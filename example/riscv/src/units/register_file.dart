import 'dart:math';
import 'package:svart/svart.dart';

class RegisterFileUnit extends Module {
  RegisterFileUnit(
    Var clock,
    Var write,
    Var addressA,
    Var addressB,
    Var addressC,
    Var inputDataA,
  ) : super(
          definitionName: 'register_file_unit',
          instanceName: 'register_file_unit_instance',
        ) {
    clock = addInput('clock', clock);
    write = addInput('write', write);
    addressA = addInput('address_a', addressA, width: 5);
    addressB = addInput('address_b', addressB, width: 5);
    addressC = addInput('address_c', addressC, width: 5);
    inputDataA = addInput('input_data_a', inputDataA, width: 32);
    outputDataB = addOutput('output_data_b', width: 32);
    outputDataC = addOutput('output_data_c', width: 32);

    final registers = List.generate(pow(2, 5).toInt(), (index) {
      return addInternal(name: 'register_$index', width: 32);
    });

    final readBIffs = <Iff>[];
    final readCIffs = <Iff>[];
    final writeAIffs = <Iff>[];
    for (var i = 0; i < registers.length; ++i) {
      readBIffs.add(
        Iff(
          addressB.eq(Const(i, width: addressB.width)),
          then: [outputDataB.assign(registers[i])],
        ),
      );
      readCIffs.add(
        Iff(
          addressC.eq(Const(i, width: addressC.width)),
          then: [outputDataC.assign(registers[i])],
        ),
      );
      if (i != 0) {
        writeAIffs.add(
          Iff(
            addressA.eq(Const(i, width: addressA.width)),
            then: [registers[i].assign(inputDataA)],
          ),
        );
      }
    }

    addCombinational(
      [registers[0].assign(Const(0, width: registers[0].width))],
    );

    addCombinational([When(readBIffs)]);

    addCombinational([When(readCIffs)]);

    addSyncSequential(PosEdge(clock), [
      If(write, then: [When(writeAIffs)]),
    ]);
  }

  late final Var outputDataB;
  late final Var outputDataC;
}
