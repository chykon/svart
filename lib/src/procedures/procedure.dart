import 'package:svart/src/actions/action.dart';

/// Base class for procedures.
abstract class Procedure {
  /// Constructs a [Procedure] with a list of [Action]s.
  ///
  /// Throws [Exception] if the list of [Action]s is empty.
  Procedure(this.actions) {
    if (actions.isEmpty) {
      throw Exception('The list of actions must not be empty.');
    }
  }

  /// List of procedure [Action]s.
  final List<Action> actions;
}
