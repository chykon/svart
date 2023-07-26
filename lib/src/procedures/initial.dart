import 'package:svart/src/actions/action.dart';
import 'package:svart/src/procedures/procedure.dart';

/// Represents a initial logic block.
///
/// Maps to the procedure `initial` from SystemVerilog.
class Initial extends Procedure {
  /// Constructs a [Initial] with a list of [Action]s.
  ///
  /// Assignments are made sequentially.
  ///
  /// Throws [Exception] if the list of [Action]s is empty.
  Initial(super.actions);
}
