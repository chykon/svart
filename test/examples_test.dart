import 'dart:io';
import 'dart:math';
import 'package:test/test.dart';
import '../example/bsm1e/example.dart' as bsm1e_testbench;
import '../example/bsm1e/src/bsm1e.dart' as bsm1e_core;
import '../example/bsm1e/src/units/arithmetic_logic_unit.dart' as bsm1e_alu;
import '../example/bsm1e/src/units/control_flow_unit.dart' as bsm1e_cfu;
import '../example/bsm1e/src/units/instruction_fetch_unit.dart' as bsm1e_ifu;
import '../example/bsm1e/src/units/literal_unit.dart' as bsm1e_lu;
import '../example/bsm1e/src/units/load_store_unit.dart' as bsm1e_lsu;
import '../example/bsm1e/src/units/memory_unit.dart' as bsm1e_mu;
import '../example/bsm1e/src/units/register_file_unit.dart' as bsm1e_rfu;
import '../example/bsm1e/src/units/socket_array_unit.dart' as bsm1e_sau;
import '../example/example.dart' as counter4bit;
import '../example/example_testbench.dart' as counter4bit_testbench;
import '../example/mux2to1.dart' as mux2to1;
import '../example/mux2to1_testbench.dart' as mux2to1_testbench;
import '../example/utf8decoder.dart' as utf8decoder;
import '../example/utf8decoder_testbench.dart' as utf8decoder_testbench;
import '../example/utf8encoder.dart' as utf8encoder;
import '../example/utf8encoder_testbench.dart' as utf8encoder_testbench;

