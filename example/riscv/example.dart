import 'dart:io';
import 'package:svart/svart.dart';
import 'src/riscv.dart';

class RISCVTestbench extends Module {
  RISCVTestbench() : super(definitionName: 'riscv_testbench') {
    final clock = addInternal(name: 'clock');
    final reset = addInternal(name: 'reset');

    addSubmodule(RISCV(clock, reset));

    addInitial([
      Dump(moduleName: definitionName),
      clock.assign(Const(0)),
      reset.assign(Const(1)),
      Delay(1),
      clock.assign(Const(1)),
      Delay(1),
      reset.assign(Const(0)),
      clock.assign(Const(0)),
      Delay(1),
      clock.assign(Const(1)),
      ...() {
        final actions = <Action>[];
        for (var i = 0; i < 64; ++i) {
          actions.addAll([
            Delay(1),
            clock.assign(Const(0)),
            Delay(1),
            clock.assign(Const(1)),
          ]);
        }
        return actions;
      }(),
    ]);
  }
}

void main() {
  final riscvTestbench = RISCVTestbench();

  File('out.sv').writeAsStringSync(riscvTestbench.emit());

  Tools.iverilog
    ..compile('out.sv', riscvTestbench.definitionName)
    ..run();
}
