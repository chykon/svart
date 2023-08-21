import 'package:svart/svart.dart';

class InstructionFetchUnit extends Module {
  InstructionFetchUnit(
    Var clock,
    Var jump,
    Var jumpAddress,
    Var next, {
    super.instanceName,
  }) : super(definitionName: 'instruction_fetch_unit') {
    clock = addInput('clock', clock);
    jump = addInput('jump', jump);
    jumpAddress = addInput('jump_address', jumpAddress, width: 15);
    next = addInput('next', next);
    currentAddress = addOutput('current_address', width: 15);

    addSyncSequential(PosEdge(clock), [
      If(
        jump,
        then: [currentAddress.assign(jumpAddress)],
        orElse: [
          If(
            next,
            then: [
              currentAddress.assign(
                currentAddress.add(Const(1, width: currentAddress.width)),
              ),
            ],
          ),
        ],
      ),
    ]);
  }

  late final Var currentAddress;
}

String main({bool noPrint = false}) {
  final systemverilog =
      InstructionFetchUnit(Var(), Var(), Var(width: 15), Var()).emit();

  if (!noPrint) {
    // ignore: avoid_print
    print(systemverilog);
  }

  return systemverilog;
}