void main() {
  group('example:', () {
    const goldPath = 'test/gold';

    group('module works correctly:', () {
      test('Mux2to1', () {
        expect(
          mux2to1.main(noPrint: true),
          equals(File('$goldPath/mux2to1.sv').readAsStringSync()),
        );
      });

      test('Counter4Bit', () {
        expect(
          counter4bit.main(noPrint: true),
          equals(File('$goldPath/counter4bit.sv').readAsStringSync()),
        );
      });

      test('UTF8Encoder', () {
        expect(
          utf8encoder.main(noPrint: true),
          equals(File('$goldPath/utf8encoder.sv').readAsStringSync()),
        );
      });

      test('UTF8Decoder', () {
        expect(
          utf8decoder.main(noPrint: true),
          equals(File('$goldPath/utf8decoder.sv').readAsStringSync()),
        );
      });

      group('BSM1E:', () {
        test('ArithmeticLogicUnit', () {
          expect(
            bsm1e_alu.main(noPrint: true),
            equals(
              File('$goldPath/bsm1e/arithmetic_logic_unit.sv')
                  .readAsStringSync(),
            ),
          );
        });
        test('ControlFlowUnit', () {
          expect(
            bsm1e_cfu.main(noPrint: true),
            equals(
              File('$goldPath/bsm1e/control_flow_unit.sv').readAsStringSync(),
            ),
          );
        });
        test('InstructionFetchUnit', () {
          expect(
            bsm1e_ifu.main(noPrint: true),
            equals(
              File('$goldPath/bsm1e/instruction_fetch_unit.sv')
                  .readAsStringSync(),
            ),
          );
        });
        test('LiteralUnit', () {
          expect(
            bsm1e_lu.main(noPrint: true),
            equals(
              File('$goldPath/bsm1e/literal_unit.sv').readAsStringSync(),
            ),
          );
        });
        test('LoadStoreUnit', () {
          expect(
            bsm1e_lsu.main(noPrint: true),
            equals(
              File('$goldPath/bsm1e/load_store_unit.sv').readAsStringSync(),
            ),
          );
        });
        test('MemoryUnit', () {
          expect(
            bsm1e_mu.main(noPrint: true),
            equals(
              File('$goldPath/bsm1e/memory_unit.sv').readAsStringSync(),
            ),
          );
        });
        test('RegisterFileUnit', () {
          expect(
            bsm1e_rfu.main(noPrint: true),
            equals(
              File('$goldPath/bsm1e/register_file_unit.sv').readAsStringSync(),
            ),
          );
        });
        test('SocketArrayUnit', () {
          expect(
            bsm1e_sau.main(noPrint: true),
            equals(
              File('$goldPath/bsm1e/socket_array_unit.sv').readAsStringSync(),
            ),
          );
        });
        test('Core', () {
          expect(
            bsm1e_core.main(noPrint: true),
            equals(
              File('$goldPath/bsm1e/bsm1e.sv').readAsStringSync(),
            ),
          );
        });
      });
    });

    group('testbench works correctly:', () {
      ({
        String pathBase,
        String vcdFileName,
        String svFileName,
        String vvpFileName
      }) generateUniquePaths() {
        final pathBase = 'test/_tmp/'
            '${DateTime.timestamp().millisecondsSinceEpoch}_'
            '${Random().nextInt(pow(2, 32).toInt())}';

        final vcdFileName = '$pathBase/dump.vcd';
        final svFileName = '$pathBase/out.sv';
        final vvpFileName = '$pathBase/out.vvp';

        return (
          pathBase: pathBase,
          vcdFileName: vcdFileName,
          svFileName: svFileName,
          vvpFileName: vvpFileName
        );
      }

      test('Mux2to1Testbench', () {
        final paths = generateUniquePaths();

        addTearDown(() {
          File(paths.pathBase).deleteSync(recursive: true);
        });

        final result = mux2to1_testbench.main(
          noPrint: true,
          vcdFileName: paths.vcdFileName,
          svFileName: paths.svFileName,
          vvpFileName: paths.vvpFileName,
        );

        expect(
          File(paths.svFileName).readAsStringSync(),
          equals(
            File('$goldPath/mux2to1_testbench.sv')
                .readAsStringSync()
                // We need to modify the gold file a bit since the dump file
                // path is generated dynamically.
                .replaceFirst('"dump.vcd"', '"${paths.vcdFileName}"'),
          ),
        );

        expect(File(paths.vcdFileName).existsSync(), equals(true));

        expect(result.stdoutCompile.isEmpty, equals(true));
        expect(result.stderrCompile.isEmpty, equals(true));
        expect(result.stdoutRun.isEmpty, equals(true));
        expect(result.stderrRun.isEmpty, equals(true));
      });

      test('Counter4BitTestbench', () {
        final paths = generateUniquePaths();

        addTearDown(() {
          File(paths.pathBase).deleteSync(recursive: true);
        });

        final result = counter4bit_testbench.main(
          noPrint: true,
          vcdFileName: paths.vcdFileName,
          svFileName: paths.svFileName,
          vvpFileName: paths.vvpFileName,
        );

        expect(
          File(paths.svFileName).readAsStringSync(),
          equals(
            File('$goldPath/counter4bit_testbench.sv')
                .readAsStringSync()
                // We need to modify the gold file a bit since the dump file
                // path is generated dynamically.
                .replaceFirst('"dump.vcd"', '"${paths.vcdFileName}"'),
          ),
        );

        expect(File(paths.vcdFileName).existsSync(), equals(true));

        expect(result.stdoutCompile.isEmpty, equals(true));
        expect(result.stderrCompile.isEmpty, equals(true));
        expect(result.stdoutRun.isEmpty, equals(true));
        expect(result.stderrRun.isEmpty, equals(true));
      });

      test('UTF8EncoderTestbench', () {
        final paths = generateUniquePaths();

        addTearDown(() {
          File(paths.pathBase).deleteSync(recursive: true);
        });

        final result = utf8encoder_testbench.main(
          noPrint: true,
          vcdFileName: paths.vcdFileName,
          svFileName: paths.svFileName,
          vvpFileName: paths.vvpFileName,
        );

        expect(File(paths.vcdFileName).existsSync(), equals(true));

        expect(result.stdoutCompile.isEmpty, equals(true));
        expect(result.stderrCompile.isEmpty, equals(true));
        expect(result.stdoutRun.isEmpty, equals(true));
        expect(result.stderrRun.isEmpty, equals(true));
      });

      test('UTF8DecoderTestbench', () {
        final paths = generateUniquePaths();

        addTearDown(() {
          File(paths.pathBase).deleteSync(recursive: true);
        });

        final result = utf8decoder_testbench.main(
          noPrint: true,
          vcdFileName: paths.vcdFileName,
          svFileName: paths.svFileName,
          vvpFileName: paths.vvpFileName,
        );

        expect(File(paths.vcdFileName).existsSync(), equals(true));

        expect(result.stdoutCompile.isEmpty, equals(true));
        expect(result.stderrCompile.isEmpty, equals(true));
        expect(result.stdoutRun.isEmpty, equals(true));
        expect(result.stderrRun.isEmpty, equals(true));
      });

      test('BSM1ETestbench', () {
        final paths = generateUniquePaths();

        addTearDown(() {
          File(paths.pathBase).deleteSync(recursive: true);
        });

        final result = bsm1e_testbench.main(
          noPrint: true,
          vcdFileName: paths.vcdFileName,
          svFileName: paths.svFileName,
          vvpFileName: paths.vvpFileName,
        );

        expect(File(paths.vcdFileName).existsSync(), equals(true));

        expect(result.stdoutCompile.isEmpty, equals(true));
        expect(result.stderrCompile.isEmpty, equals(true));
        expect(result.stdoutRun.isEmpty, equals(true));
        expect(result.stderrRun.isEmpty, equals(true));
      });
    });
  });
}
