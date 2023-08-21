import 'dart:math';
import 'package:svart/svart.dart';

class MemoryUnit extends Module {
  MemoryUnit(
    Var clock,
    Var write,
    Var selectByte,
    Var address,
    Var inputData, {
    int actualAddressSpace = 16,
    super.instanceName,
  }) : super(definitionName: 'memory_unit') {
    clock = addInput('clock', clock);
    write = addInput('write', write);
    selectByte = addInput('select_byte', selectByte);
    address = addInput('address', address, width: 16);
    inputData = addInput('input_data', inputData, width: 16);
    outputData = addOutput('output_data', width: 16);

    final memory = List.generate(pow(2, actualAddressSpace).toInt(), (index) {
      return addInternal(name: 'memo_$index', width: 8);
    });

    final readIffs = <Iff>[];
    final writeIffs = <Iff>[];
    for (var i = 0; i < memory.length; i += 2) {
      readIffs.add(
        Iff(
          address.part(15, 1).eq(Const(i, width: address.width).part(15, 1)),
          then: [outputData.assign(memory[i + 1].cat(memory[i]))],
        ),
      );
      writeIffs.add(
        Iff(
          address.part(15, 1).eq(Const(i, width: address.width).part(15, 1)),
          then: [
            If(
              selectByte,
              then: [
                If(
                  address.part(0, 0).eq(Const(0)),
                  then: [memory[i].assign(inputData.part(7, 0))],
                  orElse: [memory[i + 1].assign(inputData.part(7, 0))],
                ),
              ],
              orElse: [
                memory[i].assign(inputData.part(7, 0)),
                memory[i + 1].assign(inputData.part(15, 8)),
              ],
            ),
          ],
        ),
      );
    }

    if (actualAddressSpace == 3) {
      addInitial([
        // asm: lit 254
        memory[0].assign(Const(1, width: 8)),
        memory[1].assign(Const(254, width: 8)),
        // asm: rf.r0 lit
        memory[2].assign(Const(128 + 0, width: 8)),
        memory[3].assign(Const(1, width: 8)),
        // asm: lit 1
        memory[4].assign(Const(1, width: 8)),
        memory[5].assign(Const(1, width: 8)),
        // asm: rf.r1 lit
        memory[6].assign(Const(128 + 1, width: 8)),
        memory[7].assign(Const(1, width: 8)),
      ]);
    } else {
      addInitial([
        // asm: lit 254
        memory[0].assign(Const(1, width: 8)),
        memory[1].assign(Const(254, width: 8)),
        // asm: rf.r0 lit
        memory[2].assign(Const(128 + 0, width: 8)),
        memory[3].assign(Const(1, width: 8)),
        // asm: lit 1
        memory[4].assign(Const(1, width: 8)),
        memory[5].assign(Const(1, width: 8)),
        // asm: rf.r1 lit
        memory[6].assign(Const(128 + 1, width: 8)),
        memory[7].assign(Const(1, width: 8)),
        // asm: lit 11
        memory[8].assign(Const(1, width: 8)),
        memory[9].assign(Const(11, width: 8)),
        // asm: rf.r2 lit
        memory[10].assign(Const(128 + 2, width: 8)),
        memory[11].assign(Const(1, width: 8)),
        // asm: alu.operand.a rf.r0
        memory[12].assign(Const(11, width: 8)),
        memory[13].assign(Const(128 + 0, width: 8)),
        // asm: alu.operand.b rf.r1
        memory[14].assign(Const(12, width: 8)),
        memory[15].assign(Const(128 + 1, width: 8)),
        // asm: alu.op rf.r2
        memory[16].assign(Const(14, width: 8)),
        memory[17].assign(Const(128 + 2, width: 8)),
        // asm: rf.r3 alu.result
        memory[18].assign(Const(128 + 3, width: 8)),
        memory[19].assign(Const(13, width: 8)),
        // asm: aux.nop
        memory[20].assign(Const(0, width: 8)),
        memory[21].assign(Const(1, width: 8)),
      ]);
    }

    addCombinational([When(readIffs)]);

    addSyncSequential(PosEdge(clock), [
      If(write, then: [When(writeIffs)]),
    ]);
  }

  late final Var outputData;
}

String main({bool noPrint = false}) {
  final systemverilog = MemoryUnit(
    Var(),
    Var(),
    Var(),
    Var(width: 16),
    Var(width: 16),
    actualAddressSpace: 3,
  ).emit();

  if (!noPrint) {
    // ignore: avoid_print
    print(systemverilog);
  }

  return systemverilog;
}
