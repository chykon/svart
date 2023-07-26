import 'package:svart/src/actions/action.dart';
import 'package:svart/src/var.dart';

/// The operation of checking an expression for truth.
///
/// Maps to `assert` from SystemVerilog.
class Assert extends Action {
  /// Constructs an assertion that tests [condition] to be true.
  Assert(this.condition) {
    if (condition.width != 1) {
      throw Exception('The condition width must be 1.');
    }
  }

  /// Condition for successful execution of the assertion.
  final Var condition;
}
