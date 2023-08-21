// Example of a test bench for a 2-to-1 multiplexer.

// Import the library for working with files and processes.
import 'dart:io';
// Import the `Svart` package.
import 'package:svart/svart.dart';
// Import the target module for testing.
import 'mux2to1.dart';

// We extend the base class `Module`. This is our main block
// for building circuits.
class Mux2to1Testbench extends Module {
  // The constructor is useful for fully defining a module in one place.
  // For a test bench, only the name of the module definition is required.
  Mux2to1Testbench({String vcdFileName = 'dump.vcd'})
      : super(definitionName: 'mux2to1_testbench') {
    // We add internal `Var`s using the `addInternal` method.
    final a = addInternal(name: 'a');
    final b = addInternal(name: 'b');
    final sel = addInternal(name: 'sel');
    final y = addInternal(name: 'y');

    // We add a submodule by creating an instance of the module.
    // In the constructor, we pass our internal `Var`s and also set the name of
    // the instance. Using the cascade (`..`), we access the output `y` and call
    // the `to` method to connect the output of the module to our test bench.
    addSubmodule(Mux2to1(a, b, sel, name: 'mux2to1_instance')..y.to(y));

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
      a.assign(Const(0)),
      b.assign(Const(0)),
      sel.assign(Const(0)),
      // The `Delay` is required for the values of the outputs to be updated
      // based on the given inputs. For combinational logic, you can use
      // zero delay, but in this case, the timing diagram will display only
      // the last signal value, and not the entire history of changes.
      Delay(1),
      // Compare the actual value of the output with the expected value.
      Assert(y.eq(Const(0))),
      // Repeat the "assign-delay-assert" steps.
      a.assign(Const(1)),
      b.assign(Const(0)),
      sel.assign(Const(0)),
      Delay(1),
      Assert(y.eq(Const(0))),
      a.assign(Const(0)),
      b.assign(Const(1)),
      sel.assign(Const(0)),
      Delay(1),
      Assert(y.eq(Const(1))),
      a.assign(Const(1)),
      b.assign(Const(1)),
      sel.assign(Const(0)),
      Delay(1),
      Assert(y.eq(Const(1))),
      a.assign(Const(0)),
      b.assign(Const(0)),
      sel.assign(Const(1)),
      Delay(1),
      Assert(y.eq(Const(0))),
      a.assign(Const(1)),
      b.assign(Const(0)),
      sel.assign(Const(1)),
      Delay(1),
      Assert(y.eq(Const(1))),
      a.assign(Const(0)),
      b.assign(Const(1)),
      sel.assign(Const(1)),
      Delay(1),
      Assert(y.eq(Const(0))),
      a.assign(Const(1)),
      b.assign(Const(1)),
      sel.assign(Const(1)),
      Delay(1),
      Assert(y.eq(Const(1))),
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
  final mux2to1Testbench = Mux2to1Testbench(vcdFileName: vcdFileName);
  // We generate the SystemVerilog code by calling the `emit` method.
  final mux2to1TestbenchEmitted = mux2to1Testbench.emit();

  // The presence or absence of output depends on the value of
  // the `noPrint` flag.
  if (!noPrint) {
    // We output the generated code to the terminal.
    // The line below is used to ignore the linter rule
    // (`print` is an easy way to output to the terminal):
    // ignore: avoid_print
    print(mux2to1TestbenchEmitted);
  }

  File(svFileName)
    ..createSync(recursive: true)
    ..writeAsStringSync(mux2to1TestbenchEmitted);

  // We use `iverilog` to compile and run the simulation.
  final resultCompile = Tools.iverilog.compile(
    svFileName,
    mux2to1Testbench.definitionName,
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
