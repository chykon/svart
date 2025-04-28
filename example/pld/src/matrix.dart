import 'package:svart/svart.dart';

import 'blocks/logic.dart';
import 'blocks/route.dart';

/*

  X - X - X
  |   |   |
  X - X - X
  |   |   |
  X - X - X

*/

/*

   0     0     0
  3 1 - 3 1 - 3 1
   2     2     2
   |     |     |
   0     0     0
  3 1 - 3 1 - 3 1
   2     2     2
   |     |     |
   0     0     0
  3 1 - 3 1 - 3 1
   2     2     2

*/

class Matrix extends Module {
  Matrix({
    required ({
      Var clk,
      Var rstN,
      List<
          ({
            Var iDirComb0,
            Var iDirComb1,
            Var iDirComb2,
            Var iDirComb3,
            Var iDirSync0,
            Var iDirSync1,
            Var iDirSync2,
            Var iDirSync3,
          })> inDirs,
      List<
          ({
            Var iTgtEn,
            Var iTgtA,
            Var iTgtB,
            Var iTgtYComb,
            Var iTgtYSync,
          })> routeTargets,
    }) inputs,
    required ({
      List<
          ({
            Var oDirComb0,
            Var oDirComb1,
            Var oDirComb2,
            Var oDirComb3,
            Var oDirSync0,
            Var oDirSync1,
            Var oDirSync2,
            Var oDirSync3,
          })> outDirs,
    }) outputs,
    this.width = 16,
    this.height = 16,
  }) : super(definitionName: 'matrix') {
    final numberOfElements = width * height;

    final clk = addInput('clk', inputs.clk);
    final rstN = addInput('rst_n', inputs.rstN);

    if (inputs.inDirs.length != numberOfElements) {
      throw Exception();
    }
    final inDirs = List.generate(
      numberOfElements,
      (index) {
        final positionWidth = index % width;
        final positionHeight = index ~/ height;
        return (
          iDirComb0: (positionHeight == 0)
              ? addInput(
                  'dir_comb_0_${index}_i',
                  inputs.inDirs[index].iDirComb0,
                )
              : null,
          iDirComb1: (positionWidth == (width - 1))
              ? addInput(
                  'dir_comb_1_${index}_i',
                  inputs.inDirs[index].iDirComb1,
                )
              : null,
          iDirComb2: (positionHeight == (height - 1))
              ? addInput(
                  'dir_comb_2_${index}_i',
                  inputs.inDirs[index].iDirComb2,
                )
              : null,
          iDirComb3: (positionWidth == 0)
              ? addInput(
                  'dir_comb_3_${index}_i',
                  inputs.inDirs[index].iDirComb3,
                )
              : null,
          iDirSync0: (positionHeight == 0)
              ? addInput(
                  'dir_sync_0_${index}_i',
                  inputs.inDirs[index].iDirSync0,
                )
              : null,
          iDirSync1: (positionWidth == (width - 1))
              ? addInput(
                  'dir_sync_1_${index}_i',
                  inputs.inDirs[index].iDirSync1,
                )
              : null,
          iDirSync2: (positionHeight == (height - 1))
              ? addInput(
                  'dir_sync_2_${index}_i',
                  inputs.inDirs[index].iDirSync2,
                )
              : null,
          iDirSync3: (positionWidth == 0)
              ? addInput(
                  'dir_sync_3_${index}_i',
                  inputs.inDirs[index].iDirSync3,
                )
              : null,
        );
      },
    );

    if (inputs.routeTargets.length != numberOfElements) {
      throw Exception();
    }
    final routeTargets = List.generate(
      numberOfElements,
      (index) => (
        iTgtEn: addInput(
          'tgt_en_${index}_i',
          inputs.routeTargets[index].iTgtEn,
          width: 3,
        ),
        iTgtA: addInput(
          'tgt_a_${index}_i',
          inputs.routeTargets[index].iTgtA,
          width: 3,
        ),
        iTgtB: addInput(
          'tgt_b_${index}_i',
          inputs.routeTargets[index].iTgtB,
          width: 3,
        ),
        iTgtYComb: addInput(
          'tgt_y_comb_${index}_i',
          inputs.routeTargets[index].iTgtYComb,
          width: 4,
        ),
        iTgtYSync: addInput(
          'tgt_y_sync_${index}_i',
          inputs.routeTargets[index].iTgtYSync,
          width: 4,
        ),
      ),
    );

    if (outputs.outDirs.length != numberOfElements) {
      throw Exception();
    }
    final outDirs = List.generate(
      numberOfElements,
      (index) {
        final positionWidth = index % width;
        final positionHeight = index ~/ height;
        return (
          oDirComb0: (positionHeight == 0)
              ? (addOutput('dir_comb_0_${index}_o')
                ..to(outputs.outDirs[index].oDirComb0))
              : null,
          oDirComb1: (positionWidth == (width - 1))
              ? (addOutput('dir_comb_1_${index}_o')
                ..to(outputs.outDirs[index].oDirComb1))
              : null,
          oDirComb2: (positionHeight == (height - 1))
              ? (addOutput('dir_comb_2_${index}_o')
                ..to(outputs.outDirs[index].oDirComb2))
              : null,
          oDirComb3: (positionWidth == 0)
              ? (addOutput('dir_comb_3_${index}_o')
                ..to(outputs.outDirs[index].oDirComb3))
              : null,
          oDirSync0: (positionHeight == 0)
              ? (addOutput('dir_sync_0_${index}_o')
                ..to(outputs.outDirs[index].oDirSync0))
              : null,
          oDirSync1: (positionWidth == (width - 1))
              ? (addOutput('dir_sync_1_${index}_o')
                ..to(outputs.outDirs[index].oDirSync1))
              : null,
          oDirSync2: (positionHeight == (height - 1))
              ? (addOutput('dir_sync_2_${index}_o')
                ..to(outputs.outDirs[index].oDirSync2))
              : null,
          oDirSync3: (positionWidth == 0)
              ? (addOutput('dir_sync_3_${index}_o')
                ..to(outputs.outDirs[index].oDirSync3))
              : null,
        );
      },
    );

    //==========================================================================
    // Logic Blocks
    //==========================================================================

    final logicBlockPorts = List.generate(
      numberOfElements,
      (index) => (
        // inputs
        en: addInternal(name: 'en_${index}_logic'),
        a: addInternal(name: 'a_${index}_logic'),
        b: addInternal(name: 'b_${index}_logic'),
        // outputs
        yComb: addInternal(name: 'y_comb_${index}_logic'),
        ySync: addInternal(name: 'y_sync_${index}_logic'),
      ),
    );
    for (var i = 0; i < logicBlockPorts.length; ++i) {
      final ports = logicBlockPorts[i];
      addSubmodule(
        LogicBlock(
          'logic_block_inst_$i',
          inputs: (
            clk: clk,
            rstN: rstN,
            iEn: ports.en,
            iA: ports.a,
            iB: ports.b,
          ),
          outputs: (
            oYComb: ports.yComb,
            oYSync: ports.ySync,
          ),
        ),
      );
    }

    //==========================================================================
    // Route Blocks
    //==========================================================================

    final routeBlockPorts = List.generate(
      numberOfElements,
      (index) => (
        // inputs
        inDirComb0: addInternal(name: 'in_dir_comb_0_${index}_route'),
        inDirComb1: addInternal(name: 'in_dir_comb_1_${index}_route'),
        inDirComb2: addInternal(name: 'in_dir_comb_2_${index}_route'),
        inDirComb3: addInternal(name: 'in_dir_comb_3_${index}_route'),
        inDirSync0: addInternal(name: 'in_dir_sync_0_${index}_route'),
        inDirSync1: addInternal(name: 'in_dir_sync_1_${index}_route'),
        inDirSync2: addInternal(name: 'in_dir_sync_2_${index}_route'),
        inDirSync3: addInternal(name: 'in_dir_sync_3_${index}_route'),
        yComb: addInternal(name: 'y_comb_${index}_route'),
        ySync: addInternal(name: 'y_sync_${index}_route'),
        tgtEn: addInternal(name: 'tgt_en_${index}_route', width: 3),
        tgtA: addInternal(name: 'tgt_a_${index}_route', width: 3),
        tgtB: addInternal(name: 'tgt_b_${index}_route', width: 3),
        tgtYComb: addInternal(name: 'tgt_y_comb_${index}_route', width: 4),
        tgtYSync: addInternal(name: 'tgt_y_sync_${index}_route', width: 4),
        // outputs
        outDirComb0: addInternal(name: 'out_dir_comb_0_${index}_route'),
        outDirComb1: addInternal(name: 'out_dir_comb_1_${index}_route'),
        outDirComb2: addInternal(name: 'out_dir_comb_2_${index}_route'),
        outDirComb3: addInternal(name: 'out_dir_comb_3_${index}_route'),
        outDirSync0: addInternal(name: 'out_dir_sync_0_${index}_route'),
        outDirSync1: addInternal(name: 'out_dir_sync_1_${index}_route'),
        outDirSync2: addInternal(name: 'out_dir_sync_2_${index}_route'),
        outDirSync3: addInternal(name: 'out_dir_sync_3_${index}_route'),
        en: addInternal(name: 'en_${index}_route'),
        a: addInternal(name: 'a_${index}_route'),
        b: addInternal(name: 'b_${index}_route'),
      ),
    );
    for (var i = 0; i < routeBlockPorts.length; ++i) {
      final ports = routeBlockPorts[i];
      addSubmodule(
        RouteBlock(
          'route_block_inst_$i',
          inputs: (
            iDirComb0: ports.inDirComb0,
            iDirComb1: ports.inDirComb1,
            iDirComb2: ports.inDirComb2,
            iDirComb3: ports.inDirComb3,
            iDirSync0: ports.inDirSync0,
            iDirSync1: ports.inDirSync1,
            iDirSync2: ports.inDirSync2,
            iDirSync3: ports.inDirSync3,
            iYComb: ports.yComb,
            iYSync: ports.ySync,
            iTgtEn: ports.tgtEn,
            iTgtA: ports.tgtA,
            iTgtB: ports.tgtB,
            iTgtYComb: ports.tgtYComb,
            iTgtYSync: ports.tgtYSync,
          ),
          outputs: (
            oDirComb0: ports.outDirComb0,
            oDirComb1: ports.outDirComb1,
            oDirComb2: ports.outDirComb2,
            oDirComb3: ports.outDirComb3,
            oDirSync0: ports.outDirSync0,
            oDirSync1: ports.outDirSync1,
            oDirSync2: ports.outDirSync2,
            oDirSync3: ports.outDirSync3,
            oEn: ports.en,
            oA: ports.a,
            oB: ports.b,
          ),
        ),
      );
    }

    if (logicBlockPorts.length != routeBlockPorts.length) {
      throw Exception();
    } else {
      for (var i = 0; i < logicBlockPorts.length; ++i) {
        final positionWidth = i % width;
        final positionHeight = i ~/ height;

        addCombinational([
          logicBlockPorts[i].en.assign(routeBlockPorts[i].en),
          logicBlockPorts[i].a.assign(routeBlockPorts[i].a),
          logicBlockPorts[i].b.assign(routeBlockPorts[i].b),
          routeBlockPorts[i].yComb.assign(logicBlockPorts[i].yComb),
          routeBlockPorts[i].ySync.assign(logicBlockPorts[i].ySync),
          if (positionHeight > 0)
            routeBlockPorts[i]
                .inDirComb0
                .assign(routeBlockPorts[i - width].outDirComb2),
          if (positionWidth < (width - 1))
            routeBlockPorts[i]
                .inDirComb1
                .assign(routeBlockPorts[i + 1].outDirComb3),
          if (positionHeight < (height - 1))
            routeBlockPorts[i]
                .inDirComb2
                .assign(routeBlockPorts[i + width].outDirComb0),
          if (positionWidth > 0)
            routeBlockPorts[i]
                .inDirComb3
                .assign(routeBlockPorts[i - 1].outDirComb1),
          if (positionHeight > 0)
            routeBlockPorts[i]
                .inDirSync0
                .assign(routeBlockPorts[i - width].outDirSync2),
          if (positionWidth < (width - 1))
            routeBlockPorts[i]
                .inDirSync1
                .assign(routeBlockPorts[i + 1].outDirSync3),
          if (positionHeight < (height - 1))
            routeBlockPorts[i]
                .inDirSync2
                .assign(routeBlockPorts[i + width].outDirSync0),
          if (positionWidth > 0)
            routeBlockPorts[i]
                .inDirSync3
                .assign(routeBlockPorts[i - 1].outDirSync1),
        ]);
      }
    }
  }

  final int width;
  final int height;
}
