import 'dart:math';
import 'package:svart/svart.dart';

class InstructionDecodeUnit extends Module {
  InstructionDecodeUnit(
    Var decode,
    Var instruction,
  ) : super(
          definitionName: 'instruction_decode_unit',
          instanceName: 'instruction_decode_unit_instance',
        ) {
    decode = addInput('decode', decode);
    instruction = addInput('instruction', instruction, width: 32);
    illegalInstruction = addOutput('illegal_instruction');

    final format = addInternal(name: 'format', width: 5);
    final payload = addInternal(name: 'payload', width: 27);
    final firstParcel = addInternal(name: 'first_parcel', width: 16);

    addCombinational([format.assign(instruction.part(4, 0))]);

    addCombinational([payload.assign(instruction.part(31, 5))]);

    addCombinational([firstParcel.assign(instruction.part(15, 0))]);

    addCombinational([
      illegalInstruction.assign(Const(0)),
      If(
        decode,
        then: [
          If(
            // Illegal instruction - bits [15:0] all zeros.
            firstParcel
                .eq(Const(0, width: firstParcel.width))
                // Illegal instruction - all bits are 1.
                .or(
                  instruction.eq(
                    Const(
                      pow(2, instruction.width).toInt() - 1,
                      width: instruction.width,
                    ),
                  ),
                )
                // Illegal instruction - incorrect encoding.
                .or(format.eq(Const(31, width: format.width))),
            then: [illegalInstruction.assign(Const(1))],
            orElse: [
              // ...
            ],
          ),
        ],
      ),
    ]);
  }

  late final Var illegalInstruction;
}
