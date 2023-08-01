import 'dart:math';
import 'package:svart/svart.dart';

class MemoryUnit extends Module {
  MemoryUnit(
    Var clock,
    Var write,
    Var selectByte,
    Var address,
    Var inputData,
  ) : super(definitionName: 'memory_unit') {
    clock = addInput('clock', clock);
    write = addInput('write', write);
    selectByte = addInput('select_byte', selectByte);
    address = addInput('address', address, width: 16);
    inputData = addInput('input_data', inputData, width: 16);
    outputData = addOutput('output_data', width: 16);

    final memory = List.generate(pow(2, address.width).toInt(), (index) {
      return addInternal(name: 'memory_element_$index', width: 8);
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
                )
              ],
              orElse: [
                // Memory alignment must be considered when writing.
                Assert(address.part(0, 0).eq(Const(0))),
                memory[i].assign(inputData.part(7, 0)),
                memory[i + 1].assign(inputData.part(15, 8))
              ],
            )
          ],
        ),
      );
    }

    addCombinational([When(readIffs)]);

    addSyncSequential(PosEdge(clock), [
      If(write, then: [When(writeIffs)])
    ]);
  }

  late final Var outputData;
}
