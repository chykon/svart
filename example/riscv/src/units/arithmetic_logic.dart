import 'dart:math';
import 'package:svart/svart.dart';

class ArithmeticLogicUnit extends Module {
  ArithmeticLogicUnit(
    Var operation,
    Var operandA,
    Var operandB,
  ) : super(
          definitionName: 'arithmetic_logic_unit',
          instanceName: 'arithmetic_logic_unit_instance',
        ) {
    operation = addInput('operation', operation, width: 4);
    operandA = addInput('operandA', operandA, width: 32);
    operandB = addInput('operandB', operandB, width: 32);
    result = addOutput('result', width: 32);

    addCombinational([
      When(
        [
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.add, width: operation.width),
            ),
            then: [result.assign(operandA.add(operandB))],
          ),
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.sub, width: operation.width),
            ),
            then: [result.assign(operandA.sub(operandB))],
          ),
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.sll, width: operation.width),
            ),
            then: [result.assign(operandA.dsl(operandB))],
          ),
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.slt, width: operation.width),
            ),
            then: [
              If(
                operandA.part(31, 31).eq(Const(1)),
                then: [
                  If(
                    operandB.part(31, 31).eq(Const(1)),
                    then: [
                      If(
                        operandA.lt(operandB),
                        then: [result.assign(Const(1, width: result.width))],
                        orElse: [result.assign(Const(0, width: result.width))],
                      ),
                    ],
                    orElse: [result.assign(Const(1, width: result.width))],
                  ),
                ],
                orElse: [
                  If(
                    operandB.part(31, 31).eq(Const(1)),
                    then: [result.assign(Const(0, width: result.width))],
                    orElse: [
                      If(
                        operandA.lt(operandB),
                        then: [result.assign(Const(1, width: result.width))],
                        orElse: [result.assign(Const(0, width: result.width))],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.sltu, width: operation.width),
            ),
            then: [
              If(
                operandA.lt(operandB),
                then: [result.assign(Const(1, width: result.width))],
                orElse: [result.assign(Const(0, width: result.width))],
              ),
            ],
          ),
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.xor, width: operation.width),
            ),
            then: [
              ...() {
                final actions = <Action>[];
                for (var i = 0; i < operandA.width; ++i) {
                  if (i == 0) {
                    actions.add(
                      If(
                        operandA.part(i, i).neq(operandB.part(i, i)),
                        then: [
                          result.assign(
                            result.part(result.width - 1, 1).cat(Const(1)),
                          ),
                        ],
                        orElse: [
                          result.assign(
                            result.part(result.width - 1, 1).cat(Const(0)),
                          ),
                        ],
                      ),
                    );
                  } else if (i != (operandA.width - 1)) {
                    actions.add(
                      If(
                        operandA.part(i, i).neq(operandB.part(i, i)),
                        then: [
                          result.assign(
                            result
                                .part(result.width - 1, i + 1)
                                .cat(Const(1))
                                .cat(result.part(i - 1, 0)),
                          ),
                        ],
                        orElse: [
                          result.assign(
                            result
                                .part(result.width - 1, i + 1)
                                .cat(Const(0))
                                .cat(result.part(i - 1, 0)),
                          ),
                        ],
                      ),
                    );
                  } else {
                    actions.add(
                      If(
                        operandA.part(i, i).neq(operandB.part(i, i)),
                        then: [
                          result.assign(
                            Const(1).cat(result.part(result.width - 2, 0)),
                          ),
                        ],
                        orElse: [
                          result.assign(
                            Const(0).cat(result.part(result.width - 2, 0)),
                          ),
                        ],
                      ),
                    );
                  }
                }
                return actions;
              }(),
            ],
          ),
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.srl, width: operation.width),
            ),
            then: [result.assign(operandA.dsr(operandB))],
          ),
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.sra, width: operation.width),
            ),
            then: [
              result.assign(operandA.dsr(operandB)),
              If(
                operandA.part(31, 31).eq(Const(1)),
                then: [
                  When(() {
                    final iffs = <Iff>[];
                    for (var i = 0; i < 32; ++i) {
                      if (i == 0) {
                        continue;
                      } else {
                        iffs.add(
                          Iff(
                            operandB.eq(Const(i, width: operandB.width)),
                            then: [
                              result.assign(
                                Const(pow(2, i).toInt() - 1, width: i)
                                    .cat(result.part(31 - i, 0)),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                    return iffs;
                  }()),
                ],
              ),
            ],
          ),
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.or, width: operation.width),
            ),
            then: [result.assign(operandA.or(operandB))],
          ),
          Iff(
            operation.eq(
              Const(ArithmeticLogicUnit.operation.and, width: operation.width),
            ),
            then: [result.assign(operandA.and(operandB))],
          ),
        ],
      ),
    ]);
  }

  late final Var result;

  static final operation = (
    add: int.parse('0000', radix: 2),
    sub: int.parse('1000', radix: 2),
    sll: int.parse('0001', radix: 2),
    slt: int.parse('0010', radix: 2),
    sltu: int.parse('0011', radix: 2),
    xor: int.parse('0100', radix: 2),
    srl: int.parse('0101', radix: 2),
    sra: int.parse('1101', radix: 2),
    or: int.parse('0110', radix: 2),
    and: int.parse('0111', radix: 2),
  );
}
