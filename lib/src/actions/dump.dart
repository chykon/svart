import 'package:svart/src/actions/action.dart';
import 'package:svart/src/utilities/keywords.dart';
import 'package:svart/src/utilities/regexps.dart';

/// Signal dumping [Action].
class Dump extends Action {
  /// Provides saving of the timing diagram.
  ///
  /// The timing diagram is created for the module named [moduleName] and
  /// stored in a file named [fileName]. The format used is `VCD`.
  Dump({required this.moduleName, this.fileName = 'dump.vcd'}) {
    if (!RegExps.moduleName.hasMatch(moduleName)) {
      throw Exception('Invalid module name.');
    }
    if (Keywords.svDefault.contains(moduleName)) {
      throw Exception('The module name uses one of the reserved keywords.');
    }
    if (!RegExps.fileName.hasMatch(fileName)) {
      throw Exception('Invalid file name.');
    }
  }

  /// The module whose signals will be dumped.
  final String moduleName;

  /// The name of the file where the dumped signals will be saved.
  final String fileName;
}
