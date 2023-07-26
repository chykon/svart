import 'dart:io';

/// A set of various external tools.
abstract class Tools {
  /// The ICARUS Verilog Compilation System.
  ///
  /// Version `12.0` is recommended.
  static final iverilog = IcarusVerilog();
}

/// The ICARUS Verilog Compilation System.
class IcarusVerilog {
  /// Use `iverilog` for compilation.
  ({String stdout, String stderr}) compile(
    String inputFile,
    String topModule, {
    String outputFile = 'out.vvp',
  }) {
    // Information about flags is available at
    // https://steveicarus.github.io/iverilog/usage/command_line_flags.html
    final setup = [
      '-g2012',
      '-gio-range-error',
      '-gstrict-ca-eval',
      '-gstrict-expr-width',
      '-gno-shared-loop-index',
      '-u',
      '-Wall',
      '-Wmacro-redefinition',
      '-Winfloop',
      '-Wsensitivity-entire-vector',
      '-Wfloating-nets',
      '-s$topModule'
    ];
    final result =
        Process.runSync('iverilog', [...setup, inputFile, '-o$outputFile']);
    final String returnStdout;
    if ((result.stdout as String).isNotEmpty) {
      // ignore: avoid_print
      print(result.stdout);
      returnStdout = result.stdout as String;
    } else {
      returnStdout = '';
    }
    final String returnStderr;
    if ((result.stderr as String).isNotEmpty) {
      final stderr = (result.stderr as String).split('\n').where((string) {
        if (RegExp('^.+:[1-9][0-9]*: sorry: constant selects in '
                'always_[*] processes are not currently supported '
                r'[(]all bits will be included[)][.]$')
            .hasMatch(string)) {
          return false;
        }
        return true;
      }).join('\n');
      if (stderr.isNotEmpty) {
        // ignore: avoid_print
        print(stderr);
        returnStderr = stderr;
      } else {
        returnStderr = '';
      }
    } else {
      returnStderr = '';
    }
    if (result.exitCode != 0) {
      throw Exception('"iverilog" exit code: ${result.exitCode}');
    }
    return (stdout: returnStdout, stderr: returnStderr);
  }

  /// Use `vvp` for simulation.
  ({String stdout, String stderr}) run({String file = 'out.vvp'}) {
    final result = Process.runSync('vvp', [file]);
    final String returnStdout;
    if ((result.stdout as String).isNotEmpty) {
      if (!RegExp(r'^VCD info: dumpfile .+ opened for output[.]\n$')
          .hasMatch(result.stdout as String)) {
        // ignore: avoid_print
        print(result.stdout);
        returnStdout = result.stdout as String;
      } else {
        returnStdout = '';
      }
    } else {
      returnStdout = '';
    }
    final String returnStderr;
    if ((result.stderr as String).isNotEmpty) {
      // ignore: avoid_print
      print(result.stderr);
      returnStderr = result.stderr as String;
    } else {
      returnStderr = '';
    }
    if (result.exitCode != 0) {
      throw Exception('"vvp" exit code: ${result.exitCode}');
    }
    return (stdout: returnStdout, stderr: returnStderr);
  }
}
