import 'package:meta/meta.dart';
import 'package:svart/src/exceptions/svart_exception.dart';

/// An exception indicating that the destination signal is
/// already being controlled.
@experimental
class DrivableDestinationException extends SvartException {
  /// Constructs an [DrivableDestinationException] with a standard message.
  DrivableDestinationException()
      : super('The destination signal is already in control.');
}
