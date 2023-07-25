// Example of a test bench for a 4-bit counter.

import 'dart:io';
import 'dart:math';
import 'package:svart/svart.dart';
import 'counter4bit.dart';

// We extend the base class `Module`. This is our main block
// for building circuits.
class Counter4BitTestbench extends Module {
  // The constructor is useful for fully defining a module in one place.
  // For a test bench, only the name of the module definition is required.
  Counter4BitTestbench({String vcdFileName = 'dump.vcd'})
      : super(definitionName: 'counter4bit_testbench') {
    // We add internal `Var`s using the `addInternal` method.
    final clock = addInternal(name: 'clock');
    final reset = addInternal(name: 'reset');
    final enable = addInternal(name: 'enable');
    final value = addInternal(name: 'value', width: 4);

    // We add a submodule by creating an instance of the module.
    // In the constructor, we pass our internal `Var`s and also set the name of
    // the instance. Using the cascade (`..`), we access the output `value` and
    // call the `to` method to connect the output of the module to our
    // test bench.
    addSubmodule(
      Counter4Bit(clock, reset, enable, name: 'counter4bit_instance')
        ..value.to(value),
    );

    // We add a block of logic that is executed once.
    //
    // This is non-synthesizable logic that is used to control the inputs of
    // the module under test and compare the actual output values
    // with the expected ones.
    addInitial([
      // The `Dump` action is used to set the simulator to write the
      // history of signal changes to a file. The resulting `VCD` format file
      // can be read, for example, using the `GTKWave` program.
      Dump(moduleName: definitionName, fileName: vcdFileName),
      // We set the required values for the inputs.
      clock.assign(Const(0)),
      // We must reset first, since the initial state of the circuit is unknown.
      reset.assign(Const(1)),
      enable.assign(Const(0)),
      // Since the unit under test is designed using synchronous serial logic,
      // the test bench must also drive the clock signal. In other words, it
      // is necessary to recreate the behavior of the clock generator.
      clock.assign(Const(1)),
      // The `Delay` is required for the values of the outputs to be updated
      // based on the given inputs. The delay must be non-zero.
      Delay(1),
      // Compare the actual value of the output with the expected value.
      Assert(value.eq(Const(0, width: 4))),
      // When the reset is done, we can start using the circuit.
      reset.assign(Const(0)),
      enable.assign(Const(1)),
      // We use the immediately invoked function expression and the
      // spread operator to conveniently generate a large list of actions.
      ...() {
        // Leverage the power of a general purpose programming language to
        // generate clock, inputs, delays, and compare actual outputs to
        // expected ones.
        final actions = <Action>[];
        for (var i = 0; i < pow(2, value.width); ++i) {
          actions.addAll([
            clock.assign(Const(0)),
            Delay(1),
            clock.assign(Const(1)),
            Delay(1),
            Assert(
              value.eq(Const((i + 1) % pow(2, value.width).toInt(), width: 4)),
            ),
          ]);
        }
        return actions;
      }(),
    ]);
  }
}

// Here is a demo of code generation and simulation. Parameters are used for
// testing purposes, so this can be ignored.
({
  String stdoutCompile,
  String stderrCompile,
  String stdoutRun,
  String stderrRun
}) main({
  bool noPrint = false,
  String vcdFileName = 'dump.vcd',
  String svFileName = 'out.sv',
  String vvpFileName = 'out.vvp',
}) {
  // We create an instance of the module.
  final counter4bitTestbench = Counter4BitTestbench(vcdFileName: vcdFileName);
  // We generate the SystemVerilog code by calling the `emit` method.
  final counter4bitTestbenchEmitted = counter4bitTestbench.emit();

  // The presence or absence of output depends on the value of
  // the `noPrint` flag.
  if (!noPrint) {
    // We output the generated code to the terminal.
    // The line below is used to ignore the linter rule
    // (`print` is an easy way to output to the terminal):
    // ignore: avoid_print
    print(counter4bitTestbenchEmitted);
  }

  File(svFileName)
    ..createSync(recursive: true)
    ..writeAsStringSync(counter4bitTestbenchEmitted);

  // We use `iverilog` to compile and run the simulation.
  final resultCompile = Tools.iverilog.compile(
    svFileName,
    counter4bitTestbench.definitionName,
    outputFile: vvpFileName,
  );
  final resultRun = Tools.iverilog.run(file: vvpFileName);
  return (
    stdoutCompile: resultCompile.stdout,
    stderrCompile: resultCompile.stderr,
    stdoutRun: resultRun.stdout,
    stderrRun: resultRun.stderr
  );
}
