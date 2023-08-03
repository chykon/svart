import 'package:svart/svart.dart';

class ArithmeticLogicUnit extends Module {
  ArithmeticLogicUnit(Var clock, Var action, Var data)
      : super(definitionName: 'arithmetic_logic_unit') {
    clock = addInput('clock', clock);
    action = addInput('action', action, width: 2);
    data = addInput('data', data, width: 8);
    result = addOutput('result', width: 8);

    final operandA = addInternal(name: 'operand_a', width: 8);
    final operandB = addInternal(name: 'operand_b', width: 8);

    addSyncSequential(PosEdge(clock), [
      If(
        action.neq(Const(ArithmeticLogicUnit.action.none, width: action.width)),
        then: [
          When([
            Iff(
              action.eq(
                Const(
                  ArithmeticLogicUnit.action.setOperand.a,
                  width: action.width,
                ),
              ),
              then: [operandA.assign(data)],
            ),
            Iff(
              action.eq(
                Const(
                  ArithmeticLogicUnit.action.setOperand.b,
                  width: action.width,
                ),
              ),
              then: [operandB.assign(data)],
            ),
            Iff(
              action.eq(
                Const(
                  ArithmeticLogicUnit.action.callOperation,
                  width: action.width,
                ),
              ),
              then: [
                When(
                  [
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.not,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.not())],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.and,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.and(operandB))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.or,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.or(operandB))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.sl,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.dsl(operandB.part(3, 0)))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.sr,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.dsr(operandB.part(3, 0)))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.eq,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.eq(operandB))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.neq,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.neq(operandB))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.lt,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.lt(operandB))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.gt,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.gt(operandB))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.lte,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.lte(operandB))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.gte,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.gte(operandB))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.add,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.add(operandB))],
                    ),
                    Iff(
                      data.part(3, 0).eq(
                            Const(
                              ArithmeticLogicUnit.operation.sub,
                              width: 4,
                            ),
                          ),
                      then: [result.assign(operandA.sub(operandB))],
                    )
                  ],
                  orElse: [
                    // Operation must be in a certain range.
                    Assert(
                      data.part(3, 0).lte(
                            Const(
                              ArithmeticLogicUnit.operation.sub,
                              width: 4,
                            ),
                          ),
                    )
                  ],
                )
              ],
            )
          ])
        ],
      )
    ]);
  }

  late final Var result;

  static const action = (none: 0, setOperand: (a: 1, b: 2), callOperation: 3);

  static const operation = (
    not: 0,
    and: 1,
    or: 2,
    sl: 3,
    sr: 4,
    eq: 5,
    neq: 6,
    lt: 7,
    gt: 8,
    lte: 9,
    gte: 10,
    add: 11,
    sub: 12
  );
}
