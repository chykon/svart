import 'package:svart/svart.dart';

class LogicBlock extends Module {
  LogicBlock(
    String instanceName, {
    required ({
      Var clk,
      Var rstN,
      Var iEn,
      Var iA,
      Var iB,
    }) inputs,
    required ({
      Var oYComb,
      Var oYSync,
    }) outputs,
    this.function = LogicFunction.nand,
    this.resetValue = 0,
  }) : super(definitionName: 'logic_block', instanceName: instanceName) {
    final clk = addInput('clk', inputs.clk);
    final rstN = addInput('rst_n', inputs.rstN);
    final iEn = addInput('en_i', inputs.iEn);
    final iA = addInput('a_i', inputs.iA);
    final iB = addInput('b_i', inputs.iB);
    final oYComb = addOutput('y_comb_o')..to(outputs.oYComb);
    final oYSync = addOutput('y_sync_o')..to(outputs.oYSync);

    addCombinational([
      switch (function) {
        LogicFunction.nand => oYComb.assign(iA.and(iB).not()),
        LogicFunction.nor => oYComb.assign(iA.or(iB).not())
      },
    ]);

    addSyncSequential(PosEdge(clk), [
      If(
        rstN.not(),
        then: [
          oYSync.assign(Const(resetValue)),
        ],
        orElse: [
          If(iEn, then: [oYSync.assign(oYComb)]),
        ],
      ),
    ]);
  }

  final LogicFunction function;
  final int resetValue;
}

enum LogicFunction { nand, nor }
