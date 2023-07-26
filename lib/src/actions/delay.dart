import 'package:svart/src/actions/action.dart';

/// Delay operation.
class Delay extends Action {
  /// Creates a new delay [Action].
  ///
  /// The delay [value] must not be negative.
  Delay(this.value) {
    if (value < 0) {
      throw Exception('The delay value cannot be negative.');
    }
  }

  /// Value of delay.
  final int value;
}
