import 'package:svart/svart.dart';

class InstructionFetchUnit extends Module {
  InstructionFetchUnit(
    Var clock,
    Var jump,
    Var jumpAddress,
    Var next,
  ) : super(
          definitionName: 'instruction_fetch_unit',
          instanceName: 'instruction_fetch_unit_instance',
        ) {
    clock = addInput('clock', clock);
    jump = addInput('jump', jump);
    // Instructions are word aligned.
    jumpAddress = addInput('jump_address', jumpAddress, width: 30);
    next = addInput('next', next);
    currentAddress = addOutput('current_address', width: 30);

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
