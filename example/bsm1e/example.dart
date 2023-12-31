import 'dart:io';
import 'package:svart/svart.dart';
import 'src/bsm1e.dart';

class BSM1ETestbench extends Module {
  BSM1ETestbench({String vcdFileName = 'dump.vcd'})
      : super(definitionName: 'bsm1e_testbench') {
    final clock = addInternal(name: 'clock');
    final reset = addInternal(name: 'reset');

    addSubmodule(BSM1E(clock, reset));

    addInitial([
      Dump(moduleName: definitionName, fileName: vcdFileName),
      clock.assign(Const(0)),
      clock.assign(Const(1)),
      Delay(1),
      clock.assign(Const(0)),
      Delay(1),
      clock.assign(Const(1)),
      reset.assign(Const(1)),
      Delay(1),
      clock.assign(Const(0)),
      reset.assign(Const(0)),
      Delay(1),
      ...() {
        final actions = <Action>[];
        for (var i = 0; i < 11; ++i) {
          actions.addAll([
            clock.assign(Const(1)),
            Delay(1),
            clock.assign(Const(0)),
            Delay(1),
          ]);
        }
        return actions;
      }(),
    ]);
  }
}

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
  final bsm1eTestbench = BSM1ETestbench(vcdFileName: vcdFileName);
  final bsm1eTestbenchEmitted = bsm1eTestbench.emit();

  if (!noPrint) {
    // ignore: avoid_print
    print(bsm1eTestbenchEmitted);
  }

  File(svFileName)
    ..createSync(recursive: true)
    ..writeAsStringSync(bsm1eTestbenchEmitted);

  final resultCompile = Tools.iverilog.compile(
    svFileName,
    bsm1eTestbench.definitionName,
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
