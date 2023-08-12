import 'package:svart/src/actions/action.dart';
import 'package:svart/src/actions/assert.dart';
import 'package:svart/src/actions/assignment.dart';
import 'package:svart/src/actions/delay.dart';
import 'package:svart/src/actions/dump.dart';
import 'package:svart/src/actions/if.dart';
import 'package:svart/src/actions/when.dart';
import 'package:svart/src/procedures/combinational.dart';
import 'package:svart/src/procedures/initial.dart';
import 'package:svart/src/procedures/procedure.dart';
import 'package:svart/src/procedures/sync_sequential.dart';
import 'package:svart/src/utilities/keywords.dart';
import 'package:svart/src/utilities/regexps.dart';
import 'package:svart/src/var.dart';

/// The main element of the description of circuits.
abstract class Module {
  /// Creates a new module instance.
  Module({required String definitionName, String? instanceName})
      : this._(definitionName, instanceName ?? '_instance');

  /// Complete internal module constructor.
  Module._(this.definitionName, this.instanceName) {
    if (!RegExps.moduleName.hasMatch(definitionName)) {
      throw Exception('Invalid module definition name.');
    }
    if (Keywords.svDefault.contains(definitionName)) {
      throw Exception(
        'The module definition name uses one of the reserved keywords.',
      );
    }
    if (!RegExps.moduleName.hasMatch(instanceName)) {
      throw Exception('Invalid module instance name.');
    }
    if (Keywords.svDefault.contains(instanceName)) {
      throw Exception(
        'The module instance name uses one of the reserved keywords.',
      );
    }
  }

  /// Adds a new input port.
  Var addInput(String name, Var driver, {int width = 1}) {
    if (width != driver.width) {
      throw Exception('Widths must be equal.');
    }
    inputs.add(Var.full(name, width, [driver], Operation.none, []));
    return inputs.last;
  }

  /// Adds a new output port.
  Var addOutput(String name, {int width = 1}) {
    outputs.add(Var.full(name, width, [], Operation.none, []));
    return outputs.last;
  }

  /// Adds a new internal signal.
  Var addInternal({String? name, int width = 1}) {
    internals.add(Var.full(name ?? '_internal', width, [], Operation.none, []));
    return internals.last;
  }

  /// Adds a new submodule.
  T addSubmodule<T extends Module>(T submodule) {
    // Check that all outputs are connected.
    for (final output in submodule.outputs) {
      var isConnected = false;
      for (final varia in [...outputs, ...internals]) {
        if (varia.drivers.contains(output)) {
          isConnected = true;
          break;
        }
      }
      if (!isConnected) {
        throw Exception('All output ports must be connected.');
      }
    }
    submodules.add(submodule);
    return submodules.last as T;
  }

  /// Adds a new `initial` procedure.
  Initial addInitial(List<Action> actions) {
    initials.add(Initial(actions));
    return initials.last;
  }

  /// Adds a new `always_comb` procedure.
  Combinational addCombinational(List<Action> actions) {
    combinationals.add(Combinational(actions));
    return combinationals.last;
  }

  /// Adds a new `always_ff` procedure.
  SyncSequential addSyncSequential(Edge event, List<Action> actions) {
    syncSequentials.add(SyncSequential(event, actions));
    return syncSequentials.last;
  }

