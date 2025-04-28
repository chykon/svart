import 'package:svart/svart.dart';

/*

      0
      |
  3 - X - 1
      |
      2

*/

class RouteBlock extends Module {
  RouteBlock(
    String instanceName, {
    required ({
      Var iDirComb0,
      Var iDirComb1,
      Var iDirComb2,
      Var iDirComb3,
      Var iDirSync0,
      Var iDirSync1,
      Var iDirSync2,
      Var iDirSync3,
      Var iYComb,
      Var iYSync,
      Var iTgtEn,
      Var iTgtA,
      Var iTgtB,
      Var iTgtYComb,
      Var iTgtYSync,
    }) inputs,
    required ({
      Var oDirComb0,
      Var oDirComb1,
      Var oDirComb2,
      Var oDirComb3,
      Var oDirSync0,
      Var oDirSync1,
      Var oDirSync2,
      Var oDirSync3,
      Var oEn,
      Var oA,
      Var oB,
    }) outputs,
  }) : super(definitionName: 'route_block', instanceName: instanceName) {
    final iDirComb0 = addInput('dir_comb_0_i', inputs.iDirComb0);
    final iDirComb1 = addInput('dir_comb_1_i', inputs.iDirComb1);
    final iDirComb2 = addInput('dir_comb_2_i', inputs.iDirComb2);
    final iDirComb3 = addInput('dir_comb_3_i', inputs.iDirComb3);
    final iDirSync0 = addInput('dir_sync_0_i', inputs.iDirSync0);
    final iDirSync1 = addInput('dir_sync_1_i', inputs.iDirSync1);
    final iDirSync2 = addInput('dir_sync_2_i', inputs.iDirSync2);
    final iDirSync3 = addInput('dir_sync_3_i', inputs.iDirSync3);
    final iYComb = addInput('y_comb_i', inputs.iYComb);
    final iYSync = addInput('y_sync_i', inputs.iYSync);
    final iTgtEn = addInput('tgt_en_i', inputs.iTgtEn, width: 3);
    final iTgtA = addInput('tgt_a_i', inputs.iTgtA, width: 3);
    final iTgtB = addInput('tgt_b_i', inputs.iTgtB, width: 3);
    final iTgtYComb = addInput('tgt_y_comb_i', inputs.iTgtYComb, width: 4);
    final iTgtYSync = addInput('tgt_y_sync_i', inputs.iTgtYSync, width: 4);

    final oDirComb0 = addOutput('dir_comb_0_o')..to(outputs.oDirComb0);
    final oDirComb1 = addOutput('dir_comb_1_o')..to(outputs.oDirComb1);
    final oDirComb2 = addOutput('dir_comb_2_o')..to(outputs.oDirComb2);
    final oDirComb3 = addOutput('dir_comb_3_o')..to(outputs.oDirComb3);
    final oDirSync0 = addOutput('dir_sync_0_o')..to(outputs.oDirSync0);
    final oDirSync1 = addOutput('dir_sync_1_o')..to(outputs.oDirSync1);
    final oDirSync2 = addOutput('dir_sync_2_o')..to(outputs.oDirSync2);
    final oDirSync3 = addOutput('dir_sync_3_o')..to(outputs.oDirSync3);
    final oEn = addOutput('en_o')..to(outputs.oEn);
    final oA = addOutput('a_o')..to(outputs.oA);
    final oB = addOutput('b_o')..to(outputs.oB);

    //==========================================================================
    // iTgtEn
    //==========================================================================

    final tgtEnSync = addInternal(name: 'tgt_en_sync');
    addCombinational(
      [tgtEnSync.assign(iTgtEn.part(iTgtEn.width - 1, iTgtEn.width - 1))],
    );
    final tgtEnDir = addInternal(name: 'tgt_en_dir', width: 2);
    addCombinational(
      [tgtEnDir.assign(iTgtEn.part(iTgtEn.width - 2, 0))],
    );

    addCombinational([
      If(
        tgtEnSync,
        then: [
          When(
            [
              Iff(
                tgtEnDir.eq(Const(0, width: tgtEnDir.width)),
                then: [oEn.assign(iDirSync0)],
              ),
              Iff(
                tgtEnDir.eq(Const(1, width: tgtEnDir.width)),
                then: [oEn.assign(iDirSync1)],
              ),
              Iff(
                tgtEnDir.eq(Const(2, width: tgtEnDir.width)),
                then: [oEn.assign(iDirSync2)],
              ),
              Iff(
                tgtEnDir.eq(Const(3, width: tgtEnDir.width)),
                then: [oEn.assign(iDirSync3)],
              ),
            ],
            orElse: [
              Assert(Const(0)), // unreachable
            ],
          ),
        ],
        orElse: [
          When(
            [
              Iff(
                tgtEnDir.eq(Const(0, width: tgtEnDir.width)),
                then: [oEn.assign(iDirComb0)],
              ),
              Iff(
                tgtEnDir.eq(Const(1, width: tgtEnDir.width)),
                then: [oEn.assign(iDirComb1)],
              ),
              Iff(
                tgtEnDir.eq(Const(2, width: tgtEnDir.width)),
                then: [oEn.assign(iDirComb2)],
              ),
              Iff(
                tgtEnDir.eq(Const(3, width: tgtEnDir.width)),
                then: [oEn.assign(iDirComb3)],
              ),
            ],
            orElse: [
              Assert(Const(0)), // unreachable
            ],
          ),
        ],
      ),
    ]);

    //==========================================================================
    // iTgtA
    //==========================================================================

    final tgtASync = addInternal(name: 'tgt_a_sync');
    addCombinational(
      [tgtASync.assign(iTgtA.part(iTgtA.width - 1, iTgtA.width - 1))],
    );
    final tgtADir = addInternal(name: 'tgt_a_dir', width: 2);
    addCombinational(
      [tgtADir.assign(iTgtA.part(iTgtA.width - 2, 0))],
    );

    addCombinational([
      If(
        tgtASync,
        then: [
          When(
            [
              Iff(
                tgtADir.eq(Const(0, width: tgtADir.width)),
                then: [oA.assign(iDirSync0)],
              ),
              Iff(
                tgtADir.eq(Const(1, width: tgtADir.width)),
                then: [oA.assign(iDirSync1)],
              ),
              Iff(
                tgtADir.eq(Const(2, width: tgtADir.width)),
                then: [oA.assign(iDirSync2)],
              ),
              Iff(
                tgtADir.eq(Const(3, width: tgtADir.width)),
                then: [oA.assign(iDirSync3)],
              ),
            ],
            orElse: [
              Assert(Const(0)), // unreachable
            ],
          ),
        ],
        orElse: [
          When(
            [
              Iff(
                tgtADir.eq(Const(0, width: tgtADir.width)),
                then: [oA.assign(iDirComb0)],
              ),
              Iff(
                tgtADir.eq(Const(1, width: tgtADir.width)),
                then: [oA.assign(iDirComb1)],
              ),
              Iff(
                tgtADir.eq(Const(2, width: tgtADir.width)),
                then: [oA.assign(iDirComb2)],
              ),
              Iff(
                tgtADir.eq(Const(3, width: tgtADir.width)),
                then: [oA.assign(iDirComb3)],
              ),
            ],
            orElse: [
              Assert(Const(0)), // unreachable
            ],
          ),
        ],
      ),
    ]);

    //==========================================================================
    // iTgtB
    //==========================================================================

    final tgtBSync = addInternal(name: 'tgt_b_sync');
    addCombinational(
      [tgtBSync.assign(iTgtB.part(iTgtB.width - 1, iTgtB.width - 1))],
    );
    final tgtBDir = addInternal(name: 'tgt_b_dir', width: 2);
    addCombinational(
      [tgtBDir.assign(iTgtB.part(iTgtB.width - 2, 0))],
    );

    addCombinational([
      If(
        tgtBSync,
        then: [
          When(
            [
              Iff(
                tgtBDir.eq(Const(0, width: tgtBDir.width)),
                then: [oB.assign(iDirSync0)],
              ),
              Iff(
                tgtBDir.eq(Const(1, width: tgtBDir.width)),
                then: [oB.assign(iDirSync1)],
              ),
              Iff(
                tgtBDir.eq(Const(2, width: tgtBDir.width)),
                then: [oB.assign(iDirSync2)],
              ),
              Iff(
                tgtBDir.eq(Const(3, width: tgtBDir.width)),
                then: [oB.assign(iDirSync3)],
              ),
            ],
            orElse: [
              Assert(Const(0)), // unreachable
            ],
          ),
        ],
        orElse: [
          When(
            [
              Iff(
                tgtBDir.eq(Const(0, width: tgtBDir.width)),
                then: [oB.assign(iDirComb0)],
              ),
              Iff(
                tgtBDir.eq(Const(1, width: tgtBDir.width)),
                then: [oB.assign(iDirComb1)],
              ),
              Iff(
                tgtBDir.eq(Const(2, width: tgtBDir.width)),
                then: [oB.assign(iDirComb2)],
              ),
              Iff(
                tgtBDir.eq(Const(3, width: tgtBDir.width)),
                then: [oB.assign(iDirComb3)],
              ),
            ],
            orElse: [
              Assert(Const(0)), // unreachable
            ],
          ),
        ],
      ),
    ]);

    //==========================================================================
    // iTgtYComb
    //==========================================================================

    addCombinational([
      If(iTgtYComb.part(0, 0), then: [oDirComb0.assign(iYComb)]),
    ]);
    addCombinational([
      If(iTgtYComb.part(1, 1), then: [oDirComb1.assign(iYComb)]),
    ]);
    addCombinational([
      If(iTgtYComb.part(2, 2), then: [oDirComb2.assign(iYComb)]),
    ]);
    addCombinational([
      If(iTgtYComb.part(3, 3), then: [oDirComb3.assign(iYComb)]),
    ]);

    //==========================================================================
    // iTgtYSync
    //==========================================================================

    addCombinational([
      If(iTgtYSync.part(0, 0), then: [oDirSync0.assign(iYSync)]),
    ]);
    addCombinational([
      If(iTgtYSync.part(1, 1), then: [oDirSync1.assign(iYSync)]),
    ]);
    addCombinational([
      If(iTgtYSync.part(2, 2), then: [oDirSync2.assign(iYSync)]),
    ]);
    addCombinational([
      If(iTgtYSync.part(3, 3), then: [oDirSync3.assign(iYSync)]),
    ]);
  }
}
