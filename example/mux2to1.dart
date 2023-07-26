// An example of a 2-to-1 multiplexer.
//
// Interface:
//   inputs:
//     a   - 1 bit
//     b   - 1 bit
//     sel - 1 bit
//   outputs:
//     y   - 1 bit

// Import the `Svart` package.
import 'package:svart/svart.dart';

// We extend the base class `Module`. This is our main block
// for building circuits.
class Mux2to1 extends Module {
  // The constructor is useful for fully defining a module in one place.
  // The `a`, `b` and `sel` constructor parameters are input ports and
  // are used to easily connect to other modules. The `name` parameter is
  // used to specify the name of the module instance and may be omitted.
  Mux2to1(Var a, Var b, Var sel, {String? name})
      // Specifying the module definition name is required. In this case,
      // we pass it as a string directly to the parent class constructor.
      : super(definitionName: 'mux2to1', instanceName: name) {
    // We add module inputs using the `addInput` method.
    //
    // It is required to specify the name of the input port and a reference
    // to the external `Var` to which the internal `Var` returned by the
    // function will be connected. By default, the input bit width is one,
    // so it can be omitted.
    //
    // For simplicity, we sequentially assign the results of calling the
    // `addInput` method to the corresponding parameters. Reassigning function
    // parameters is not a recommended practice, but in this case it helps
    // to protect against accidental access to an external `Var` and not to
    // create unnecessary variables.
    a = addInput('a', a);
    b = addInput('b', b);
    sel = addInput('sel', sel);
    // We add module outputs using the `addOutput` method, which is a
    // bit like `addInput`.
    y = addOutput('y');

    // Adding a combinational logic block.
    //
    // Combinational logic is stateless and the output signal is determined
    // only by the inputs. This is the equivalent of a pure function.
    addCombinational([
      // In this list, we put actions that are almost one-to-one mapped
      // to the SystemVerilog code:
      // --------------
      // if (sel) begin
      //   y = a;
      // end else begin
      //   y = b;
      // end
      // --------------
      // The type of assignment (blocking or non-blocking) depends
      // on the type of procedure.
      If(sel, then: [y.assign(a)], orElse: [y.assign(b)])
    ]);
  }

  // The output port is made a field of the class for convenience.
  // Use the `late` modifier to initialize a variable in the body of
  // the constructor (this can be useful for module parameterization).
  late final Var y;
}

// Here is a demo of code generation. The return value and the `noPrint`
// parameter are used for testing purposes, so this can be ignored.
String main({bool noPrint = false}) {
  // We instantiate the module and call the `emit` method to generate the
  // SystemVerilog code. We also pass the required `Var`s to the constructor
  // as "caps". The name of the module instance is omitted because it is
  // the top one in the hierarchy.
  final systemverilog =
      Mux2to1(Var(name: 'a_cap'), Var(name: 'b_cap'), Var(name: 'sel_cap'))
          .emit();

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
