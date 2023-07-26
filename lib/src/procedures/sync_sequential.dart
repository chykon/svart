import 'package:svart/src/procedures/procedure.dart';
import 'package:svart/src/var.dart';

/// Represents a sequential synchronous logic block.
///
/// Maps to the procedure `always_ff` from SystemVerilog.
class SyncSequential extends Procedure {
  /// Constructs a [SyncSequential] procedure whose [actions] list
  /// execution starts after [event] occurs.
  ///
  /// Assignments are made parallel.
  SyncSequential(this.event, super.actions);

  /// An event that triggers procedure execution.
  final Edge event;
}

/// Represents a clock change event wait block from `0` to `1` (positive edge).
///
/// Maps to `@(posedge ...)` from SystemVerilog.
class PosEdge extends Edge {
  /// Constructs an [PosEdge] event, where [source] specifies the
  /// source of the event.
  PosEdge(super.source);
}

/// The base class of the activation event of the sequential logic block.
abstract class Edge {
  /// Constructs an [Edge] event, where [source] specifies the
  /// source of the event.
  ///
  /// The [source] signal must not be [Const] and must have a width of 1.
  Edge(this.source) {
    if (source is Const) {
      throw Exception('"Const" cannot be a clock signal.');
    }
    if (source.width != 1) {
      throw Exception('The clock signal width must be 1.');
    }
  }

  /// Event source.
  final Var source;
}
