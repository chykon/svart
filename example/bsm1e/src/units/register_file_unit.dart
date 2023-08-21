import 'dart:math';
import 'package:svart/svart.dart';

class RegisterFileUnit extends Module {
  RegisterFileUnit(
    Var clock,
    Var write,
    Var address,
    Var inputData, {
    int actualRegisterAddressSpace = 7,
    super.instanceName,
  }) : super(definitionName: 'register_file_unit') {
    clock = addInput('clock', clock);
    write = addInput('write', write);
    address = addInput('address', address, width: 7);
    inputData = addInput('input_data', inputData, width: 8);
    outputData = addOutput('output_data', width: 8);

    final registers =
        List.generate(pow(2, actualRegisterAddressSpace).toInt(), (index) {
      return addInternal(name: 'register_$index', width: 8);
    });

    final readIffs = <Iff>[];
    final writeIffs = <Iff>[];
    for (var i = 0; i < registers.length; ++i) {
      readIffs.add(
        Iff(
          address.eq(Const(i, width: address.width)),
          then: [outputData.assign(registers[i])],
        ),
      );
      writeIffs.add(
        Iff(
          address.eq(Const(i, width: address.width)),
          then: [registers[i].assign(inputData)],
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

String main({bool noPrint = false}) {
  final systemverilog = RegisterFileUnit(
    Var(),
    Var(),
    Var(width: 7),
    Var(width: 8),
    actualRegisterAddressSpace: 3,
  ).emit();

  if (!noPrint) {
    // ignore: avoid_print
    print(systemverilog);
  }

  return systemverilog;
}