  /// Generates SystemVerilog code.
  String emit() {
    final inputs = <String>[];
    for (final input in this.inputs) {
      final String width;
      if (input.width == 1) {
        width = ' ';
      } else {
        width = ' [${input.width - 1}:0] ';
      }
      inputs.add('\n  input logic$width${input.name}');
    }

    final outputs = <String>[];
    for (final output in this.outputs) {
      final String width;
      if (output.width == 1) {
        width = ' ';
      } else {
        width = ' [${output.width - 1}:0] ';
      }
      outputs.add('\n  output logic$width${output.name}');
    }

    final internals = <String>[];
    for (final internal in this.internals) {
      final String width;
      if (internal.width == 1) {
        width = ' ';
      } else {
        width = ' [${internal.width - 1}:0] ';
      }
      internals.add('  logic$width${internal.name};');
    }

    final submodules = (definitions: <String>[], instantiations: <String>[]);
    for (final submodule in this.submodules) {
      submodules.definitions.add('${submodule.emit()}\n');
      final connections = <String>[];
      for (final input in submodule.inputs) {
        for (final varia in [
          ...this.inputs,
          ...this.outputs,
          ...this.internals
        ]) {
          if (input.drivers.contains(varia)) {
            connections.add('.${input.name}(${varia.name})');
            break;
          }
        }
      }
      for (final output in submodule.outputs) {
        for (final varia in [...this.outputs, ...this.internals]) {
          if (varia.drivers.contains(output)) {
            connections.add('.${output.name}(${varia.name})');
            break;
          }
        }
      }
      submodules.instantiations
          .add('\n  ${submodule.definitionName} ${submodule.instanceName} '
              '(${connections.join(', ')});');
    }

    var partCounter = 0;

    String parseProcedure(Procedure procedure) {
      ({String basic, List<String> auxiliaries}) parseVaria(Var varia) {
        late final String basic;
        final auxiliaries = <String>[];

        void doCommonBinaryOperation(String operator) {
          final parsedVaria0 = parseVaria(varia.drivers[0]);
          final parsedVaria1 = parseVaria(varia.drivers[1]);
          basic = '(${parsedVaria0.basic}) $operator (${parsedVaria1.basic})';
          auxiliaries.insertAll(
            0,
            [...parsedVaria0.auxiliaries, ...parsedVaria1.auxiliaries],
          );
        }

        switch (varia.operation) {
          case Operation.none:
            if (varia is Const) {
              basic = "${varia.width}'h"
                  '${varia.value.toRadixString(16).toUpperCase()}';
            } else {
              basic = varia.name;
            }
          case Operation.not:
            final parsedVaria = parseVaria(varia.drivers[0]);
            basic = '~(${parsedVaria.basic})';
            auxiliaries.insertAll(0, parsedVaria.auxiliaries);
          case Operation.and:
            doCommonBinaryOperation('&');
          case Operation.or:
            doCommonBinaryOperation('|');
          case Operation.sl:
            final parsedVaria = parseVaria(varia.drivers[0]);
            basic = '(${parsedVaria.basic}) << ${varia.parameters[0]}';
            auxiliaries.insertAll(0, parsedVaria.auxiliaries);
          case Operation.sr:
            final parsedVaria = parseVaria(varia.drivers[0]);
            basic = '(${parsedVaria.basic}) >> ${varia.parameters[0]}';
            auxiliaries.insertAll(0, parsedVaria.auxiliaries);
          case Operation.dsl:
            doCommonBinaryOperation('<<');
          case Operation.dsr:
            doCommonBinaryOperation('>>');
          case Operation.part:
            // Unfortunately, SystemVerilog limits the "part-select" use cases
            // (see "IEEE Std 1800-2017", 11.5 Operands), requiring workarounds
            // that break direct "Svart-to-SystemVerilog" matching.
            //
            // As a workaround, it is proposed to put the expression to which
            // "part-select" is applied in a separate "always_comb" block, and
            // assign the expression itself to additional "logic". In this case,
            // "assign" is not used because "always_comb" is the best solution
            // (see https://bradpierce.wordpress.com/2009/12/04/sv-always_comb-safer-than-verilog-assign/).
            final parsedVaria = parseVaria(varia.drivers[0]);
            final name = '_part${partCounter++}';
            basic = '$name[${varia.parameters[0]}:${varia.parameters[1]}]';
            final String width;
            if (varia.width == 1) {
              width = ' ';
            } else {
              width = ' [${varia.drivers[0].width - 1}:0] ';
            }
            auxiliaries.insertAll(0, [
              ...parsedVaria.auxiliaries,
              '  logic$width$name = ${parsedVaria.basic};'
            ]);
          case Operation.cat:
            final parsedVaria0 = parseVaria(varia.drivers[0]);
            final parsedVaria1 = parseVaria(varia.drivers[1]);
            basic = '{${parsedVaria0.basic}, ${parsedVaria1.basic}}';
            auxiliaries.insertAll(
              0,
              [...parsedVaria0.auxiliaries, ...parsedVaria1.auxiliaries],
            );
          case Operation.eq:
            doCommonBinaryOperation('==');
          case Operation.neq:
            doCommonBinaryOperation('!=');
          case Operation.lt:
            doCommonBinaryOperation('<');
          case Operation.gt:
            doCommonBinaryOperation('>');
          case Operation.lte:
            doCommonBinaryOperation('<=');
          case Operation.gte:
            doCommonBinaryOperation('>=');
          case Operation.add:
            doCommonBinaryOperation('+');
          case Operation.sub:
            doCommonBinaryOperation('-');
          case Operation.mul:
            doCommonBinaryOperation('*');
        }
        return (basic: basic, auxiliaries: auxiliaries);
      }

      ({String basic, List<String> auxiliaries}) parseAction(
        Action action,
        int indentationLevel,
      ) {
        final indentation = '  ' * indentationLevel;

        ({List<String> basics, List<String> auxiliaries}) parseAssignment(
          Assignment assignment,
        ) {
          final parsedVaria = parseVaria(assignment.source);
          final String assignmentOperator;
          if ((procedure is Initial) || (procedure is Combinational)) {
            assignmentOperator = '=';
          } else if (procedure is SyncSequential) {
            assignmentOperator = '<=';
          } else {
            throw Exception('Unknown procedure type: ${procedure.runtimeType}');
          }
          final basics = [
            [
              '${assignment.destination.name} $assignmentOperator ',
              '${parsedVaria.basic};'
            ].join()
          ];
          final auxiliaries = parsedVaria.auxiliaries;
          if (procedure is Combinational) {
            // However, the chosen workaround to overcome "part-select"
            // limitations has a drawback: when using the "always_comb"
            // procedure, you may encounter a race condition that occurs when
            // changing the values located in the additional "always_comb"
            // (see https://github.com/steveicarus/iverilog/issues/872#issuecomment-1445490519).
            // To solve this problem, the assignment needs to be moved inside
            // the procedure block, which forces more code to be generated.
            final auxiliaryDeclarations = <String>[];
            final auxiliaryAssignments = <String>[];
            for (final auxiliary in auxiliaries) {
              final temp = auxiliary.split(' = ');
              auxiliaryDeclarations.add('${temp.first};\n');
              final temp2 = temp.first.split(' ').last;
              auxiliaryAssignments.add('$temp2 = ${temp.last}\n$indentation');
            }
            basics.insertAll(0, auxiliaryAssignments);
            auxiliaries
              ..clear()
              ..addAll(auxiliaryDeclarations);
          } else if (procedure is SyncSequential) {
            final auxiliaryDeclarations = <String>[];
            final auxiliaryAssignments = <String>[];
            for (final auxiliary in auxiliaries) {
              final temp = auxiliary.split(' = ');
              auxiliaryDeclarations.add('${temp.first};\n');
              final temp2 = temp.first.split(' ').last;
              auxiliaryAssignments.add('  always_comb $temp2 = ${temp.last}\n');
            }
            auxiliaries
              ..clear()
              ..addAll(auxiliaryDeclarations)
              ..addAll(auxiliaryAssignments);
          }
          return (basics: basics, auxiliaries: auxiliaries);
        }

        ({String basic, List<String> auxiliaries}) parseIf(If conditional) {
          final parsedVaria = parseVaria(conditional.condition);
          final auxiliaries = parsedVaria.auxiliaries;
          final thenActions = <String>[];
          for (final thenAction in conditional.thenActions) {
            final parsedAction = parseAction(thenAction, indentationLevel + 1);
            thenActions.add(parsedAction.basic);
            auxiliaries.addAll(parsedAction.auxiliaries);
          }
          thenActions.add('${indentation}end');
          final elseActions = <String>[];
          if (conditional.elseActions != null) {
            elseActions.add(' else begin\n');
            for (final elseAction in conditional.elseActions!) {
              final parsedAction =
                  parseAction(elseAction, indentationLevel + 1);
              elseActions.add(parsedAction.basic);
              auxiliaries.addAll(parsedAction.auxiliaries);
            }
            elseActions.add('${indentation}end');
          }
          return (
            basic: '${indentation}if (${parsedVaria.basic}) begin\n'
                '${thenActions.join()}${elseActions.join()}',
            auxiliaries: auxiliaries
          );
        }

        ({String basic, List<String> auxiliaries}) parseWhen(When when) {
          final auxiliaries = <String>[];
          final iffs = <String>[];
          for (var i = 0; i < when.iffs.length; ++i) {
            final iff = when.iffs[i];
            final parsedVaria = parseVaria(iff.condition);
            final String begin;
            if (i == 0) {
              begin = 'if (${parsedVaria.basic}) begin\n';
            } else {
              begin = ' else if (${parsedVaria.basic}) begin\n';
            }
            auxiliaries.addAll(parsedVaria.auxiliaries);
            final actions = <String>[];
            for (final action in iff.actions) {
              final parsedAction = parseAction(action, indentationLevel + 1);
              actions.add(parsedAction.basic);
              auxiliaries.addAll(parsedAction.auxiliaries);
            }
            iffs.add('$begin${actions.join()}${indentation}end');
          }
          final elseActions = <String>[];
          if (when.elseActions != null) {
            elseActions.add(' else begin\n');
            for (final elseAction in when.elseActions!) {
              final parsedAction =
                  parseAction(elseAction, indentationLevel + 1);
              elseActions.add(parsedAction.basic);
              auxiliaries.addAll(parsedAction.auxiliaries);
            }
            elseActions.add('${indentation}end');
          }
          return (
            basic: '$indentation${iffs.join()}${elseActions.join()}',
            auxiliaries: auxiliaries
          );
        }

        ({String basic, List<String> auxiliaries}) parseAssert(
          Assert assertion,
        ) {
          final parsedVaria = parseVaria(assertion.condition);
          return (
            basic: 'assert (${parsedVaria.basic}) else \$fatal;',
            auxiliaries: parsedVaria.auxiliaries
          );
        }

        String parseDelay(Delay delay) {
          return '#${delay.value};';
        }

        String parseDump(Dump dump) {
          return '\$dumpfile("${dump.fileName}");\n'
              '$indentation\$dumpvars(0, ${dump.moduleName});';
        }

        final String basic;
        final auxiliaries = <String>[];
        if (action is Assignment) {
          final parsedAssignment = parseAssignment(action);
          basic = '$indentation${parsedAssignment.basics.join()}\n';
          auxiliaries.addAll(parsedAssignment.auxiliaries);
        } else if (action is If) {
          final parsedIf = parseIf(action);
          basic = '${parsedIf.basic}\n';
          auxiliaries.addAll(parsedIf.auxiliaries);
        } else if (action is When) {
          final parsedWhen = parseWhen(action);
          basic = '${parsedWhen.basic}\n';
          auxiliaries.addAll(parsedWhen.auxiliaries);
        } else if (action is Assert) {
          final parsedAssert = parseAssert(action);
          basic = '$indentation${parsedAssert.basic}\n';
          auxiliaries.addAll(parsedAssert.auxiliaries);
        } else if (action is Delay) {
          final parsedDelay = parseDelay(action);
          basic = '$indentation$parsedDelay\n';
        } else if (action is Dump) {
          final parsedDump = parseDump(action);
          basic = '$indentation$parsedDump\n';
        } else {
          throw Exception('Unknown action type: ${action.runtimeType}');
        }
        return (basic: basic, auxiliaries: auxiliaries);
      }

      final basic = <String>[];
      final auxiliaries = <String>[];
      for (final action in procedure.actions) {
        final parsedAction = parseAction(action, 2);
        basic.add(parsedAction.basic);
        auxiliaries.addAll(parsedAction.auxiliaries);
      }

      final String begin;
      if (procedure is Initial) {
        begin = '  initial begin\n';
      } else if (procedure is Combinational) {
        begin = '  always_comb begin\n';
      } else if (procedure is SyncSequential) {
        final parsedVaria = parseVaria(procedure.event.source);
        final String event;
        if (procedure.event is PosEdge) {
          event = '@(posedge ${parsedVaria.basic})';
        } else {
          throw Exception('Unknown event type: ${procedure.event.runtimeType}');
        }
        begin = '  always_ff $event begin\n';
        auxiliaries.insertAll(0, parsedVaria.auxiliaries);
      } else {
        throw Exception('Unknown procedure type: ${procedure.runtimeType}');
      }
      if (auxiliaries.isNotEmpty) {
        auxiliaries.insert(0, '\n');
      }
      return '${auxiliaries.join()}$begin${basic.join()}  end\n';
    }

    final initials = <String>[];
    for (final initial in this.initials) {
      initials.add(parseProcedure(initial));
    }

    final combinationals = <String>[];
    for (final combinational in this.combinationals) {
      combinationals.add(parseProcedure(combinational));
    }

    final syncSequentials = <String>[];
    for (final syncSequential in this.syncSequentials) {
      syncSequentials.add(parseProcedure(syncSequential));
    }

    final String ports;
    if (inputs.isNotEmpty || outputs.isNotEmpty) {
      ports = '${[...inputs, ...outputs].join(',')}\n';
    } else {
      ports = '';
    }

    final result = [
      submodules.definitions.join('\n'),
      'module $definitionName',
      if (ports.isNotEmpty) ' ($ports);\n' else ';\n',
      internals.join('\n'),
      if (internals.join('\n').isNotEmpty) '\n',
      submodules.instantiations.join('\n'),
      if (submodules.instantiations.join('\n').isNotEmpty) '\n\n',
      initials.join('\n'),
      combinationals.join('\n'),
      if (ports.isNotEmpty &&
          internals.join('\n').isNotEmpty &&
          syncSequentials.join('\n').isNotEmpty)
        '\n',
      syncSequentials.join('\n'),
      'endmodule\n'
    ];
    return result.join();
  }

  /// Module definition name.
  final String definitionName;

  /// Module instance name.
  final String instanceName;

  /// List of inputs.
  final inputs = <Var>[];

  /// List of outputs.
  final outputs = <Var>[];

  /// List of internals.
  final internals = <Var>[];

  /// List of submodules.
  final submodules = <Module>[];

  /// List of [Initial] procedures.
  final initials = <Initial>[];

  /// List of [Combinational] procedures.
  final combinationals = <Combinational>[];

  /// List of [SyncSequential] procedures.
  final syncSequentials = <SyncSequential>[];
}
