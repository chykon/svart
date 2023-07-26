import 'package:svart/src/actions/action.dart';
import 'package:svart/src/var.dart';

/// Assignment operation.
///
/// The type of assignment (blocking or non-blocking) is determined
/// by the type of procedure.
class Assignment extends Action {
  /// Creates a new assignment [Action].
  ///
  /// [destination] must not be [Const] or controlled by another signal.
  /// The widths of [destination] and [source] must match.
  Assignment(this.destination, this.source) {
    if (destination is Const) {
      throw Exception('"Const" cannot be a destination signal.');
    }
    if (destination.drivers.isNotEmpty) {
      throw Exception('The destination signal is already in control.');
    }
    if (destination.width != source.width) {
      throw Exception('Destination (${destination.width}) and '
          'source (${source.width}) widths do not match.');
    }
  }

  /// Destination signal (`LHS` in SystemVerilog).
  final Var destination;

  /// Source signal (`RHS` in SystemVerilog).
  final Var source;
}
