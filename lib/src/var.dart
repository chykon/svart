import 'package:meta/meta.dart';
import 'package:svart/src/actions/assignment.dart';
import 'package:svart/src/utilities/keywords.dart';
import 'package:svart/src/utilities/regexps.dart';

/// The main element that performs the storage, transmission and
/// transformation of the signal.
class Var {
  /// Creates a new signal instance.
  Var({String? name, int width = 1})
      : this.full(name ?? '_var', width, [], Operation.none, []);

  /// Internal complete signal constructor.
  @internal
  Var.full(
    this.name,
    this.width,
    this.drivers,
    this.operation,
    this.parameters,
  ) {
    if (!RegExps.varName.hasMatch(name)) {
      throw Exception('Invalid signal name.');
    }
    if (Keywords.svDefault.contains(name)) {
      throw Exception('The signal name uses one of the reserved keywords.');
    }
    if (width < 1) {
      throw Exception('Invalid signal width.');
    }
  }

  /// Connects the output of the module.
  void to(Var destination) {
    final assignment = Assignment(destination, this);
    assignment.destination.drivers.add(assignment.source);
  }

  /// Assign the value of one signal to another.
  Assignment assign(Var source) {
    return Assignment(this, source);
  }

  /// Bitwise NOT.
  Var not() {
    return Var.full('_not', width, [this], Operation.not, []);
  }

  /// Bitwise AND.
  Var and(Var other) {
    return Var.full(
      '_and',
      (width == other.width) ? width : throw Exception('Widths are not equal.'),
      [this, other],
      Operation.and,
      [],
    );
  }

  /// Bitwise OR.
  Var or(Var other) {
    return Var.full(
      '_or',
      (width == other.width) ? width : throw Exception('Widths are not equal.'),
      [this, other],
      Operation.or,
      [],
    );
  }

  /// Logical (unsigned) shift left.
  Var sl(int shamt) {
    if ((shamt < 1) || (shamt > width)) {
      throw Exception('Shamt cannot be less than 1 or greater than $width.');
    }
    return Var.full('_sl', width, [this], Operation.sl, [shamt]);
  }

  /// Logical (unsigned) shift right.
  Var sr(int shamt) {
    if ((shamt < 1) || (shamt > width)) {
      throw Exception('Shamt cannot be less than 1 or greater than $width.');
    }
    return Var.full('_sr', width, [this], Operation.sr, [shamt]);
  }

  /// Logical (unsigned) dynamic shift left.
  Var dsl(Var shamter) {
    return Var.full('_dsl', width, [this, shamter], Operation.dsl, []);
  }

  /// Logical (unsigned) dynamic shift right.
  Var dsr(Var shamter) {
    return Var.full('_dsr', width, [this, shamter], Operation.dsr, []);
  }

  /// Select part of the signal.
  ///
  /// SystemVerilog does not allow one-to-one mapping of such
  /// operations in all cases.
  Var part(int msbIndex, int lsbIndex) {
    if ((msbIndex < 0) || (msbIndex >= width)) {
      throw Exception(
        'MSB cannot be less than 0 or greater than ${width - 1}.',
      );
    }
    if ((lsbIndex < 0) || (lsbIndex >= width)) {
      throw Exception(
        'LSB cannot be less than 0 or greater than ${width - 1}.',
      );
    }
    if (msbIndex < lsbIndex) {
      throw Exception('MSB cannot be less than LSB');
    }
    return Var.full(
      '_part',
      (msbIndex - lsbIndex) + 1,
      [this],
      Operation.part,
      [msbIndex, lsbIndex],
    );
  }

  /// Catenate signals.
  Var cat(Var other) {
    return Var.full(
      '_cat',
      width + other.width,
      [this, other],
      Operation.cat,
      [],
    );
  }

  /// Equal.
  Var eq(Var other) {
    if (width != other.width) {
      throw Exception('Widths are not equal.');
    }
    return Var.full('_eq', 1, [this, other], Operation.eq, []);
  }

  /// Not equal.
  Var neq(Var other) {
    if (width != other.width) {
      throw Exception('Widths are not equal.');
    }
    return Var.full('_neq', 1, [this, other], Operation.neq, []);
  }

  /// Less than (unsigned).
  Var lt(Var other) {
    if (width != other.width) {
      throw Exception('Widths are not equal.');
    }
    return Var.full('_lt', 1, [this, other], Operation.lt, []);
  }

  /// Greater than (unsigned).
  Var gt(Var other) {
    if (width != other.width) {
      throw Exception('Widths are not equal.');
    }
    return Var.full('_gt', 1, [this, other], Operation.gt, []);
  }

  /// Less than or equal (unsigned).
  Var lte(Var other) {
    if (width != other.width) {
      throw Exception('Widths are not equal.');
    }
    return Var.full('_lte', 1, [this, other], Operation.lte, []);
  }

  /// Greater than or equal (unsigned).
  Var gte(Var other) {
    if (width != other.width) {
      throw Exception('Widths are not equal.');
    }
    return Var.full('_gte', 1, [this, other], Operation.gte, []);
  }

  /// Addition.
  Var add(Var other) {
    return Var.full(
      '_add',
      (width == other.width) ? width : throw Exception('Widths are not equal.'),
      [this, other],
      Operation.add,
      [],
    );
  }

  /// Subtraction.
  Var sub(Var other) {
    return Var.full(
      '_sub',
      (width == other.width) ? width : throw Exception('Widths are not equal.'),
      [this, other],
      Operation.sub,
      [],
    );
  }

  /// Multiplication.
  Var mul(Var other) {
    return Var.full(
      '_mul',
      (width == other.width) ? width : throw Exception('Widths are not equal.'),
      [this, other],
      Operation.mul,
      [],
    );
  }

  /// Signal name.
  final String name;

  /// Signal width.
  final int width;

  /// List of drivers.
  final List<Var> drivers;

  /// Operation type.
  final Operation operation;

  /// List of [operation] parameters.
  final List<int> parameters;
}

/// Immediate signal value.
class Const extends Var {
  /// Creates a new signal immediate value.
  ///
  /// The signal [value] must not be truncated due to the [width].
  Const(this.value, {int width = 1})
      : super.full('_const', width, [], Operation.none, []) {
    if (value < 0) {
      throw Exception('The value must be non-negative.');
    }
    final requiredWidth =
        value.toRadixString(2).split('').reversed.join().lastIndexOf('1') + 1;
    if (requiredWidth > width) {
      throw Exception('The value ($value) must not be truncated: '
          '$requiredWidth bits required, $width bits specified');
    }
  }

  /// Signal value.
  final int value;
}

/// Varia operation type.
enum Operation {
  /// Operation `none`.
  none,

  /// Operation `not`.
  not,

  /// Operation `and`.
  and,

  /// Operation `or`.
  or,

  /// Operation `sl`.
  sl,

  /// Operation `sr`.
  sr,

  /// Operation `dsl`.
  dsl,

  /// Operation `dsr`.
  dsr,

  /// Operation `part`.
  part,

  /// Operation `cat`.
  cat,

  /// Operation `eq`.
  eq,

  /// Operation `neq`.
  neq,

  /// Operation `lt`.
  lt,

  /// Operation `gt`.
  gt,

  /// Operation `lte`.
  lte,

  /// Operation `gte`.
  gte,

  /// Operation `add`.
  add,

  /// Operation `sub`.
  sub,

  /// Operation `mul`.
  mul
}
