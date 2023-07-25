import 'package:meta/meta.dart';
import 'package:svart/src/exceptions/svart_exception.dart';
import 'package:svart/src/var.dart';

/// Exception indicating an attempt to use [Const] as a destination signal.
@experimental
class ConstDestinationException extends SvartException {
  /// Constructs an [ConstDestinationException] with a standard message.
  ConstDestinationException()
      : super('"Const" cannot be a destination signal.');
}
