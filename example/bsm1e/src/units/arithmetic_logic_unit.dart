import 'package:svart/svart.dart';

class ArithmeticLogicUnit extends Module {
  ArithmeticLogicUnit(Var clock, Var act, Var data, {super.instanceName})
      : super(definitionName: 'arithmetic_logic_unit') {
    clock = addInput('clock', clock);
    act = addInput('act', act, width: 2);
    data = addInput('data', data, width: 8);
    result = addOutput('result', width: 8);

    final operandA = addInternal(name: 'operand_a', width: 8);
    final operandB = addInternal(name: 'operand_b', width: 8);
    final op = addInternal(name: 'op', width: 4);

    addCombinational([op.assign(data.part(3, 0))]);

    addSyncSequential(PosEdge(clock), [
      If(
        act.neq(Const(actcode.none, width: act.width)),
        then: [
          When([
            Iff(
              act.eq(Const(actcode.setOperand.a, width: act.width)),
              then: [operandA.assign(data)],
            ),
            Iff(
              act.eq(Const(actcode.setOperand.b, width: act.width)),
              then: [operandB.assign(data)],
            ),
            Iff(
              act.eq(Const(actcode.operate, width: act.width)),
              then: [
                When(
                  [
                    Iff(
                      op.eq(Const(opcode.not, width: op.width)),
                      then: [result.assign(operandA.not())],
                    ),
                    Iff(
                      op.eq(Const(opcode.and, width: op.width)),
                      then: [result.assign(operandA.and(operandB))],
                    ),
                    Iff(
                      op.eq(Const(opcode.or, width: op.width)),
                      then: [result.assign(operandA.or(operandB))],
                    ),
                    Iff(
                      op.eq(Const(opcode.sl, width: op.width)),
                      then: [result.assign(operandA.dsl(operandB.part(3, 0)))],
                    ),
                    Iff(
                      op.eq(Const(opcode.sr, width: op.width)),
                      then: [result.assign(operandA.dsr(operandB.part(3, 0)))],
                    ),
                    Iff(
                      op.eq(Const(opcode.eq, width: op.width)),
                      then: [
                        result.assign(
                          Const(0, width: 7).cat(operandA.eq(operandB)),
                        ),
                      ],
                    ),
                    Iff(
                      op.eq(Const(opcode.neq, width: op.width)),
                      then: [
                        result.assign(
                          Const(0, width: 7).cat(operandA.neq(operandB)),
                        ),
                      ],
                    ),
                    Iff(
                      op.eq(Const(opcode.lt, width: op.width)),
                      then: [
                        result.assign(
                          Const(0, width: 7).cat(operandA.lt(operandB)),
                        ),
                      ],
                    ),
                    Iff(
                      op.eq(Const(opcode.gt, width: op.width)),
                      then: [
                        result.assign(
                          Const(0, width: 7).cat(operandA.gt(operandB)),
                        ),
                      ],
                    ),
                    Iff(
                      op.eq(Const(opcode.lte, width: op.width)),
                      then: [
                        result.assign(
                          Const(0, width: 7).cat(operandA.lte(operandB)),
                        ),
                      ],
                    ),
                    Iff(
                      op.eq(Const(opcode.gte, width: op.width)),
                      then: [
                        result.assign(
                          Const(0, width: 7).cat(operandA.gte(operandB)),
                        ),
                      ],
                    ),
                    Iff(
                      op.eq(Const(opcode.add, width: op.width)),
                      then: [result.assign(operandA.add(operandB))],
                    ),
                    Iff(
                      op.eq(Const(opcode.sub, width: op.width)),
                      then: [result.assign(operandA.sub(operandB))],
                    ),
                  ],
                  orElse: [
                    // Operation must be in a certain range.
                    Assert(op.lte(Const(opcode.sub, width: op.width))),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
    ]);
  }

  late final Var result;

  static const actcode = (
    none: 0,
    setOperand: (a: 1, b: 2),
    operate: 3,
  );

  static const opcode = (
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

String main({bool noPrint = false}) {
  final systemverilog =
      ArithmeticLogicUnit(Var(), Var(width: 2), Var(width: 8)).emit();

  if (!noPrint) {
    // ignore: avoid_print
    print(systemverilog);
  }

  return systemverilog;
}
