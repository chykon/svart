import 'package:svart/svart.dart';

import 'units/arithmetic_logic_unit.dart';
import 'units/control_flow_unit.dart';
import 'units/instruction_fetch_unit.dart';
import 'units/literal_unit.dart';
import 'units/load_store_unit.dart';
import 'units/memory_unit.dart';
import 'units/register_file_unit.dart';
import 'units/socket_array_unit.dart';

class BSM1E extends Module {
  BSM1E(Var clock, Var reset) : super(definitionName: 'bsm1e') {
    clock = addInput('clock', clock);
    reset = addInput('reset', reset);

    final currentState = addInternal(name: 'current_state');
    final nextState = addInternal(name: 'next_state');

    final alu = (
      to: (
        act: addInternal(name: 'to_alu_act', width: 2),
        data: addInternal(name: 'to_alu_data', width: 8)
      ),
      from: (result: addInternal(name: 'from_alu_result', width: 8))
    );
    final cfu = (
      to: (
        act: addInternal(name: 'to_cfu_act', width: 3),
        data: addInternal(name: 'to_cfu_data', width: 8),
        resetBranch: addInternal(name: 'to_cfu_reset_branch'),
        currentAddress: addInternal(name: 'to_cfu_current_address', width: 15)
      ),
      from: (
        branch: addInternal(name: 'from_cfu_branch'),
        branchAddress: addInternal(name: 'from_cfu_branch_address', width: 15)
      )
    );
    final ifu = (
      to: (
        jump: addInternal(name: 'to_ifu_jump'),
        jumpAddress: addInternal(name: 'to_ifu_jump_address', width: 15),
        next: addInternal(name: 'to_ifu_next')
      ),
      from: (
        currentAddress: addInternal(name: 'from_ifu_current_address', width: 15)
      )
    );
    final lu = (
      to: (
        write: addInternal(name: 'to_lu_write'),
        inputValue: addInternal(name: 'to_lu_input_value', width: 8)
      ),
      from: (outputValue: addInternal(name: 'from_lu_output_value', width: 8))
    );
    final lsu = (
      to: (
        act: addInternal(name: 'to_lsu_act', width: 3),
        data: addInternal(name: 'to_lsu_data', width: 8),
        resetMemoryAccess: addInternal(name: 'to_lsu_reset_memory_access'),
        memoryData: addInternal(name: 'to_lsu_memory_data', width: 16)
      ),
      from: (
        memoryAccess: (
          load: (
            byte: addInternal(name: 'from_lsu_memory_access_load_byte'),
            halfword: addInternal(name: 'from_lsu_memory_access_load_halfword')
          ),
          store: (
            byte: addInternal(name: 'from_lsu_memory_access_store_byte'),
            halfword: addInternal(name: 'from_lsu_memory_access_store_halfword')
          )
        ),
        targetAddress: addInternal(name: 'from_lsu_target_address', width: 16),
        targetData: addInternal(name: 'from_lsu_target_data', width: 16)
      )
    );
    final mu = (
      to: (
        write: addInternal(name: 'to_mu_write'),
        selectByte: addInternal(name: 'to_mu_select_byte'),
        address: addInternal(name: 'to_mu_address', width: 16),
        inputData: addInternal(name: 'to_mu_input_data', width: 16)
      ),
      from: (outputData: addInternal(name: 'from_mu_output_data', width: 16))
    );
    final rfu = (
      to: (
        write: addInternal(name: 'to_ifu_write'),
        address: addInternal(name: 'to_ifu_address', width: 7),
        inputData: addInternal(name: 'to_ifu_input_data', width: 8)
      ),
      from: (outputData: addInternal(name: 'from_ifu_output_data', width: 8))
    );
    final sau = (
      to: (instruction: addInternal(name: 'to_sau_instruction', width: 16),),
      from: (
        illegalInstruction: addInternal(name: 'from_sau_illegal_instruction')
      )
    );

    addSubmodule(
      ArithmeticLogicUnit(
        clock,
        alu.to.act,
        alu.to.data,
        instanceName: 'alu_instance',
      )..result.to(alu.from.result),
    );
    addSubmodule(
      ControlFlowUnit(
        clock,
        cfu.to.act,
        cfu.to.data,
        cfu.to.resetBranch,
        cfu.to.currentAddress,
        instanceName: 'cfu_instance',
      )
        ..branch.to(cfu.from.branch)
        ..branchAddress.to(cfu.from.branchAddress),
    );
    addSubmodule(
      InstructionFetchUnit(
        clock,
        ifu.to.jump,
        ifu.to.jumpAddress,
        ifu.to.next,
        instanceName: 'ifu_instance',
      )..currentAddress.to(ifu.from.currentAddress),
    );
    addSubmodule(
      LiteralUnit(
        clock,
        lu.to.write,
        lu.to.inputValue,
        instanceName: 'lu_instance',
      )..outputValue.to(lu.from.outputValue),
    );
    addSubmodule(
      LoadStoreUnit(
        clock,
        lsu.to.act,
        lsu.to.data,
        lsu.to.resetMemoryAccess,
        lsu.to.memoryData,
        instanceName: 'lsu_instance',
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
        // We will have to limit ourselves to a 10-bit address space,
        // since simulating a full address space with such an implementation
        // requires a lot of memory.
        actualAddressSpace: 10,
        instanceName: 'mu_instance',
      )..outputData.to(mu.from.outputData),
    );
    addSubmodule(
      RegisterFileUnit(
        clock,
        rfu.to.write,
        rfu.to.address,
        rfu.to.inputData,
        instanceName: 'rfu_instance',
      )..outputData.to(rfu.from.outputData),
    );
    addSubmodule(
      SocketArrayUnit(
        sau.to.instruction,
        lu.from,
        (branchAddress: cfu.from.branchAddress),
        rfu.from,
        (targetData: lsu.from.targetData),
        alu.from,
        instanceName: 'sau_instance',
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
      When(
        [
          Iff(
            nextState.eq(Const(_state.initial)),
            then: [
              // ...
            ],
          )
        ],
        orElse: [
          // ...
        ],
      )
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
