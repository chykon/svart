// An example of a UTF-8 encoder (converting Unicode code points to UTF-8).
// The implementation relies on the "WHATWG: Encoding - UTF-8 encoder"
// specification. Link: https://encoding.spec.whatwg.org/#utf-8-encoder
//
// Interface:
//   inputs:
//     codepoint - 21 bits
//   outputs:
//     status    - 1 bit
//     bytes     - 32 bits

// Import the `Svart` package.
import 'package:svart/svart.dart';

// We extend the base class `Module`. This is our main block
// for building circuits.
class UTF8Encoder extends Module {
  // The constructor is useful for fully defining a module in one place.
  // The `codepoint` constructor parameter are input port and
  // are used to easily connect to other modules. The `name` parameter is
  // used to specify the name of the module instance and may be omitted.
  UTF8Encoder(Var codepoint, {String? name})
      // Specifying the module definition name is required. In this case,
      // we pass it as a string directly to the parent class constructor.
      : super(definitionName: 'utf8encoder', instanceName: name) {
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
    codepoint = addInput('codepoint', codepoint, width: 21);
    status = addOutput('status');
    bytes = addOutput('bytes', width: 32);

    // We add internal `Var`s using the `addInternal` method.
    final count = addInternal(name: 'count', width: 2);
    final offset = addInternal(name: 'offset', width: 8);
    final byte = addInternal(name: 'octet', width: 8);

    // Adding a combinational logic block.
    //
    // Combinational logic is stateless and the output signal is determined
    // only by the inputs. This is the equivalent of a pure function.
    addCombinational([
      count.assign(Const(0, width: 2)),
      When(
        [
          Iff(
            codepoint
                .gte(Const(0, width: 21))
                .and(codepoint.lte(Const(0x7F, width: 21))),
            then: [
              bytes.assign(Const(0, width: 11).cat(codepoint)),
              status.assign(Const(UTF8Encoder.statusSuccess)),
            ],
          ),
          Iff(
            codepoint
                .gte(Const(0x80, width: 21))
                .and(codepoint.lte(Const(0x7FF, width: 21))),
            then: [
              count.assign(Const(1, width: 2)),
              offset.assign(Const(0xC0, width: 8)),
            ],
          ),
          Iff(
            codepoint
                .gte(Const(0x800, width: 21))
                .and(codepoint.lte(Const(0xFFFF, width: 21))),
            then: [
              count.assign(Const(2, width: 2)),
              offset.assign(Const(0xE0, width: 8)),
            ],
          ),
          Iff(
            codepoint
                .gte(Const(0x10000, width: 21))
                .and(codepoint.lte(Const(0x10FFFF, width: 21))),
            then: [
              count.assign(Const(3, width: 2)),
              offset.assign(Const(0xF0, width: 8)),
            ],
          )
        ],
        orElse: [status.assign(Const(UTF8Encoder.statusFailure))],
      ),
      If(
        count.neq(Const(0, width: 2)),
        then: [
          byte.assign(
            codepoint
                .dsr(Const(6, width: 5).mul(Const(0, width: 3).cat(count)))
                .add(Const(0, width: 13).cat(offset))
                .part(7, 0),
          ),
          bytes.assign(Const(0, width: 24).cat(byte)),
          byte.assign(
            Const(0x80, width: 21)
                .or(
                  codepoint
                      .dsr(
                        Const(6, width: 4).mul(
                          Const(0, width: 2).cat(count.sub(Const(1, width: 2))),
                        ),
                      )
                      .and(Const(0x3F, width: 21)),
                )
                .part(7, 0),
          ),
          bytes.assign(bytes.part(31, 16).cat(byte).cat(bytes.part(7, 0))),
          count.assign(count.sub(Const(1, width: 2))),
          If(
            count.eq(Const(0, width: 2)),
            then: [status.assign(Const(UTF8Encoder.statusSuccess))],
            orElse: [
              byte.assign(
                Const(0x80, width: 21)
                    .or(
                      codepoint
                          .dsr(
                            Const(6, width: 3).mul(
                              Const(0).cat(count.sub(Const(1, width: 2))),
                            ),
                          )
                          .and(Const(0x3F, width: 21)),
                    )
                    .part(7, 0),
              ),
              bytes.assign(bytes.part(31, 24).cat(byte).cat(bytes.part(15, 0))),
              count.assign(count.sub(Const(1, width: 2))),
              If(
                count.eq(Const(0, width: 2)),
                then: [status.assign(Const(UTF8Encoder.statusSuccess))],
                orElse: [
                  byte.assign(
                    Const(0x80, width: 21)
                        .or(codepoint.and(Const(0x3F, width: 21)))
                        .part(7, 0),
                  ),
                  bytes.assign(byte.cat(bytes.part(23, 0))),
                  status.assign(Const(UTF8Encoder.statusSuccess))
                ],
              )
            ],
          )
        ],
      )
    ]);
  }

  // The output port is made a field of the class for convenience.
  // Use the `late` modifier to initialize a variable in the body of
  // the constructor (this can be useful for module parameterization).
  late final Var status;
  late final Var bytes;

  // Status indicating valid output.
  static const statusSuccess = 0;
  // An invalid code point was received. See "The Unicode Standard",
  // section 2.4 "Code Points and Characters".
  // Link: https://www.unicode.org/versions/latest/ch02.pdf
  static const statusFailure = 1;
}

// Here is a demo of code generation. The return value and the `noPrint`
// parameter are used for testing purposes, so this can be ignored.
String main({bool noPrint = false}) {
  // We instantiate the module and call the `emit` method to generate the
  // SystemVerilog code. We also pass the required `Var`s to the constructor
  // as "caps". The name of the module instance is omitted because it is
  // the top one in the hierarchy.
  final systemverilog =
      UTF8Encoder(Var(name: 'codepoint_cap', width: 21)).emit();

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
