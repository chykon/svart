// An example of UTF-8 decoder (converting UTF-8 to Unicode code points).
// The implementation relies on the "WHATWG: Encoding - UTF-8 decoder"
// specification. Link: https://encoding.spec.whatwg.org/#utf-8-decoder
//
// Interface:
//   inputs:
//     clock     - 1 bit
//     reset     - 1 bit
//     enable    - 1 bit
//     byte      - 8 bits
//   outputs:
//     status    - 3 bits
//     codepoint - 21 bits

// Import the `Svart` package.
import 'package:svart/svart.dart';

// We extend the base class `Module`. This is our main block
// for building circuits.
class UTF8Decoder extends Module {
  // The constructor is useful for fully defining a module in one place.
  // The `clock`, `reset`, `enable` and `byte` constructor parameters are input
  // ports and are used to easily connect to other modules. The `name`
  // parameter is used to specify the name of the module instance and may
  // be omitted.
  UTF8Decoder(Var clock, Var reset, Var enable, Var byte, {String? name})
      // Specifying the module definition name is required. In this case,
      // we pass it as a string directly to the parent class constructor.
      : super(definitionName: 'utf8decoder', instanceName: name) {
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
    byte = addInput('octet', byte, width: 8);
    // We add module outputs using the `addOutput` method, which is a
    // bit like `addInput`.
    status = addOutput('status', width: 3);
    codepoint = addOutput('codepoint', width: 21);

    // We add internal `Var`s using the `addInternal` method.
    final bytesSeen = addInternal(name: 'bytes_seen', width: 2);
    final bytesNeeded = addInternal(name: 'bytes_needed', width: 2);
    final lowerBoundary = addInternal(name: 'lower_boundary', width: 8);
    final upperBoundary = addInternal(name: 'upper_boundary', width: 8);

    // Adding a synchronous sequential logic block.
    //
    // The synchronous logic has a state that is updated when the clock changes
    // (in this case, when the clock goes from "0" to "1").
    addSyncSequential(PosEdge(clock), [
      If(
        reset,
        then: [
          codepoint.assign(Const(0, width: 21)),
          bytesSeen.assign(Const(0, width: 2)),
          bytesNeeded.assign(Const(0, width: 2)),
          lowerBoundary.assign(Const(0x80, width: 8)),
          upperBoundary.assign(Const(0xBF, width: 8)),
          status.assign(Const(UTF8Decoder.statusInitial, width: 3))
        ],
        orElse: [
          If(
            enable,
            then: [
              If(
                bytesNeeded.eq(Const(0, width: 2)),
                then: [
                  When(
                    [
                      Iff(
                        byte
                            .gte(Const(0, width: 8))
                            .and(byte.lte(Const(0x7F, width: 8))),
                        then: [
                          codepoint.assign(Const(0, width: 13).cat(byte)),
                          status.assign(
                            Const(UTF8Decoder.statusSuccess, width: 3),
                          )
                        ],
                      ),
                      Iff(
                        byte
                            .gte(Const(0xC2, width: 8))
                            .and(byte.lte(Const(0xDF, width: 8))),
                        then: [
                          bytesNeeded.assign(Const(1, width: 2)),
                          codepoint.assign(
                            Const(0, width: 13)
                                .cat(byte.and(Const(0x1F, width: 8))),
                          ),
                          status.assign(
                            Const(UTF8Decoder.statusInprocess, width: 3),
                          )
                        ],
                      ),
                      Iff(
                        byte
                            .gte(Const(0xE0, width: 8))
                            .and(byte.lte(Const(0xEF, width: 8))),
                        then: [
                          If(
                            byte.eq(Const(0xE0, width: 8)),
                            then: [lowerBoundary.assign(Const(0xA0, width: 8))],
                            orElse: [
                              If(
                                byte.eq(Const(0xED, width: 8)),
                                then: [
                                  upperBoundary.assign(Const(0x9F, width: 8))
                                ],
                              )
                            ],
                          ),
                          bytesNeeded.assign(Const(2, width: 2)),
                          codepoint.assign(
                            Const(0, width: 13)
                                .cat(byte.and(Const(0xF, width: 8))),
                          ),
                          status.assign(
                            Const(UTF8Decoder.statusInprocess, width: 3),
                          )
                        ],
                      ),
                      Iff(
                        byte
                            .gte(Const(0xF0, width: 8))
                            .and(byte.lte(Const(0xF4, width: 8))),
                        then: [
                          If(
                            byte.eq(Const(0xF0, width: 8)),
                            then: [lowerBoundary.assign(Const(0x90, width: 8))],
                            orElse: [
                              If(
                                byte.eq(Const(0xF4, width: 8)),
                                then: [
                                  upperBoundary.assign(Const(0x8F, width: 8))
                                ],
                              )
                            ],
                          ),
                          bytesNeeded.assign(Const(3, width: 2)),
                          codepoint.assign(
                            Const(0, width: 13)
                                .cat(byte.and(Const(0x7, width: 8))),
                          ),
                          status.assign(
                            Const(UTF8Decoder.statusInprocess, width: 3),
                          )
                        ],
                      )
                    ],
                    orElse: [
                      status.assign(Const(UTF8Decoder.statusFailure, width: 3))
                    ],
                  )
                ],
                orElse: [
                  If(
                    byte.gte(lowerBoundary).and(byte.lte(upperBoundary)),
                    then: [
                      lowerBoundary.assign(Const(0x80, width: 8)),
                      upperBoundary.assign(Const(0xBF, width: 8)),
                      codepoint.assign(
                        codepoint.sl(6).or(
                              Const(0, width: 13)
                                  .cat(byte.and(Const(0x3F, width: 8))),
                            ),
                      ),
                      If(
                        bytesSeen.add(Const(1, width: 2)).eq(bytesNeeded),
                        then: [
                          bytesNeeded.assign(Const(0, width: 2)),
                          bytesSeen.assign(Const(0, width: 2)),
                          status.assign(
                            Const(UTF8Decoder.statusSuccess, width: 3),
                          )
                        ],
                        orElse: [
                          bytesSeen.assign(bytesSeen.add(Const(1, width: 2)))
                        ],
                      )
                    ],
                    orElse: [
                      codepoint.assign(Const(0, width: 21)),
                      bytesNeeded.assign(Const(0, width: 2)),
                      bytesSeen.assign(Const(0, width: 2)),
                      lowerBoundary.assign(Const(0x80, width: 8)),
                      upperBoundary.assign(Const(0xBF, width: 8)),
                      status.assign(
                        Const(UTF8Decoder.statusFailureRepeat, width: 3),
                      )
                    ],
                  )
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
  late final Var codepoint;

  // Status after reset.
  static const statusInitial = 0;
  // The code point is not ready.
  static const statusInprocess = 1;
  // The code point is ready.
  static const statusSuccess = 2;
  // Bad byte received.
  static const statusFailure = 3;
  // Bad byte received. It is necessary to repeat the transmission
  // of the last byte.
  static const statusFailureRepeat = 4;
}

// Here is a demo of code generation. The return value and the `noPrint`
// parameter are used for testing purposes, so this can be ignored.
String main({bool noPrint = false}) {
  // We instantiate the module and call the `emit` method to generate the
  // SystemVerilog code. We also pass the required `Var`s to the constructor
  // as "caps". The name of the module instance is omitted because it is
  // the top one in the hierarchy.
  final systemverilog = UTF8Decoder(Var(), Var(), Var(), Var(width: 8)).emit();

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
