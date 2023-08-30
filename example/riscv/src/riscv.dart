import 'package:svart/svart.dart';

import 'units/arithmetic_logic.dart';
import 'units/control_flow.dart';
import 'units/instruction_decode.dart';
import 'units/instruction_fetch.dart';
import 'units/load_store.dart';
import 'units/memory.dart';
import 'units/register_file.dart';

class RISCV extends Module {
  RISCV(
    Var clock,
    Var reset,
  ) : super(definitionName: 'riscv', instanceName: 'riscv_instance') {
    clock = addInput('clock', clock);
    reset = addInput('reset', reset);

    final aluOperation = addInternal(name: 'alu_operation', width: 4);
    final aluOperandA = addInternal(name: 'alu_operand_a', width: 32);
    final aluOperandB = addInternal(name: 'alu_operand_b', width: 32);
    final aluResult = addInternal(name: 'alu_result', width: 32);
    addSubmodule(
      ArithmeticLogicUnit(aluOperation, aluOperandA, aluOperandB)
        ..result.to(aluResult),
    );

    final cfuOperation = addInternal(name: 'cfu_operation', width: 3);
    final cfuRs1 = addInternal(name: 'cfu_rs1', width: 32);
    final cfuRs2 = addInternal(name: 'cfu_rs2', width: 32);
    final cfuBranch = addInternal(name: 'cfu_branch');
    addSubmodule(
      ControlFlowUnit(cfuOperation, cfuRs1, cfuRs2)..branch.to(cfuBranch),
    );

    final iduInstruction = addInternal(name: 'idu_instruction', width: 32);
    final iduIllegalInstruction = addInternal(name: 'idu_illegal_instruction');
    final iduOpcode = addInternal(name: 'idu_opcode', width: 7);
    final iduRd = addInternal(name: 'idu_rd', width: 5);
    final iduFunct3 = addInternal(name: 'idu_funct3', width: 3);
    final iduRs1 = addInternal(name: 'idu_rs1', width: 5);
    final iduRs2 = addInternal(name: 'idu_rs2', width: 5);
    final iduFunct7 = addInternal(name: 'idu_funct7', width: 7);
    final iduImmI = addInternal(name: 'idu_imm_i', width: 32);
    final iduImmS = addInternal(name: 'idu_imm_s', width: 32);
    final iduImmB = addInternal(name: 'idu_imm_b', width: 32);
    final iduImmU = addInternal(name: 'idu_imm_u', width: 32);
    final iduImmJ = addInternal(name: 'idu_imm_j', width: 32);
    addSubmodule(
      InstructionDecodeUnit(iduInstruction)
        ..illegalInstruction.to(iduIllegalInstruction)
        ..opcode.to(iduOpcode)
        ..rd.to(iduRd)
        ..funct3.to(iduFunct3)
        ..rs1.to(iduRs1)
        ..rs2.to(iduRs2)
        ..funct7.to(iduFunct7)
        ..immI.to(iduImmI)
        ..immS.to(iduImmS)
        ..immB.to(iduImmB)
        ..immU.to(iduImmU)
        ..immJ.to(iduImmJ),
    );

    final ifuJump = addInternal(name: 'ifu_jump');
    final ifuJumpAddress = addInternal(name: 'ifu_jump_address', width: 30);
    final ifuNext = addInternal(name: 'ifu_next');
    final ifuCurrentAddress =
        addInternal(name: 'ifu_current_address', width: 30);
    addSubmodule(
      InstructionFetchUnit(clock, ifuJump, ifuJumpAddress, ifuNext)
        ..currentAddress.to(ifuCurrentAddress),
    );

    final lsuOperation = addInternal(name: 'lsu_operation', width: 4);
    final lsuLowAddress = addInternal(name: 'lsu_low_address', width: 2);
    final lsuMemData = addInternal(name: 'lsu_mem_data', width: 32);
    final lsuRegData = addInternal(name: 'lsu_reg_data', width: 32);
    final lsuOutputData = addInternal(name: 'lsu_output_data', width: 32);
    final lsuAddressMisaligned = addInternal(name: 'lsu_address_misaligned');
    addSubmodule(
      LoadStoreUnit(lsuOperation, lsuLowAddress, lsuMemData, lsuRegData)
        ..outputData.to(lsuOutputData)
        ..addressMisaligned.to(lsuAddressMisaligned),
    );

    final muWrite = addInternal(name: 'mu_write');
    final muAddress = addInternal(name: 'mu_address', width: 30);
    final muInputData = addInternal(name: 'mu_input_data', width: 32);
    final muOutputData = addInternal(name: 'mu_output_data', width: 32);
    addSubmodule(
      MemoryUnit(clock, muWrite, muAddress, muInputData)
        ..outputData.to(muOutputData),
    );

    final rfuWrite = addInternal(name: 'rfu_write');
    final rfuAddressA = addInternal(name: 'rfu_address_a', width: 5);
    final rfuAddressB = addInternal(name: 'rfu_address_b', width: 5);
    final rfuAddressC = addInternal(name: 'rfu_address_c', width: 5);
    final rfuInputDataA = addInternal(name: 'rfu_input_data_a', width: 32);
    final rfuOutputDataB = addInternal(name: 'rfu_output_data_b', width: 32);
    final rfuOutputDataC = addInternal(name: 'rfu_output_data_c', width: 32);
    addSubmodule(
      RegisterFileUnit(
        clock,
        rfuWrite,
        rfuAddressA,
        rfuAddressB,
        rfuAddressC,
        rfuInputDataA,
      )
        ..outputDataB.to(rfuOutputDataB)
        ..outputDataC.to(rfuOutputDataC),
    );

    final instructionBuffer =
        addInternal(name: 'instruction_buffer', width: 32);

    addSyncSequential(
      PosEdge(clock),
      [instructionBuffer.assign(iduInstruction)],
    );

    final currentState = addInternal(name: 'current_state', width: 2);
    final nextState = addInternal(name: 'next_state', width: 2);

    addCombinational([
      nextState.assign(currentState),
      ifuJump.assign(Const(0)),
      ifuNext.assign(Const(0)),
      muWrite.assign(Const(0)),
      rfuWrite.assign(Const(0)),
      When(
        [
          Iff(
            nextState.eq(Const(_state.initial, width: nextState.width)),
            then: [
              ifuJumpAddress.assign(Const(0, width: 30)),
              ifuJump.assign(Const(1)),
              nextState.assign(Const(_state.main, width: nextState.width)),
            ],
          ),
          Iff(
            nextState.eq(Const(_state.main, width: nextState.width)),
            then: [
              muAddress.assign(ifuCurrentAddress),
              iduInstruction.assign(muOutputData),
              If(
                iduIllegalInstruction,
                then: [
                  nextState.assign(
                    Const(_state.illegalInstruction, width: nextState.width),
                  ),
                ],
                orElse: [
                  When(
                    [
                      Iff(
                        iduOpcode
                            .eq(Const(_opcode.opImm, width: iduOpcode.width)),
                        then: [
                          If(
                            iduFunct3
                                .eq(
                                  Const(
                                    int.parse('001', radix: 2),
                                    width: iduFunct3.width,
                                  ),
                                )
                                .or(
                                  iduFunct3.eq(
                                    Const(
                                      int.parse('101', radix: 2),
                                      width: iduFunct3.width,
                                    ),
                                  ),
                                ),
                            then: [
                              If(
                                iduFunct3.eq(
                                  Const(
                                    int.parse('101', radix: 2),
                                    width: iduFunct3.width,
                                  ),
                                ),
                                then: [
                                  rfuAddressB.assign(iduRs1),
                                  aluOperandA.assign(rfuOutputDataB),
                                  aluOperandB.assign(
                                    Const(0, width: 27).cat(iduImmI.part(4, 0)),
                                  ),
                                  aluOperation.assign(
                                    iduImmI.part(10, 10).cat(iduFunct3),
                                  ),
                                  rfuAddressA.assign(iduRd),
                                  rfuInputDataA.assign(aluResult),
                                  rfuWrite.assign(Const(1)),
                                ],
                                orElse: [
                                  rfuAddressB.assign(iduRs1),
                                  aluOperandA.assign(rfuOutputDataB),
                                  aluOperandB.assign(
                                    Const(0, width: 27).cat(iduImmI.part(4, 0)),
                                  ),
                                  aluOperation.assign(
                                    iduImmI.part(10, 10).cat(iduFunct3),
                                  ),
                                  rfuAddressA.assign(iduRd),
                                  rfuInputDataA.assign(aluResult),
                                  rfuWrite.assign(Const(1)),
                                ],
                              ),
                            ],
                            orElse: [
                              rfuAddressB.assign(iduRs1),
                              aluOperandA.assign(rfuOutputDataB),
                              aluOperandB.assign(iduImmI),
                              aluOperation.assign(Const(0).cat(iduFunct3)),
                              rfuAddressA.assign(iduRd),
                              rfuInputDataA.assign(aluResult),
                              rfuWrite.assign(Const(1)),
                            ],
                          ),
                        ],
                      ),
                      Iff(
                        iduOpcode
                            .eq(Const(_opcode.lui, width: iduOpcode.width)),
                        then: [
                          rfuAddressA.assign(iduRd),
                          rfuInputDataA.assign(iduImmU),
                          rfuWrite.assign(Const(1)),
                        ],
                      ),
                      Iff(
                        iduOpcode
                            .eq(Const(_opcode.auipc, width: iduOpcode.width)),
                        then: [
                          rfuAddressA.assign(iduRd),
                          rfuInputDataA.assign(
                            iduImmU
                                .add(ifuCurrentAddress.cat(Const(0, width: 2))),
                          ),
                          rfuWrite.assign(Const(1)),
                        ],
                      ),
                      Iff(
                        iduOpcode.eq(Const(_opcode.op, width: iduOpcode.width)),
                        then: [
                          rfuAddressB.assign(iduRs1),
                          aluOperandA.assign(rfuOutputDataB),
                          rfuAddressC.assign(iduRs2),
                          aluOperandB.assign(rfuOutputDataC),
                          aluOperation
                              .assign(iduFunct7.part(6, 6).cat(iduFunct3)),
                          rfuAddressA.assign(iduRd),
                          rfuInputDataA.assign(aluResult),
                          rfuWrite.assign(Const(1)),
                        ],
                      ),
                      Iff(
                        iduOpcode
                            .eq(Const(_opcode.jal, width: iduOpcode.width)),
                        then: [
                          ifuJumpAddress.assign(
                            iduImmJ
                                .add(ifuCurrentAddress.cat(Const(0, width: 2)))
                                .part(31, 2),
                          ),
                          ifuJump.assign(Const(1)),
                          rfuAddressA.assign(iduRd),
                          rfuInputDataA.assign(
                            ifuCurrentAddress
                                .add(Const(1, width: ifuCurrentAddress.width))
                                .cat(Const(0, width: 2)),
                          ),
                          rfuWrite.assign(Const(1)),
                        ],
                      ),
                      Iff(
                        iduOpcode
                            .eq(Const(_opcode.jalr, width: iduOpcode.width)),
                        then: [
                          rfuAddressB.assign(iduRs1),
                          ifuJumpAddress.assign(
                            iduImmJ
                                .add(
                                  iduImmI
                                      .add(rfuOutputDataB)
                                      .part(31, 1)
                                      .cat(Const(0)),
                                )
                                .part(31, 2),
                          ),
                          ifuJump.assign(Const(1)),
                          rfuAddressA.assign(iduRd),
                          rfuInputDataA.assign(
                            ifuCurrentAddress
                                .add(Const(1, width: ifuCurrentAddress.width))
                                .cat(Const(0, width: 2)),
                          ),
                          rfuWrite.assign(Const(1)),
                        ],
                      ),
                      Iff(
                        iduOpcode
                            .eq(Const(_opcode.branch, width: iduOpcode.width)),
                        then: [
                          rfuAddressB.assign(iduRs1),
                          rfuAddressC.assign(iduRs2),
                          cfuRs1.assign(rfuOutputDataB),
                          cfuRs2.assign(rfuOutputDataC),
                          cfuOperation.assign(iduFunct3),
                          If(
                            cfuBranch,
                            then: [
                              ifuJumpAddress.assign(
                                iduImmB
                                    .add(
                                      ifuCurrentAddress.cat(Const(0, width: 2)),
                                    )
                                    .part(31, 2),
                              ),
                              ifuJump.assign(Const(1)),
                            ],
                          ),
                        ],
                      ),
                      Iff(
                        iduOpcode
                            .eq(Const(_opcode.load, width: iduOpcode.width))
                            .or(
                              iduOpcode.eq(
                                Const(_opcode.store, width: iduOpcode.width),
                              ),
                            ),
                        then: [
                          nextState.assign(
                            Const(_state.memoryAccess, width: nextState.width),
                          ),
                        ],
                      ),
                    ],
                  ),
                  If(
                    iduOpcode
                        .eq(Const(_opcode.load, width: iduOpcode.width))
                        .or(
                          iduOpcode.eq(
                            Const(_opcode.store, width: iduOpcode.width),
                          ),
                        ),
                    then: [
                      ifuNext.assign(Const(0)),
                    ],
                    orElse: [
                      ifuNext.assign(Const(1)),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Iff(
            nextState.eq(Const(_state.memoryAccess, width: nextState.width)),
            then: [
              iduInstruction.assign(instructionBuffer),
              When([
                Iff(
                  iduOpcode.eq(Const(_opcode.load, width: iduOpcode.width)),
                  then: [
                    rfuAddressB.assign(iduRs1),
                    lsuOperation.assign(iduOpcode.part(5, 5).cat(iduFunct3)),
                    lsuLowAddress
                        .assign(rfuOutputDataB.add(iduImmI).part(1, 0)),
                    muAddress.assign(rfuOutputDataB.add(iduImmI).part(31, 2)),
                    lsuMemData.assign(muOutputData),
                    rfuAddressA.assign(iduRd),
                    rfuInputDataA.assign(lsuOutputData),
                    rfuWrite.assign(Const(1)),
                  ],
                ),
                Iff(
                  iduOpcode.eq(Const(_opcode.store, width: iduOpcode.width)),
                  then: [
                    lsuOperation.assign(iduOpcode.part(5, 5).cat(iduFunct3)),
                    rfuAddressB.assign(iduRs1),
                    lsuLowAddress
                        .assign(rfuOutputDataB.add(iduImmS).part(1, 0)),
                    rfuAddressC.assign(iduRs2),
                    lsuRegData.assign(rfuOutputDataC),
                    muAddress.assign(rfuOutputDataB.add(iduImmS).part(31, 2)),
                    muInputData.assign(lsuOutputData),
                    muWrite.assign(Const(1)),
                    lsuMemData.assign(muOutputData),
                  ],
                ),
              ]),
              ifuNext.assign(Const(1)),
              nextState.assign(Const(_state.main, width: nextState.width)),
            ],
          ),
        ],
      ),
    ]);

    addSyncSequential(PosEdge(clock), [
      If(
        reset,
        then: [
          currentState.assign(Const(_state.initial, width: currentState.width)),
        ],
        orElse: [currentState.assign(nextState)],
      ),
    ]);
  }

  static const _state = (
    initial: 0,
    main: 1,
    memoryAccess: 2,
    illegalInstruction: 3,
  );

  static final _opcode = (
    load: int.parse('0000011', radix: 2),
    store: int.parse('0100011', radix: 2),
    madd: int.parse('1000011', radix: 2),
    branch: int.parse('1100011', radix: 2),
    loadFp: int.parse('0000111', radix: 2),
    storeFp: int.parse('0100111', radix: 2),
    msub: int.parse('1000111', radix: 2),
    jalr: int.parse('1100111', radix: 2),
    nmsub: int.parse('1001011', radix: 2),
    miscMem: int.parse('0001111', radix: 2),
    amo: int.parse('0101111', radix: 2),
    nmadd: int.parse('1001111', radix: 2),
    jal: int.parse('1101111', radix: 2),
    opImm: int.parse('0010011', radix: 2),
    op: int.parse('0110011', radix: 2),
    opFp: int.parse('1010011', radix: 2),
    system: int.parse('1110011', radix: 2),
    auipc: int.parse('0010111', radix: 2),
    lui: int.parse('0110111', radix: 2),
    opImm32: int.parse('0011011', radix: 2),
    op32: int.parse('0111011', radix: 2),
  );
}
