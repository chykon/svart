import 'dart:io';
import 'dart:math';
import 'package:test/test.dart';
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
    });
  });
}
