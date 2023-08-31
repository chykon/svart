import 'dart:math';
import 'package:svart/svart.dart';

class InstructionDecodeUnit extends Module {
  InstructionDecodeUnit(
    Var instruction,
  ) : super(
          definitionName: 'instruction_decode_unit',
          instanceName: 'instruction_decode_unit_instance',
        ) {
    instruction = addInput('instruction', instruction, width: 32);
    illegalInstruction = addOutput('illegal_instruction');

    opcode = addOutput('opcode', width: 7);
    addCombinational([opcode.assign(instruction.part(6, 0))]);
    rd = addOutput('rd', width: 5);
    addCombinational([rd.assign(instruction.part(11, 7))]);
    funct3 = addOutput('funct3', width: 3);
    addCombinational([funct3.assign(instruction.part(14, 12))]);
    rs1 = addOutput('rs1', width: 5);
    addCombinational([rs1.assign(instruction.part(19, 15))]);
    rs2 = addOutput('rs2', width: 5);
    addCombinational([rs2.assign(instruction.part(24, 20))]);
    funct7 = addOutput('funct7', width: 7);
    addCombinational([funct7.assign(instruction.part(31, 25))]);

    final imm_4_0 = addInternal(name: 'imm_4_0', width: 5);
    addCombinational([imm_4_0.assign(instruction.part(11, 7))]);
    final imm_4_1 = addInternal(name: 'imm_4_1', width: 4);
    addCombinational([imm_4_1.assign(instruction.part(11, 8))]);
    final imm_10_1 = addInternal(name: 'imm_10_1', width: 10);
    addCombinational([imm_10_1.assign(instruction.part(30, 21))]);
    final imm_10_5 = addInternal(name: 'imm_10_5', width: 6);
    addCombinational([imm_10_5.assign(instruction.part(30, 25))]);
    final imm_11_0 = addInternal(name: 'imm_11_0', width: 12);
    addCombinational([imm_11_0.assign(instruction.part(31, 20))]);
    final imm_11_5 = addInternal(name: 'imm_11_5', width: 7);
    addCombinational([imm_11_5.assign(instruction.part(31, 25))]);
    final imm_11 = addInternal(name: 'imm_11');
    addCombinational([imm_11.assign(instruction.part(7, 7))]);
    final imm_12 = addInternal(name: 'imm_12');
    addCombinational([imm_12.assign(instruction.part(31, 31))]);
    final imm_19_12 = addInternal(name: 'imm_19_12', width: 8);
    addCombinational([imm_19_12.assign(instruction.part(19, 12))]);
    final imm_20 = addInternal(name: 'imm_20');
    addCombinational([imm_20.assign(instruction.part(31, 31))]);
    final imm_31_12 = addInternal(name: 'imm_31_12', width: 20);
    addCombinational([imm_31_12.assign(instruction.part(31, 12))]);

    immI = addOutput('imm_i', width: 32);
    addCombinational(
      [
        immI.assign(Const(0, width: 20).cat(imm_11_0)),
        If(
          instruction.part(31, 31).eq(Const(1)),
          then: [
            immI.assign(
              Const(pow(2, 20).toInt() - 1, width: 20).cat(immI.part(11, 0)),
            ),
          ],
        ),
      ],
    );
    immS = addOutput('imm_s', width: 32);
    addCombinational(
      [
        immS.assign(Const(0, width: 20).cat(imm_11_5).cat(imm_4_0)),
        If(
          instruction.part(31, 31).eq(Const(1)),
          then: [
            immS.assign(
              Const(pow(2, 20).toInt() - 1, width: 20).cat(immS.part(11, 0)),
            ),
          ],
        ),
      ],
    );
    immB = addOutput('imm_b', width: 32);
    addCombinational(
      [
        immB.assign(
          Const(0, width: 19)
              .cat(imm_12)
              .cat(imm_11)
              .cat(imm_10_5)
              .cat(imm_4_1)
              .cat(Const(0)),
        ),
        If(
          instruction.part(31, 31).eq(Const(1)),
          then: [
            immB.assign(
              Const(pow(2, 19).toInt() - 1, width: 19).cat(immB.part(12, 0)),
            ),
          ],
        ),
      ],
    );
    immU = addOutput('imm_u', width: 32);
    addCombinational(
      [immU.assign(imm_31_12.cat(Const(0, width: 12)))],
    );
    immJ = addOutput('imm_j', width: 32);
    addCombinational(
      [
        immJ.assign(
          Const(0, width: 11)
              .cat(imm_20)
              .cat(imm_19_12)
              .cat(imm_11)
              .cat(imm_10_1)
              .cat(Const(0)),
        ),
        If(
          instruction.part(31, 31).eq(Const(1)),
          then: [
            immJ.assign(
              Const(pow(2, 11).toInt() - 1, width: 11).cat(immJ.part(20, 0)),
            ),
          ],
        ),
      ],
    );

    addCombinational([
      If(
        // Illegal instruction - bits [15:0] all zeros.
        instruction
            .part(15, 0)
            .eq(Const(0, width: 16))
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
            .or(
              instruction
                  .part(4, 0)
                  .eq(Const(int.parse('11111', radix: 2), width: 5)),
            ),
        then: [illegalInstruction.assign(Const(1))],
        orElse: [illegalInstruction.assign(Const(0))],
      ),
    ]);
  }

  late final Var illegalInstruction;

  late final Var opcode;
  late final Var rd;
  late final Var funct3;
  late final Var rs1;
  late final Var rs2;
  late final Var funct7;

  late final Var immI;
  late final Var immS;
  late final Var immB;
  late final Var immU;
  late final Var immJ;
}
