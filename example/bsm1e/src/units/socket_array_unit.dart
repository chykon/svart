import 'package:svart/svart.dart';
import 'arithmetic_logic_unit.dart';
import 'control_flow_unit.dart';
import 'load_store_unit.dart';

class SocketArrayUnit extends Module {
  SocketArrayUnit(
    Var instruction,
    ({Var outputValue}) fromLU, // Literal Unit
    ({Var branchAddress}) fromCFU, // Control Flow Unit
    ({Var outputData}) fromRFU, // Register File Unit
    ({Var targetData}) fromLSU, // Load-Store Unit
    ({Var result}) fromALU, // Arithmetic Logic Unit
    {
    super.instanceName,
  }) : super(definitionName: 'socket_array_unit') {
    instruction = addInput('instruction', instruction, width: 16);
    fromLU = (
      outputValue: addInput(
        'from_lu_output_value',
        fromLU.outputValue,
        width: 8,
      )
    );
    fromCFU = (
      branchAddress: addInput(
        'from_cfu_branch_address',
        fromCFU.branchAddress,
        width: 15,
      )
    );
    fromRFU = (
      outputData: addInput(
        'from_rfu_output_data',
        fromRFU.outputData,
        width: 8,
      )
    );
    fromLSU = (
      targetData: addInput(
        'from_lsu_target_data',
        fromLSU.targetData,
        width: 16,
      )
    );
    fromALU = (
      result: addInput(
        'from_alu_result',
        fromALU.result,
        width: 8,
      )
    );
    illegalInstruction = addOutput('illegal_instruction');
    toLU = (
      write: addOutput('to_lu_write'),
      inputValue: addOutput('to_lu_input_value', width: 8)
    );
    toCFU = (
      act: addOutput('to_cfu_act', width: 3),
      data: addOutput('to_cfu_data', width: 8)
    );
    toRFU = (
      write: addOutput('to_rfu_write'),
      address: addOutput('to_rfu_address', width: 7),
      inputData: addOutput('to_rfu_input_data', width: 8)
    );
    toLSU = (
      act: addOutput('to_lsu_act', width: 3),
      data: addOutput('to_lsu_data', width: 8)
    );
    toALU = (
      act: addOutput('to_alu_act', width: 2),
      data: addOutput('to_alu_data', width: 8)
    );

    final alpha = addInternal(name: 'alpha', width: 8);
    final omega = addInternal(name: 'omega', width: 8);

    addCombinational([alpha.assign(instruction.part(7, 0))]);
    addCombinational([omega.assign(instruction.part(15, 8))]);

    addCombinational([
      illegalInstruction.assign(Const(0)),
      toLU.write.assign(Const(0)),
      toCFU.act
          .assign(Const(ControlFlowUnit.actcode.none, width: toCFU.act.width)),
      toRFU.write.assign(Const(0)),
      toLSU.act
          .assign(Const(LoadStoreUnit.actcode.none, width: toLSU.act.width)),
      toALU.act.assign(
        Const(ArithmeticLogicUnit.actcode.none, width: toALU.act.width),
      ),
      If(
        // asm: aux.nop (if condition is false)
        alpha
            .eq(Const(index.aux, width: alpha.width))
            .and(omega.eq(Const(auxOpcode.nop, width: omega.width)))
            .not(),
        then: [
          When(
            [
              // asm: aux.illegal
              Iff(
                alpha.eq(Const(index.aux, width: alpha.width)).and(
                      omega.eq(Const(auxOpcode.illegal, width: omega.width)),
                    ),
                then: [illegalInstruction.assign(Const(1))],
              ),
              // asm: lit <0-255>
              Iff(
                alpha.eq(Const(index.lit, width: alpha.width)),
                then: [
                  toLU.inputValue.assign(omega),
                  toLU.write.assign(Const(1))
                ],
              ),
              // asm: <rf.r0-rf.r127> <source> (abstract)
              Iff(
                alpha
                    .gte(Const(index.rf.address.first, width: omega.width))
                    .and(
                      omega.lte(
                        Const(index.rf.address.last, width: omega.width),
                      ),
                    ),
                then: [
                  When(
                    [
                      // asm: <rf.r0-rf.r127> lit
                      Iff(
                        omega.eq(Const(index.lit, width: omega.width)),
                        then: [
                          toRFU.address.assign(alpha.part(6, 0)),
                          toRFU.inputData.assign(fromLU.outputValue),
                          toRFU.write.assign(Const(1))
                        ],
                      ),
                      // asm: <rf.r0-rf.r127> br.address.low
                      Iff(
                        omega.eq(
                          Const(index.br.address.low, width: omega.width),
                        ),
                        then: [
                          toRFU.address.assign(alpha.part(6, 0)),
                          toRFU.inputData.assign(
                            fromCFU.branchAddress.part(6, 0).cat(Const(0)),
                          ),
                          toRFU.write.assign(Const(1))
                        ],
                      ),
                      // asm: <rf.r0-rf.r127> br.address.high
                      Iff(
                        omega.eq(
                          Const(index.br.address.high, width: omega.width),
                        ),
                        then: [
                          toRFU.address.assign(alpha.part(6, 0)),
                          toRFU.inputData
                              .assign(fromCFU.branchAddress.part(14, 7)),
                          toRFU.write.assign(Const(1))
                        ],
                      ),
                      // asm: <rf.r0-rf.r127> mem.data.low
                      Iff(
                        omega.eq(
                          Const(index.mem.data.low, width: omega.width),
                        ),
                        then: [
                          toRFU.address.assign(alpha.part(6, 0)),
                          toRFU.inputData.assign(fromLSU.targetData.part(7, 0)),
                          toRFU.write.assign(Const(1))
                        ],
                      ),
                      // asm: <rf.r0-rf.r127> mem.data.high
                      Iff(
                        omega.eq(
                          Const(index.mem.data.high, width: omega.width),
                        ),
                        then: [
                          toRFU.address.assign(alpha.part(6, 0)),
                          toRFU.inputData
                              .assign(fromLSU.targetData.part(15, 8)),
                          toRFU.write.assign(Const(1))
                        ],
                      ),
                      // asm: <rf.r0-rf.r127> alu.result
                      Iff(
                        omega.eq(
                          Const(index.alu.result, width: omega.width),
                        ),
                        then: [
                          toRFU.address.assign(alpha.part(6, 0)),
                          toRFU.inputData.assign(fromALU.result),
                          toRFU.write.assign(Const(1))
                        ],
                      )
                    ],
                    orElse: [illegalInstruction.assign(Const(1))],
                  )
                ],
              ),
              // asm: <destination> <rf.r0-rf.r127> (abstract)
              Iff(
                omega
                    .gte(Const(index.rf.address.first, width: omega.width))
                    .and(
                      omega.lte(
                        Const(index.rf.address.last, width: omega.width),
                      ),
                    ),
                then: [
                  When(
                    [
                      // asm: br.address.low <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(
                          Const(index.br.address.low, width: alpha.width),
                        ),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          toCFU.data.assign(fromRFU.outputData),
                          toCFU.act.assign(
                            Const(
                              ControlFlowUnit.actcode.setAddress.lowPart,
                              width: toCFU.act.width,
                            ),
                          )
                        ],
                      ),
                      // asm: br.address.high <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(
                          Const(index.br.address.high, width: alpha.width),
                        ),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          toCFU.data.assign(fromRFU.outputData),
                          toCFU.act.assign(
                            Const(
                              ControlFlowUnit.actcode.setAddress.highPart,
                              width: toCFU.act.width,
                            ),
                          )
                        ],
                      ),
                      // asm: br.value <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(Const(index.br.value, width: alpha.width)),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          toCFU.data.assign(fromRFU.outputData),
                          toCFU.act.assign(
                            Const(
                              ControlFlowUnit.actcode.setValue,
                              width: toCFU.act.width,
                            ),
                          )
                        ],
                      ),
                      // asm: br.op <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(Const(index.br.op, width: alpha.width)),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          If(
                            fromRFU.outputData.lte(
                              Const(
                                ControlFlowUnit.opcode.branch.neqz,
                                width: fromRFU.outputData.width,
                              ),
                            ),
                            then: [
                              toCFU.data.assign(fromRFU.outputData),
                              toCFU.act.assign(
                                Const(
                                  ControlFlowUnit.actcode.operate,
                                  width: toCFU.act.width,
                                ),
                              )
                            ],
                            orElse: [illegalInstruction.assign(Const(1))],
                          )
                        ],
                      ),
                      // asm: mem.address.low <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(
                          Const(index.mem.address.low, width: alpha.width),
                        ),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          toLSU.data.assign(fromRFU.outputData),
                          toLSU.act.assign(
                            Const(
                              LoadStoreUnit.actcode.setAddress.lowByte,
                              width: toLSU.act.width,
                            ),
                          )
                        ],
                      ),
                      // asm: mem.address.high <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(
                          Const(index.mem.address.high, width: alpha.width),
                        ),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          toLSU.data.assign(fromRFU.outputData),
                          toLSU.act.assign(
                            Const(
                              LoadStoreUnit.actcode.setAddress.highByte,
                              width: toLSU.act.width,
                            ),
                          )
                        ],
                      ),
                      // asm: mem.data.low <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(
                          Const(index.mem.data.low, width: alpha.width),
                        ),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          toLSU.data.assign(fromRFU.outputData),
                          toLSU.act.assign(
                            Const(
                              LoadStoreUnit.actcode.setData.lowByte,
                              width: toLSU.act.width,
                            ),
                          )
                        ],
                      ),
                      // asm: mem.data.high <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(
                          Const(index.mem.data.high, width: alpha.width),
                        ),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          toLSU.data.assign(fromRFU.outputData),
                          toLSU.act.assign(
                            Const(
                              LoadStoreUnit.actcode.setData.highByte,
                              width: toLSU.act.width,
                            ),
                          )
                        ],
                      ),
                      // asm: mem.op <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(Const(index.mem.op, width: alpha.width)),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          If(
                            fromRFU.outputData.lte(
                              Const(
                                LoadStoreUnit.opcode.store.halfword,
                                width: fromRFU.outputData.width,
                              ),
                            ),
                            then: [
                              toLSU.data.assign(fromRFU.outputData),
                              toLSU.act.assign(
                                Const(
                                  LoadStoreUnit.actcode.operate,
                                  width: toLSU.act.width,
                                ),
                              )
                            ],
                            orElse: [illegalInstruction.assign(Const(1))],
                          )
                        ],
                      ),
                      // asm: alu.operand.a <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(
                          Const(index.alu.operand.a, width: alpha.width),
                        ),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          toALU.data.assign(fromRFU.outputData),
                          toALU.act.assign(
                            Const(
                              ArithmeticLogicUnit.actcode.setOperand.a,
                              width: toALU.act.width,
                            ),
                          )
                        ],
                      ),
                      // asm: alu.operand.b <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(
                          Const(index.alu.operand.b, width: alpha.width),
                        ),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          toALU.data.assign(fromRFU.outputData),
                          toALU.act.assign(
                            Const(
                              ArithmeticLogicUnit.actcode.setOperand.b,
                              width: toALU.act.width,
                            ),
                          )
                        ],
                      ),
                      // asm: alu.op <rf.r0-rf.r127>
                      Iff(
                        alpha.eq(Const(index.alu.op, width: alpha.width)),
                        then: [
                          toRFU.address.assign(omega.part(6, 0)),
                          If(
                            fromRFU.outputData.lte(
                              Const(
                                ArithmeticLogicUnit.opcode.sub,
                                width: fromRFU.outputData.width,
                              ),
                            ),
                            then: [
                              toALU.data.assign(fromRFU.outputData),
                              toALU.act.assign(
                                Const(
                                  ArithmeticLogicUnit.actcode.operate,
                                  width: toALU.act.width,
                                ),
                              )
                            ],
                            orElse: [illegalInstruction.assign(Const(1))],
                          )
                        ],
                      )
                    ],
                    orElse: [illegalInstruction.assign(Const(1))],
                  )
                ],
              )
            ],
            orElse: [illegalInstruction.assign(Const(1))],
          )
        ],
      )
    ]);
  }

  late final Var illegalInstruction;
  late final ({Var write, Var inputValue}) toLU;
  late final ({Var act, Var data}) toCFU;
  late final ({Var write, Var address, Var inputData}) toRFU;
  late final ({Var act, Var data}) toLSU;
  late final ({Var act, Var data}) toALU;

  static const index = (
    // auxiliary
    aux: 0,
    // literal
    lit: 1,
    // branch
    br: (
      address: (low: 2, high: 3),
      value: 4,
      op: 5, // operation
    ),
    // memory
    mem: (
      address: (low: 6, high: 7),
      data: (low: 8, high: 9),
      op: 10,
    ),
    // Arithmetic Logic Unit
    alu: (
      operand: (a: 11, b: 12),
      result: 13,
      op: 14,
    ),
    // Register File
    rf: (address: (first: 128, last: 255))
  );

  static const auxOpcode = (illegal: 0, nop: 1);
}
