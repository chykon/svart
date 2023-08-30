import 'dart:math';
import 'package:svart/svart.dart';

class MemoryUnit extends Module {
  MemoryUnit(
    Var clock,
    Var write,
    Var address,
    Var inputData,
  ) : super(
          definitionName: 'memory_unit',
          instanceName: 'memory_unit_instance',
        ) {
    clock = addInput('clock', clock);
    write = addInput('write', write);
    // Word addressing is used.
    address = addInput('address', address, width: 30);
    inputData = addInput('input_data', inputData, width: 32);
    outputData = addOutput('output_data', width: 32);

    // Currently, the `svart` package only allows for a very inefficient
    // way to "manually" generate memory. At the moment, the "real" size
    // of the address space is reduced, which allows you to simulate the
    // operation of the circuit.
    final memory = List.generate(pow(2, address.width - 20).toInt(), (index) {
      return addInternal(name: 'memory_word_$index', width: 32);
    });

    final readIffs = <Iff>[];
    final writeIffs = <Iff>[];
    for (var i = 0; i < memory.length; ++i) {
      readIffs.add(
        Iff(
          address.eq(Const(i, width: address.width)),
          then: [outputData.assign(memory[i])],
        ),
      );
      writeIffs.add(
        Iff(
          address.eq(Const(i, width: address.width)),
          then: [memory[i].assign(inputData)],
        ),
      );
    }

    addInitial([
      /*
        int i = 0;
        int shift = 1;
        int memStart = 512;
        while (i != 8) {
          mem[memStart + i] = shift << i;
          ++i;
        }
      */
      // addi x1, x1, 0
      memory[0].assign(
        Const(
          int.parse('00000000000000001000000010010011', radix: 2),
          width: 32,
        ),
      ),
      // addi x10, x10, 8
      memory[1].assign(
        Const(
          int.parse('00000000100001010000010100010011', radix: 2),
          width: 32,
        ),
      ),
      // addi x2, x2, 1
      memory[2].assign(
        Const(
          int.parse('00000000000100010000000100010011', radix: 2),
          width: 32,
        ),
      ),
      // addi x3, x3, 512
      memory[3].assign(
        Const(
          int.parse('00100000000000011000000110010011', radix: 2),
          width: 32,
        ),
      ),
      // add x4, x3, x1
      memory[4].assign(
        Const(
          int.parse('00000000000100011000001000110011', radix: 2),
          width: 32,
        ),
      ),
      // sll x5, x2, x1
      memory[5].assign(
        Const(
          int.parse('00000000000100010001001010110011', radix: 2),
          width: 32,
        ),
      ),
      // sb x4, x5, 0
      memory[6].assign(
        Const(
          int.parse('00000000010100100000000000100011', radix: 2),
          width: 32,
        ),
      ),
      // addi x1, x1, 1
      memory[7].assign(
        Const(
          int.parse('00000000000100001000000010010011', radix: 2),
          width: 32,
        ),
      ),
      // bne x1, x10, -16
      memory[8].assign(
        Const(
          int.parse('11111110101000001001100011100011', radix: 2),
          width: 32,
        ),
      ),
      // illegal instruction
      memory[9].assign(
        Const(
          int.parse('00000000000000000000000000000000', radix: 2),
          width: 32,
        ),
      ),
    ]);

    addCombinational([When(readIffs)]);

    addSyncSequential(PosEdge(clock), [
      If(write, then: [When(writeIffs)]),
    ]);
  }

  late final Var outputData;
}
