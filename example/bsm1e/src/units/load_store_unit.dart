import 'package:svart/svart.dart';

class LoadStoreUnit extends Module {
  LoadStoreUnit(
    Var clock,
    Var act,
    Var data,
    Var resetMemoryAccess,
    Var memoryData, {
    super.instanceName,
  }) : super(definitionName: 'load_store_unit') {
    clock = addInput('clock', clock);
    act = addInput('act', act, width: 3);
    data = addInput('data', data, width: 8);
    resetMemoryAccess = addInput('reset_memory_access', resetMemoryAccess);
    memoryData = addInput('memory_data', memoryData, width: 16);
    memoryAccess = (
      load: (
        byte: addOutput('memory_access_load_byte'),
        halfword: addOutput('memory_access_load_halfword')
      ),
      store: (
        byte: addOutput('memory_access_store_byte'),
        halfword: addOutput('memory_access_store_halfword')
      )
    );
    targetAddress = addOutput('target_address', width: 16);
    targetData = addOutput('target_data', width: 16);

    final op = addInternal(name: 'op', width: 2);

    addCombinational([op.assign(data.part(1, 0))]);

    addSyncSequential(PosEdge(clock), [
      If(
        resetMemoryAccess,
        then: [
          memoryAccess.load.byte.assign(Const(0)),
          memoryAccess.load.halfword.assign(Const(0)),
          memoryAccess.store.byte.assign(Const(0)),
          memoryAccess.store.halfword.assign(Const(0))
        ],
        orElse: [targetData.assign(memoryData)],
      ),
      If(
        act.neq(Const(actcode.none, width: act.width)),
        then: [
          When(
            [
              Iff(
                act.eq(Const(actcode.setAddress.lowByte, width: act.width)),
                then: [
                  targetAddress.assign(targetAddress.part(15, 8).cat(data))
                ],
              ),
              Iff(
                act.eq(Const(actcode.setAddress.highByte, width: act.width)),
                then: [
                  targetAddress.assign(data.cat(targetAddress.part(7, 0)))
                ],
              ),
              Iff(
                act.eq(Const(actcode.setData.lowByte, width: act.width)),
                then: [targetData.assign(targetData.part(15, 8).cat(data))],
              ),
              Iff(
                act.eq(Const(actcode.setData.highByte, width: act.width)),
                then: [targetData.assign(data.cat(targetData.part(7, 0)))],
              ),
              Iff(
                act.eq(Const(actcode.operate, width: act.width)),
                then: [
                  When([
                    Iff(
                      op.eq(Const(opcode.load.byte, width: op.width)),
                      then: [
                        memoryAccess.load.byte.assign(Const(1)),
                        targetData.assign(
                          targetData.part(15, 8).cat(memoryData.part(7, 0)),
                        )
                      ],
                    ),
                    Iff(
                      op.eq(Const(opcode.load.halfword, width: op.width)),
                      then: [
                        memoryAccess.load.halfword.assign(Const(1)),
                        targetData.assign(memoryData)
                      ],
                    ),
                    Iff(
                      op.eq(Const(opcode.store.byte, width: op.width)),
                      then: [memoryAccess.store.byte.assign(Const(1))],
                    ),
                    Iff(
                      op.eq(Const(opcode.store.halfword, width: op.width)),
                      then: [memoryAccess.store.halfword.assign(Const(1))],
                    )
                  ])
                ],
              )
            ],
            orElse: [
              // `Act` must be in a certain range.
              Assert(act.lte(Const(actcode.operate, width: act.width)))
            ],
          )
        ],
      )
    ]);
  }

  late final ({
    ({Var byte, Var halfword}) load,
    ({Var byte, Var halfword}) store
  }) memoryAccess;
  late final Var targetAddress;
  late final Var targetData;

  static const actcode = (
    none: 0,
    setAddress: (lowByte: 1, highByte: 2),
    setData: (lowByte: 3, highByte: 4),
    operate: 5
  );

  static const opcode = (
    load: (byte: 0, halfword: 1),
    store: (byte: 2, halfword: 3),
  );
}
