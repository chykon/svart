// An example of a 4-bit counter.
//
// Interface:
//   inputs:
//     clock  - 1 bit
//     reset  - 1 bit
//     enable - 1 bit
//   outputs:
//     value  - 4 bits

// Import the `Svart` package.
import 'package:svart/svart.dart';

// We extend the base class `Module`. This is our main block
// for building circuits.
class Counter4Bit extends Module {
  // The constructor is useful for fully defining a module in one place.
  // The `clock`, `reset` and `enable` constructor parameters are input ports
  // and are used to easily connect to other modules. The `name` parameter is
  // used to specify the name of the module instance and may be omitted.
  Counter4Bit(Var clock, Var reset, Var enable, {String? name})
      // Specifying the module definition name is required. In this case,
      // we pass it as a string directly to the parent class constructor.
      : super(definitionName: 'counter4bit', instanceName: name) {
    // We add module inputs using the `addInput` method.
    //
    // It is required to specify the name of the input port and a reference
    // to the external `Var` to which the internal `Var` returned by the
    // function will be connected.
    //
    // For simplicity, we sequentially assign the results of calling the
    // `addInput` method to the corresponding parameters. Reassigning function
    // parameters is not a recommended practice, but in this case it helps
    // to protect against accidental access to an external `Var` and not to
    // create unnecessary variables.
    clock = addInput('clock', clock);
    reset = addInput('reset', reset);
    enable = addInput('enable', enable);
    // We add module outputs using the `addOutput` method, which is a
    // bit like `addInput`.
    value = addOutput('value', width: 4);

    // Adding a synchronous sequential logic block.
    //
    // The synchronous logic has a state that is updated when the clock changes
    // (in this case, when the clock goes from "0" to "1").
    addSyncSequential(PosEdge(clock), [
      // In this list, we put actions that are almost one-to-one mapped
      // to the SystemVerilog code:
      // --------------
      // if (reset) begin
      //   value <= 4'h0;
      // end else begin
      //   if (enable) begin
      //     value <= value + 4'h1;
      //   end
      // end
      // --------------
      // The type of assignment (blocking or non-blocking) depends
      // on the type of procedure.
      If(
        reset,
        then: [value.assign(Const(0, width: 4))],
        orElse: [
          If(enable, then: [value.assign(value.add(Const(1, width: 4)))]),
        ],
      ),
    ]);
  }

  // The output port is made a field of the class for convenience.
  // Use the `late` modifier to initialize a variable in the body of
  // the constructor (this can be useful for module parameterization).
  late final Var value;
}

// Here is a demo of code generation. The return value and the `noPrint`
// parameter are used for testing purposes, so this can be ignored.
String main({bool noPrint = false}) {
  // We instantiate the module and call the `emit` method to generate the
  // SystemVerilog code. We also pass the required `Var`s to the constructor
  // as "caps". The name of the module instance is omitted because it is
  // the top one in the hierarchy.
  final systemverilog = Counter4Bit(
    Var(name: 'clock_cap'),
    Var(name: 'reset_cap'),
    Var(name: 'enable_cap'),
  ).emit();

  // The presence or absence of output depends on the value of
  // the `noPrint` flag.
  if (!noPrint) {
    // We output the generated code to the terminal.
    // The line below is used to ignore the linter rule
    // (`print` is an easy way to output to the terminal):
    // ignore: avoid_print
    print(systemverilog);
  }

  // Returning a string with the generated code is for testing purposes
  // and is not important in this case.
  return systemverilog;
}
