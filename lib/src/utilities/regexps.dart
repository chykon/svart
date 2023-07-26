/// A set of commonly used regular expressions.
abstract class RegExps {
  /// Regular expression to check if the module name is valid.
  static final moduleName = RegExp(r'^[_a-zA-Z][_a-zA-Z0-9]*$');

  /// Regular expression to check if the var name is valid.
  static final varName = moduleName;

  /// Regular expression to check if the file name is valid.
  static final fileName = RegExp(r'^[_a-zA-Z0-9][_a-zA-Z0-9./]*$');
}
