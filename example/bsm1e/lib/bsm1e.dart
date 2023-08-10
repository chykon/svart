import 'package:svart/svart.dart';

import 'src/arithmetic_logic_unit.dart';
import 'src/control_flow_unit.dart';
import 'src/instruction_fetch_unit.dart';
import 'src/literal_unit.dart';
import 'src/load_store_unit.dart';
import 'src/memory_unit.dart';
import 'src/register_file_unit.dart';
import 'src/socket_array_unit.dart';

class BSM1E extends Module {
  BSM1E(Var clock, Var reset) : super(definitionName: 'bsm1e') {
    clock = addInput('clock', clock);
    reset = addInput('reset', reset);

    final currentState = addInternal(name: 'current_state');
    final nextState = addInternal(name: 'next_state');

    final alu = (
      to: (
        act: addInternal(name: 'act', width: 2),
        data: addInternal(name: 'data', width: 8)
      ),
      from: (result: addInternal(name: 'result', width: 8))
    );
    final cfu = (
      to: (
        act: addInternal(name: 'act', width: 3),
        data: addInternal(name: 'data', width: 8),
        resetBranch: addInternal(name: 'reset_branch'),
        currentAddress: addInternal(name: 'current_address', width: 15)
      ),
      from: (
        branch: addInternal(name: 'branch'),
        branchAddress: addInternal(name: 'branch_address', width: 15)
      )
    );
    final ifu = (
      to: (
        jump: addInternal(name: 'jump'),
        jumpAddress: addInternal(name: 'jump_address', width: 15),
        next: addInternal(name: 'next')
      ),
      from: (currentAddress: addInternal(name: 'current_address', width: 15))
    );
    final lu = (
      to: (
        write: addInternal(name: 'write'),
        inputValue: addInternal(name: 'input_value', width: 8)
      ),
      from: (outputValue: addInternal(name: 'output_value', width: 8))
    );
    final lsu = (
      to: (
        act: addInternal(name: 'act', width: 3),
        data: addInternal(name: 'data', width: 8),
        resetMemoryAccess: addInternal(name: 'reset_branch'),
        memoryData: addInternal(name: 'current_address', width: 15)
      ),
      from: (
        memoryAccess: (
          load: (
            byte: addInternal(name: 'memory_access_load_byte'),
            halfword: addInternal(name: 'memory_access_load_halfword')
          ),
          store: (
            byte: addInternal(name: 'memory_access_store_byte'),
            halfword: addInternal(name: 'memory_access_store_halfword')
          )
        ),
        targetAddress: addInternal(name: 'target_address', width: 16),
        targetData: addInternal(name: 'target_data', width: 16)
      )
    );
    final mu = (
      to: (
        write: addInternal(name: 'write'),
        selectByte: addInternal(name: 'select_byte'),
        address: addInternal(name: 'address', width: 16),
        inputData: addInternal(name: 'input_data', width: 16)
      ),
      from: (outputData: addInternal(name: 'output_data', width: 16))
    );
    final rfu = (
      to: (
        write: addInternal(name: 'write'),
        address: addInternal(name: 'address', width: 7),
        inputData: addInternal(name: 'input_data', width: 8)
      ),
      from: (outputData: addInternal(name: 'output_data', width: 8))
    );
    final sau = (
      to: (instruction: addInternal(name: 'instruction', width: 16),),
      from: (illegalInstruction: addInternal(name: 'illegal_instruction'))
    );

    addSubmodule(
      ArithmeticLogicUnit(clock, alu.to.act, alu.to.data)
        ..result.to(alu.from.result),
    );
    addSubmodule(
      ControlFlowUnit(
        clock,
        cfu.to.act,
        cfu.to.data,
        cfu.to.resetBranch,
        cfu.to.currentAddress,
      )
        ..branch.to(cfu.from.branch)
        ..branchAddress.to(cfu.from.branchAddress),
    );
    addSubmodule(
      InstructionFetchUnit(clock, ifu.to.jump, ifu.to.jumpAddress, ifu.to.next)
        ..currentAddress.to(ifu.from.currentAddress),
    );
    addSubmodule(
      LiteralUnit(clock, lu.to.write, lu.to.inputValue)
        ..outputValue.to(lu.from.outputValue),
    );
    addSubmodule(
      LoadStoreUnit(
        clock,
        lsu.to.act,
        lsu.to.data,
        lsu.to.resetMemoryAccess,
        lsu.to.memoryData,
      )
        ..memoryAccess.load.byte.to(lsu.from.memoryAccess.load.byte)
        ..memoryAccess.load.halfword.to(lsu.from.memoryAccess.load.halfword)
        ..memoryAccess.store.byte.to(lsu.from.memoryAccess.store.byte)
        ..memoryAccess.store.halfword.to(lsu.from.memoryAccess.store.halfword)
        ..targetAddress.to(lsu.from.targetAddress)
        ..targetData.to(lsu.from.targetData),
    );
    addSubmodule(
      MemoryUnit(
        clock,
        mu.to.write,
        mu.to.selectByte,
        mu.to.address,
        mu.to.inputData,
      )..outputData.to(mu.from.outputData),
    );
    addSubmodule(
      RegisterFileUnit(clock, rfu.to.write, rfu.to.address, rfu.to.inputData)
        ..outputData.to(rfu.from.outputData),
    );
    addSubmodule(
      SocketArrayUnit(
        sau.to.instruction,
        lu.from,
        (branchAddress: cfu.from.branchAddress),
        rfu.from,
        (targetData: lsu.from.targetData),
        alu.from,
      )
        ..illegalInstruction.to(sau.from.illegalInstruction)
        ..toLU.write.to(lu.to.write)
        ..toLU.inputValue.to(lu.to.inputValue)
        ..toCFU.act.to(cfu.to.act)
        ..toCFU.data.to(cfu.to.data)
        ..toRFU.write.to(rfu.to.write)
        ..toRFU.address.to(rfu.to.address)
        ..toRFU.inputData.to(rfu.to.inputData)
        ..toLSU.act.to(lsu.to.act)
        ..toLSU.data.to(lsu.to.data)
        ..toALU.act.to(alu.to.act)
        ..toALU.data.to(alu.to.data),
    );

    addCombinational([
      nextState.assign(currentState),
      cfu.to.resetBranch.assign(Const(0)),
      ifu.to.jump.assign(Const(0)),
      ifu.to.next.assign(Const(0)),
      lsu.to.resetMemoryAccess.assign(Const(0)),
      mu.to.write.assign(Const(0)),
      When([
        Iff(nextState.eq(Const(_state.initial)), then: [
          // ...
        ])
      ], orElse: [
        // ...
      ])
    ]);

    addSyncSequential(PosEdge(clock), [
      If(
        reset,
        then: [currentState.assign(Const(_state.initial))],
        orElse: [currentState.assign(nextState)],
      )
    ]);
  }

