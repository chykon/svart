import 'package:meta/meta.dart';
import 'package:svart/src/exceptions/svart_exception.dart';

/// Exception indicating an attempt was made to use a multi-bit signal
/// as a clock.
@experimental
class InvalidClockWidthException extends SvartException {
  /// Constructs an [InvalidClockWidthException] with a standard message.
  InvalidClockWidthException() : super('The clock signal width must be 1.');
}
