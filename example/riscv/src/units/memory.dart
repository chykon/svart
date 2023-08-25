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

    addCombinational([When(readIffs)]);

    addSyncSequential(PosEdge(clock), [
      If(write, then: [When(writeIffs)]),
    ]);
  }

  late final Var outputData;
}
