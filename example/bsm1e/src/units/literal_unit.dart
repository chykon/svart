import 'package:svart/svart.dart';

class LiteralUnit extends Module {
  LiteralUnit(Var clock, Var write, Var inputValue, {super.instanceName})
      : super(definitionName: 'literal_unit') {
    clock = addInput('clock', clock);
    write = addInput('write', write);
    inputValue = addInput('input_value', inputValue, width: 8);
    outputValue = addOutput('output_value', width: 8);

    addSyncSequential(PosEdge(clock), [
      If(write, then: [outputValue.assign(inputValue)]),
    ]);
  }

  late final Var outputValue;
}

String main({bool noPrint = false}) {
  final systemverilog = LiteralUnit(Var(), Var(), Var(width: 8)).emit();

  if (!noPrint) {
    // ignore: avoid_print
    print(systemverilog);
  }

  return systemverilog;
}
