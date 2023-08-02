import 'package:svart/svart.dart';

class ValueKeepUnit extends Module {
  ValueKeepUnit(Var clock, Var write, Var inputValue)
      : super(definitionName: 'value_keep_unit') {
    clock = addInput('clock', clock);
    write = addInput('write', write);
    inputValue = addInput('input_value', inputValue, width: 8);
    outputValue = addOutput('output_value', width: 8);

    addSyncSequential(PosEdge(clock), [
      If(write, then: [outputValue.assign(inputValue)])
    ]);
  }

  late final Var outputValue;
}
