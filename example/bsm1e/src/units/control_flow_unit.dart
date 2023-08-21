import 'package:svart/svart.dart';

class ControlFlowUnit extends Module {
  ControlFlowUnit(
    Var clock,
    Var act,
    Var data,
    Var resetBranch,
    Var currentAddress, {
    super.instanceName,
  }) : super(definitionName: 'control_flow_unit') {
    clock = addInput('clock', clock);
    act = addInput('act', act, width: 3);
    data = addInput('data', data, width: 8);
    resetBranch = addInput('reset_branch', resetBranch);
    currentAddress = addInput('current_address', currentAddress, width: 15);
    branch = addOutput('branch');
    branchAddress = addOutput('branch_address', width: 15);

    final value = addInternal(name: 'value');
    final op = addInternal(name: 'op', width: 2);

    addCombinational([op.assign(data.part(1, 0))]);

    addSyncSequential(PosEdge(clock), [
      If(resetBranch, then: [branch.assign(Const(0))]),
      If(
        act.neq(Const(actcode.none, width: act.width)),
        then: [
          When(
            [
              Iff(
                act.eq(Const(actcode.setAddress.lowPart, width: act.width)),
                then: [
                  branchAddress
                      .assign(branchAddress.part(14, 7).cat(data.part(7, 1))),
                ],
              ),
              Iff(
                act.eq(Const(actcode.setAddress.highPart, width: act.width)),
                then: [
                  branchAddress.assign(data.cat(branchAddress.part(6, 0))),
                ],
              ),
              Iff(
                act.eq(Const(actcode.setValue, width: act.width)),
                then: [value.assign(data.part(0, 0))],
              ),
              Iff(
                act.eq(Const(actcode.operate, width: act.width)),
                then: [
                  When(
                    [
                      Iff(
                        op.eq(Const(opcode.snapshot, width: op.width)),
                        then: [branchAddress.assign(currentAddress)],
                      ),
                      Iff(
                        op.eq(Const(opcode.branch.eqz, width: op.width)),
                        then: [
                          If(
                            value.eq(Const(0)),
                            then: [branch.assign(Const(1))],
                          ),
                        ],
                      ),
                      Iff(
                        op.eq(Const(opcode.branch.neqz, width: op.width)),
                        then: [
                          If(
                            value.neq(Const(0)),
                            then: [branch.assign(Const(1))],
                          ),
                        ],
                      ),
                    ],
                    orElse: [
                      // `Op` must be in a certain range.
                      Assert(
                          op.lte(Const(opcode.branch.neqz, width: op.width))),
                    ],
                  ),
                ],
              ),
            ],
            orElse: [
              // `Act` must be in a certain range.
              Assert(act.lte(Const(actcode.operate, width: act.width))),
            ],
          ),
        ],
      ),
    ]);
  }

  late final Var branch;
  late final Var branchAddress;

  // action code
  static const actcode = (
    none: 0,
    setAddress: (lowPart: 1, highPart: 2),
    setValue: 3,
    operate: 4,
  );

  static const opcode = (
    snapshot: 0,
    branch: (
      eqz: 1, // equal zero
      neqz: 2, // not equal zero
    ),
  );
}

String main({bool noPrint = false}) {
  final systemverilog = ControlFlowUnit(
    Var(),
    Var(width: 3),
    Var(width: 8),
    Var(),
    Var(width: 15),
  ).emit();

  if (!noPrint) {
    // ignore: avoid_print
    print(systemverilog);
  }

  return systemverilog;
}
