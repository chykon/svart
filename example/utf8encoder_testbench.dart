// Example of a testbench for a UTF-8 encoder.

import 'dart:convert';
import 'dart:io';
import 'package:svart/svart.dart';
import 'utf8encoder.dart';

// We extend the base class `Module`. This is our main block
// for building circuits.
class UTF8EncoderTestbench extends Module {
  // The constructor is useful for fully defining a module in one place.
  // For a test bench, only the name of the module definition is required.
  UTF8EncoderTestbench({String vcdFileName = 'dump.vcd'})
      : super(definitionName: 'utf8encoder_testbench') {
    // We add internal `Var`s using the `addInternal` method.
    final codepoint = addInternal(name: 'codepoint', width: 21);
    final status = addInternal(name: 'status');
    final bytes = addInternal(name: 'bytes', width: 32);

    // We add a submodule by creating an instance of the module.
    addSubmodule(
      UTF8Encoder(codepoint, name: 'utf8encoder_instance')
        ..status.to(status)
        ..bytes.to(bytes),
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
      // Let's check that a code point outside the allowed range results
      // in an error.
      ...[
        codepoint.assign(Const(0x110000, width: 21)),
        Delay(1),
        Assert(status.eq(Const(UTF8Encoder.statusFailure))),
      ],
      // Let's generate test values from an external file.
      // Used "UTF-8 encoded sample plain-text file"
      // Link: https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-demo.txt
      ...() {
        // Leverage the power of a general purpose programming language to
        // generate inputs, delays, and compare actual outputs to
        // expected ones.
        final actions = <Action>[];
        final testBytes = File('test/input/utf8demo.txt').readAsBytesSync();
        final testString = utf8.decode(testBytes);
        final testCodepoints = testString.runes;
        for (final testCodepoint in testCodepoints) {
          final codepointBytes =
              utf8.encode(String.fromCharCode(testCodepoint));
          var expectedOutput = 0;
          for (var i = 0; i < codepointBytes.length; ++i) {
            expectedOutput = expectedOutput | (codepointBytes[i] << (8 * i));
          }
          actions.addAll([
            codepoint.assign(Const(testCodepoint, width: 21)),
            Delay(1),
            Assert(status.eq(Const(UTF8Encoder.statusSuccess))),
            Assert(bytes.eq(Const(expectedOutput, width: 32))),
          ]);
        }
        return actions;
      }(),
      // Used "UTF-8 decoder capability and stress test"
      // Link: https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt
      ...() {
        final actions = <Action>[];
        final testBytes = File('test/input/utf8test.txt').readAsBytesSync();
        final testString = utf8.decode(testBytes, allowMalformed: true);
        final testCodepoints = testString.runes;
        for (final testCodepoint in testCodepoints) {
          final codepointBytes =
              utf8.encode(String.fromCharCode(testCodepoint));
          var expectedOutput = 0;
          for (var i = 0; i < codepointBytes.length; ++i) {
            expectedOutput = expectedOutput | (codepointBytes[i] << (8 * i));
          }
          actions.addAll([
            codepoint.assign(Const(testCodepoint, width: 21)),
            Delay(1),
            Assert(status.eq(Const(UTF8Encoder.statusSuccess))),
            Assert(bytes.eq(Const(expectedOutput, width: 32))),
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
  final utf8encoderTestbench = UTF8EncoderTestbench(vcdFileName: vcdFileName);
  // We generate the SystemVerilog code by calling the `emit` method.
  final utf8encoderTestbenchEmitted = utf8encoderTestbench.emit();

  // The presence or absence of output depends on the value of
  // the `noPrint` flag.
  if (!noPrint) {
    // We output the generated code to the terminal.
    // The line below is used to ignore the linter rule
    // (`print` is an easy way to output to the terminal):
    // ignore: avoid_print
    print(utf8encoderTestbenchEmitted);
  }

  File(svFileName)
    ..createSync(recursive: true)
    ..writeAsStringSync(utf8encoderTestbenchEmitted);

  // We use `iverilog` to compile and run the simulation.
  final resultCompile = Tools.iverilog.compile(
    svFileName,
    utf8encoderTestbench.definitionName,
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
