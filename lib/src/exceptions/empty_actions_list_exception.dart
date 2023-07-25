import 'package:meta/meta.dart';
import 'package:svart/src/actions/action.dart';
import 'package:svart/src/exceptions/svart_exception.dart';

/// An exception that indicates the presence of empty [Action] lists
/// in the circuit description.
@experimental
class EmptyActionsListException extends SvartException {
  /// Constructs an [EmptyActionsListException] with a standard message.
  EmptyActionsListException() : super('The list of actions must not be empty.');
}
