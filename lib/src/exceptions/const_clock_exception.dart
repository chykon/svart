import 'package:meta/meta.dart';
import 'package:svart/src/exceptions/svart_exception.dart';
import 'package:svart/src/var.dart';

/// Exception indicating an attempt to use [Const] as a clock signal.
@experimental
class ConstClockException extends SvartException {
  /// Constructs an [ConstClockException] with a standard message.
  ConstClockException() : super('"Const" cannot be a clock signal.');
}
