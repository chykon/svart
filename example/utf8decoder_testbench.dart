// Example of a testbench for a UTF-8 decoder.

import 'dart:convert';
import 'dart:io';
import 'package:svart/svart.dart';
import 'utf8decoder.dart';

// We extend the base class `Module`. This is our main block
// for building circuits.
class UTF8DecoderTestbench extends Module {
  // The constructor is useful for fully defining a module in one place.
  // For a test bench, only the name of the module definition is required.
  UTF8DecoderTestbench({String vcdFileName = 'dump.vcd'})
      : super(definitionName: 'utf8decoder_testbench') {
    // We add internal `Var`s using the `addInternal` method.
    final clock = addInternal(name: 'clock');
    final reset = addInternal(name: 'reset');
    final enable = addInternal(name: 'enable');
    final byte = addInternal(name: 'octet', width: 8);
    final status = addInternal(name: 'status', width: 3);
    final codepoint = addInternal(name: 'codepoint', width: 21);

    // We add a submodule by creating an instance of the module.
    addSubmodule(
      UTF8Decoder(clock, reset, enable, byte, name: 'utf8decoder_instance')
        ..status.to(status)
        ..codepoint.to(codepoint),
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
      // We perform a reset and check its result.
      clock.assign(Const(0)),
      reset.assign(Const(1)),
      enable.assign(Const(0)),
      clock.assign(Const(1)),
      Delay(1),
      Assert(status.eq(Const(UTF8Decoder.statusInitial, width: 3))),
      Assert(codepoint.eq(Const(0, width: 21))),
      // Check that `reset` takes precedence over `enable`.
      enable.assign(Const(1)),
      clock.assign(Const(0)),
      Delay(1),
      clock.assign(Const(1)),
      Delay(1),
      Assert(status.eq(Const(UTF8Decoder.statusInitial, width: 3))),
      Assert(codepoint.eq(Const(0, width: 21))),
      // We check that the state does not change in the absence of the
      // `reset` and `enable` signals.
      reset.assign(Const(0)),
      enable.assign(Const(0)),
      clock.assign(Const(0)),
      Delay(1),
      clock.assign(Const(1)),
      Delay(1),
      Assert(status.eq(Const(UTF8Decoder.statusInitial, width: 3))),
      Assert(codepoint.eq(Const(0, width: 21))),
      // Let's generate test values from an external file.
      enable.assign(Const(1)),
      // Used "UTF-8 encoded sample plain-text file"
      // Link: https://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-demo.txt
      ...() {
        // Leverage the power of a general purpose programming language to
        // generate clock, inputs, delays, and compare actual outputs to
        // expected ones.
        final actions = <Action>[];
        final testBytes = File('test/input/utf8demo.txt').readAsBytesSync();
        final testString = utf8.decode(testBytes);
        final testCodepoints = testString.runes;
        for (final testCodepoint in testCodepoints) {
          final codepointBytes =
              utf8.encode(String.fromCharCode(testCodepoint));
          for (var i = 0; i < codepointBytes.length; ++i) {
            actions.addAll([
              byte.assign(Const(codepointBytes[i], width: 8)),
              clock.assign(Const(0)),
              Delay(1),
              clock.assign(Const(1)),
              Delay(1),
            ]);
            if (i == (codepointBytes.length - 1)) {
              actions.addAll([
                Assert(
                  status.eq(Const(UTF8Decoder.statusSuccess, width: 3)),
                ),
                Assert(
                  codepoint.eq(Const(testCodepoint, width: 21)),
                ),
              ]);
            } else {
              actions.add(
                Assert(
                  status.eq(Const(UTF8Decoder.statusInprocess, width: 3)),
                ),
              );
            }
          }
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
          for (var i = 0; i < codepointBytes.length; ++i) {
            actions.addAll([
              byte.assign(Const(codepointBytes[i], width: 8)),
              clock.assign(Const(0)),
              Delay(1),
              clock.assign(Const(1)),
              Delay(1),
            ]);
            if (i == (codepointBytes.length - 1)) {
              actions.addAll([
                Assert(
                  status.eq(Const(UTF8Decoder.statusSuccess, width: 3)),
                ),
                Assert(
                  codepoint.eq(Const(testCodepoint, width: 21)),
                ),
              ]);
            } else {
              actions.add(
                Assert(
                  status.eq(Const(UTF8Decoder.statusInprocess, width: 3)),
                ),
              );
            }
          }
        }
        return actions;
      }()
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
  final utf8decoderTestbench = UTF8DecoderTestbench(vcdFileName: vcdFileName);
  // We generate the SystemVerilog code by calling the `emit` method.
  final utf8decoderTestbenchEmitted = utf8decoderTestbench.emit();

  // The presence or absence of output depends on the value of
  // the `noPrint` flag.
  if (!noPrint) {
    // We output the generated code to the terminal.
    // The line below is used to ignore the linter rule
    // (`print` is an easy way to output to the terminal):
    // ignore: avoid_print
    print(utf8decoderTestbenchEmitted);
  }

  File(svFileName)
    ..createSync(recursive: true)
    ..writeAsStringSync(utf8decoderTestbenchEmitted);

  // We use `iverilog` to compile and run the simulation.
  final resultCompile = Tools.iverilog.compile(
    svFileName,
    utf8decoderTestbench.definitionName,
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
