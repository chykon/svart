import 'package:meta/meta.dart';

/// Base class for Svart exceptions.
@experimental
abstract class SvartException implements Exception {
  /// Constructs an exception with a [message].
  SvartException(this.message);

  /// Exception message.
  final String message;
}
