import 'package:svart/src/actions/action.dart';
import 'package:svart/src/var.dart';

/// Conditional branch [Action].
class If extends Action {
  /// Creates a new conditional branch [Action].
  ///
  /// Generated SystemVerilog code:
  ///
  /// ```systemverilog
  /// if (condition) begin
  ///   // "then" actions
  /// end else begin
  ///   // "orElse" actions
  /// end
  /// ```
  If(this.condition, {required List<Action> then, List<Action>? orElse})
      : thenActions = then,
        elseActions = orElse {
    if (condition.width != 1) {
      throw Exception('The condition width must be 1.');
    }
    if (thenActions.isEmpty) {
      throw Exception('The "then" branch has an empty action list.');
    }
    if (elseActions != null) {
      if (elseActions!.isEmpty) {
        throw Exception('The "orElse" branch has an empty action list.');
      }
    }
  }

  /// The condition to be checked.
  final Var condition;

  /// List of actions of the `then` branch.
  final List<Action> thenActions;

  /// List of actions of the `orElse` branch.
  final List<Action>? elseActions;
}
