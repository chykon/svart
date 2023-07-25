import 'package:svart/src/actions/action.dart';
import 'package:svart/src/procedures/procedure.dart';

/// Represents a combinational logic block.
///
/// Maps to the procedure `always_comb` from SystemVerilog.
class Combinational extends Procedure {
  /// Constructs a [Combinational] with a list of [Action]s.
  ///
  /// Assignments are made sequentially.
  ///
  /// Throws [Exception] if the list of [Action]s is empty.
  Combinational(super.actions);
}
