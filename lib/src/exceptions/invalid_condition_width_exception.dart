import 'package:meta/meta.dart';
import 'package:svart/src/exceptions/svart_exception.dart';

/// Exception indicating an attempt was made to use a multi-bit signal
/// as a condition.
@experimental
class InvalidConditionWidthException extends SvartException {
  /// Constructs an [InvalidConditionWidthException] with a standard message.
  InvalidConditionWidthException() : super('The condition width must be 1.');
}
