import 'dart:math';
import 'package:svart/svart.dart';

class MemoryControllerUnit extends Module {
  MemoryControllerUnit(
    Var clock,
    Var enable,
    Var write,
    Var selectByte,
    Var address,
    Var inputData,
  ) : super(definitionName: 'memory_controller_unit') {
    clock = addInput('clock', clock);
    enable = addInput('enable', enable);
    write = addInput('write', write);
    selectByte = addInput('select_byte', selectByte);
    address = addInput('address', address, width: 16);
    inputData = addInput('input_data', inputData, width: 16);
    outputData = addOutput('output_data', width: 16);

    final memory = List.generate(pow(2, address.width).toInt(), (index) {
      return addInternal(name: 'memory_element_$index', width: 8);
    });

    final writeByteIffs = <Iff>[];
    final readByteIffs = <Iff>[];
    final writeHalfwordIffs = <Iff>[];
    final readHalfwordIffs = <Iff>[];
    for (var i = 0; i < memory.length; ++i) {
      writeByteIffs.add(
        Iff(
          address.eq(Const(i, width: address.width)),
          then: [memory[i].assign(inputData.part(7, 0))],
        ),
      );
      readByteIffs.add(
        Iff(
          address.eq(Const(i, width: address.width)),
          then: [outputData.assign(outputData.part(15, 8).cat(memory[i]))],
        ),
      );
      writeHalfwordIffs.add(
        Iff(
          address.eq(Const(i, width: address.width)),
          then: [
            if (i.isEven) ...[
              memory[i].assign(inputData.part(7, 0)),
              memory[i + 1].assign(inputData.part(15, 8))
            ] else
              // The write operation must respect memory alignment.
              Assert(address.neq(Const(i, width: address.width)))
          ],
        ),
      );
      readHalfwordIffs.add(
        Iff(
          address.eq(Const(i, width: address.width)),
          then: [
            if (i.isEven)
              outputData.assign(memory[i + 1].cat(memory[i]))
            else
              // The read operation must respect memory alignment.
              Assert(address.neq(Const(i, width: address.width)))
          ],
        ),
      );
    }

    addSyncSequential(PosEdge(clock), [
      If(
        enable,
        then: [
          If(
            write,
            then: [
              If(
                selectByte,
                then: [When(writeByteIffs)],
                orElse: [When(writeHalfwordIffs)],
              )
            ],
            orElse: [
              If(
                selectByte,
                then: [When(readByteIffs)],
                orElse: [When(readHalfwordIffs)],
              )
            ],
          )
        ],
      )
    ]);
  }

  late final Var outputData;
}
