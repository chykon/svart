import 'package:svart/svart.dart';

class ControlFlowUnit extends Module {
  ControlFlowUnit(
    Var operation,
    Var rs1,
    Var rs2,
  ) : super(
          definitionName: 'control_flow_unit',
          instanceName: 'control_flow_unit_instance',
        ) {
    operation = addInput('operation', operation, width: 3);
    rs1 = addInput('rs1', rs1, width: 32);
    rs2 = addInput('rs2', rs2, width: 32);
    branch = addOutput('branch');

    addCombinational([
      branch.assign(Const(0)),
      When([
        Iff(
          operation.eq(
            Const(ControlFlowUnit.operation.beq, width: operation.width),
          ),
          then: [
            If(rs1.eq(rs2), then: [branch.assign(Const(1))]),
          ],
        ),
        Iff(
          operation.eq(
            Const(ControlFlowUnit.operation.bne, width: operation.width),
          ),
          then: [
            If(rs1.neq(rs2), then: [branch.assign(Const(1))]),
          ],
        ),
        Iff(
          operation.eq(
            Const(ControlFlowUnit.operation.blt, width: operation.width),
          ),
          then: [
            If(
              rs1.part(31, 31).eq(Const(1)),
              then: [
                If(
                  rs2.part(31, 31).eq(Const(1)),
                  then: [
                    If(
                      rs1.lt(rs2),
                      then: [branch.assign(Const(1))],
                      orElse: [branch.assign(Const(0))],
                    ),
                  ],
                  orElse: [branch.assign(Const(1))],
                ),
              ],
              orElse: [
                If(
                  rs2.part(31, 31).eq(Const(1)),
                  then: [branch.assign(Const(0))],
                  orElse: [
                    If(
                      rs1.lt(rs2),
                      then: [branch.assign(Const(1))],
                      orElse: [branch.assign(Const(0))],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Iff(
          operation.eq(
            Const(ControlFlowUnit.operation.bge, width: operation.width),
          ),
          then: [
            If(
              rs1.part(31, 31).eq(Const(1)),
              then: [
                If(
                  rs2.part(31, 31).eq(Const(1)),
                  then: [
                    If(
                      rs1.gte(rs2),
                      then: [branch.assign(Const(1))],
                      orElse: [branch.assign(Const(0))],
                    ),
                  ],
                  orElse: [branch.assign(Const(0))],
                ),
              ],
              orElse: [
                If(
                  rs2.part(31, 31).eq(Const(1)),
                  then: [branch.assign(Const(1))],
                  orElse: [
                    If(
                      rs1.gte(rs2),
                      then: [branch.assign(Const(1))],
                      orElse: [branch.assign(Const(0))],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Iff(
          operation.eq(
            Const(ControlFlowUnit.operation.bltu, width: operation.width),
          ),
          then: [
            If(rs1.lt(rs2), then: [branch.assign(Const(1))]),
          ],
        ),
        Iff(
          operation.eq(
            Const(ControlFlowUnit.operation.bgeu, width: operation.width),
          ),
          then: [
            If(rs1.gte(rs2), then: [branch.assign(Const(1))]),
          ],
        ),
      ]),
    ]);
  }

  late final Var branch;

  static final operation = (
    beq: int.parse('000', radix: 2),
    bne: int.parse('001', radix: 2),
    blt: int.parse('100', radix: 2),
    bge: int.parse('101', radix: 2),
    bltu: int.parse('110', radix: 2),
    bgeu: int.parse('111', radix: 2),
  );
}
