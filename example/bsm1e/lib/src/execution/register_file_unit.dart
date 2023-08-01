import 'dart:math';
import 'package:svart/svart.dart';

class RegisterFileControllerUnit extends Module {
  RegisterFileControllerUnit(
    Var clock,
    Var enable,
    Var transferMode,
    Var source,
    Var destination,
  ) : super(definitionName: 'register_file_controller_unit') {
    clock = addInput('clock', clock);
    enable = addInput('enable', enable);
    transferMode = addInput('transfer_mode', transferMode, width: 2);
    source = addInput('source', source, width: 8);
    destination = addInput('destination', destination, width: 7);
    data = addOutput('data', width: 8);

    final registers = List.generate(pow(2, _addressWidth).toInt(), (index) {
      return addInternal(name: 'register_$index', width: 8);
    });

    final internalSourceIffs = <Iff>[];
    final externalSourceIffs = <Iff>[];
    final externalDestinationIffs = <Iff>[];
    for (var i = 0; i < registers.length; ++i) {
      final internalDestinationIffs = <Iff>[];
      for (var j = 0; j < registers.length; ++j) {
        internalDestinationIffs.add(
          Iff(
            destination.eq(Const(j, width: _addressWidth)),
            then: [
              if (j != i)
                registers[j].assign(registers[i])
              else
                // You cannot pass a register value to itself.
                Assert(destination.neq(Const(j, width: _addressWidth)))
            ],
          ),
        );
      }
      internalSourceIffs.add(
        Iff(
          source.part(6, 0).eq(Const(i, width: _addressWidth)),
          then: [When(internalDestinationIffs)],
        ),
      );
      externalSourceIffs.add(
        Iff(
          destination.eq(Const(i, width: _addressWidth)),
          then: [registers[i].assign(source)],
        ),
      );
      externalDestinationIffs.add(
        Iff(
          source.part(6, 0).eq(Const(i, width: _addressWidth)),
          then: [data.assign(registers[i])],
        ),
      );
    }

    addSyncSequential(PosEdge(clock), [
      If(
        enable,
        then: [
          When([
            Iff(
              transferMode.eq(
                Const(
                  RegisterFileControllerUnit.transferModeInternal,
                  width: transferMode.width,
                ),
              ),
              then: [When(internalSourceIffs)],
            ),
            Iff(
              transferMode.eq(
                Const(
                  RegisterFileControllerUnit.transferModeExternalSource,
                  width: transferMode.width,
                ),
              ),
              then: [When(externalSourceIffs)],
            ),
            Iff(
              transferMode.eq(
                Const(
                  RegisterFileControllerUnit.transferModeExternalDestination,
                  width: transferMode.width,
                ),
              ),
              then: [When(externalDestinationIffs)],
            )
          ])
        ],
      )
    ]);
  }

  late final Var data;

  final _addressWidth = 7;

  static const transferModeInternal = 0;
  static const transferModeExternalSource = 1;
  static const transferModeExternalDestination = 2;
}
