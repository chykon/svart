import 'package:svart/svart.dart';

class SocketArrayUnit extends Module {
  SocketArrayUnit(
    Var instruction,
    ({Var outputValue}) fromLU, // Literal Unit
  ) : super(definitionName: 'socket_array_unit') {
    instruction = addInput('instruction', instruction, width: 16);
    fromLU = (
      outputValue: addInput(
        fromLU.outputValue.name,
        fromLU.outputValue,
        width: fromLU.outputValue.width,
      )
    );
    illegalInstruction = addOutput('illegal_instruction');
    toLU = (
      write: addOutput('write'),
      inputValue: addOutput('input_value', width: 8)
    );

    final alpha = addInternal(name: 'alpha', width: 8);
    final omega = addInternal(name: 'omega', width: 8);

    addCombinational([alpha.assign(instruction.part(7, 0))]);
    addCombinational([omega.assign(instruction.part(15, 8))]);

    addCombinational([
      illegalInstruction.assign(Const(0)),
      toLU.write.assign(Const(0)),
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