  static const _state = (initial: 0);
}

/*
    final states = [
      State<_State>(_State.initial, events: {
        Const(1): _State.premainA,
      }, actions: [
        mcu.enable < 0,
        ifu.enable < 1,
        ifu.jump < 1,
        ifu.jumpAddress < _startAddress,
        sacu.enable < 0,
      ]),
      State<_State>(_State.premainA, events: {
        Const(1): _State.premainB,
      }, actions: [
        mcu.enable < 1,
        mcu.write < 0,
        mcu.selectByte < 0,
        mcu.address < ifu.mcuAddress,
        ifu.enable < 1,
        ifu.jump < 0,
        sacu.enable < 0,
        cfu.block < 0,
      ]),
      State<_State>(_State.premainB, events: {
        Const(1): _State.main,
      }, actions: [
        mcu.enable < 1,
        mcu.write < 0,
        mcu.selectByte < 0,
        mcu.address < ifu.mcuAddress,
        ifu.enable < 1,
        ifu.jump < 0,
        sacu.enable < 0,
        cfu.block < 0,
      ]),
      State<_State>(_State.main, events: {
        cfu.branch: _State.branch,
        sacu.illegalInstruction: _State.illegalInstruction,
      }, actions: [
        mcu.enable < 1,
        mcu.write < 0,
        mcu.selectByte < 0,
        mcu.address < ifu.mcuAddress,
        ifu.enable < 1,
        ifu.jump < 0,
        sacu.enable < 1,
        cfu.block < 0,
      ]),
      State<_State>(_State.branch, events: {
        Const(1): _State.premainA,
      }, actions: [
        mcu.enable < 1,
        mcu.write < 0,
        mcu.selectByte < 0,
        mcu.address < ifu.mcuAddress,
        ifu.enable < 1,
        ifu.jump < 1,
        ifu.jumpAddress < [cfu.addressHighByte, cfu.addressLowByte].swizzle(),
        sacu.enable < 1, // branch delay slot
        cfu.block < 0,
      ]),
      State<_State>(_State.illegalInstruction, events: {}, actions: [
        mcu.enable < 0,
        ifu.enable < 0,
        sacu.enable < 0,
        cfu.block < 1,
      ])
    ];

    StateMachine<_State>(intf.clock, intf.reset, _State.initial, states);
  }

  late final BSM1DInterface intf;
  late final List<Logic> memory;
  late final List<Logic> registers;

  static const _startAddress = 0x0000;
}

enum _State { initial, premainA, premainB, main, branch, illegalInstruction }

*/
