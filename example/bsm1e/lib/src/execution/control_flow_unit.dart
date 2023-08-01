import 'package:svart/svart.dart';

class ControlFlowUnit extends Module {
  ControlFlowUnit(
    Var clock,
    Var action,
    Var data,
    Var currentAddress,
  ) : super(definitionName: 'control_flow_unit') {
    clock = addInput('clock', clock);
    action = addInput('action', action, width: 3);
    data = addInput('data', data, width: 8);
    currentAddress = addInput('current_address', currentAddress, width: 15);
    branch = addOutput('branch');
    branchAddress = addOutput('branch_address', width: 15);

    final value = addInternal(name: 'value');

    addSyncSequential(PosEdge(clock), [
      branch.assign(Const(0)),
      If(
        action.neq(Const(ControlFlowUnit.action.none, width: action.width)),
        then: [
          When(
            [
              Iff(
                action.eq(
                  Const(
                    ControlFlowUnit.action.setAddressLowPart,
                    width: action.width,
                  ),
                ),
                then: [
                  // Zero bit will be truncated.
                  Assert(data.part(0, 0).eq(Const(0))),
                  branchAddress
                      .assign(branchAddress.part(14, 7).cat(data.part(7, 1)))
                ],
              ),
              Iff(
                action.eq(
                  Const(
                    ControlFlowUnit.action.setAddressHighPart,
                    width: action.width,
                  ),
                ),
                then: [
                  branchAddress.assign(data.cat(branchAddress.part(6, 0)))
                ],
              ),
              Iff(
                action.eq(
                  Const(
                    ControlFlowUnit.action.setValue,
                    width: action.width,
                  ),
                ),
                then: [
                  // Only the zero bit is used.
                  Assert(data.part(7, 1).eq(Const(0, width: 7))),
                  value.assign(data.part(0, 0))
                ],
              ),
              Iff(
                action.eq(
                  Const(
                    ControlFlowUnit.action.callOperation,
                    width: action.width,
                  ),
                ),
                then: [
                  If(
                    data
                        .part(0, 0)
                        .eq(Const(ControlFlowUnit.operation.snapshot)),
                    then: [branchAddress.assign(currentAddress)],
                    orElse: [
                      If(value.eq(Const(0)), then: [branch.assign(Const(1))])
                    ],
                  )
                ],
              )
            ],
            orElse: [
              // `Action` must be in a certain range.
              Assert(
                action.lte(
                  Const(
                    ControlFlowUnit.action.callOperation,
                    width: action.width,
                  ),
                ),
              )
            ],
          )
        ],
      )
    ]);
  }

  late final Var branch;
  late final Var branchAddress;

  static const action = (
    none: 0,
    setAddressLowPart: 1,
    setAddressHighPart: 2,
    setValue: 3,
    callOperation: 4
  );

  static const operation = (snapshot: 0, branchEqz: 1);
}
