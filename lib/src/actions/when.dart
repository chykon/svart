import 'package:svart/src/actions/action.dart';
import 'package:svart/src/var.dart';

/// Branching with multiple conditions.
class When extends Action {
  /// Creates a branch with multiple conditions.
  ///
  /// Generated SystemVerilog code:
  ///
  /// ```systemverilog
  /// if (iff0_condition) begin
  ///   // "iff0_then" actions
  /// end else if (iff1_condition) begin
  ///   // "iff1_then" actions
  /// end else begin
  ///   // "orElse" actions
  /// end
  /// ```
  When(this.iffs, {List<Action>? orElse}) : elseActions = orElse {
    if (iffs.isEmpty) {
      throw Exception('The list of "iffs" must not be empty.');
    }
    if (elseActions != null) {
      if (elseActions!.isEmpty) {
        throw Exception('The "orElse" branch has an empty action list.');
      }
    }
  }

  /// List of [Iff]s branches.
  final List<Iff> iffs;

  /// List of [Action]s to be performed if the conditions of all branches
  /// are false.
  final List<Action>? elseActions;
}

/// One of the branches of the [When] action.
class Iff {
  /// Creates a [When] action branch.
  Iff(this.condition, {required List<Action> then}) : actions = then {
    if (condition.width != 1) {
      throw Exception('The condition width must be 1.');
    }
    if (actions.isEmpty) {
      throw Exception('The list of actions must not be empty.');
    }
  }

  /// The condition to be checked.
  final Var condition;

  /// List of actions.
  final List<Action> actions;
}
