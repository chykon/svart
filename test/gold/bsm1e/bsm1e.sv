module arithmetic_logic_unit (
  input logic clock,
  input logic [1:0] act,
  input logic [7:0] data,
  output logic [7:0] result
);
  logic [7:0] operand_a;
  logic [7:0] operand_b;
  logic [3:0] op;

  logic [7:0] _part0;
  always_comb begin
    _part0 = data;
    op = _part0[3:0];
  end

  logic [7:0] _part1;
  always_comb _part1 = operand_b;
  logic [7:0] _part2;
  always_comb _part2 = operand_b;
  always_ff @(posedge clock) begin
    if ((act) != (2'h0)) begin
      if ((act) == (2'h1)) begin
        operand_a <= data;
      end else if ((act) == (2'h2)) begin
        operand_b <= data;
      end else if ((act) == (2'h3)) begin
        if ((op) == (4'h0)) begin
          result <= ~(operand_a);
        end else if ((op) == (4'h1)) begin
          result <= (operand_a) & (operand_b);
        end else if ((op) == (4'h2)) begin
          result <= (operand_a) | (operand_b);
        end else if ((op) == (4'h3)) begin
          result <= (operand_a) << (_part1[3:0]);
        end else if ((op) == (4'h4)) begin
          result <= (operand_a) >> (_part2[3:0]);
        end else if ((op) == (4'h5)) begin
          result <= {7'h0, (operand_a) == (operand_b)};
        end else if ((op) == (4'h6)) begin
          result <= {7'h0, (operand_a) != (operand_b)};
        end else if ((op) == (4'h7)) begin
          result <= {7'h0, (operand_a) < (operand_b)};
        end else if ((op) == (4'h8)) begin
          result <= {7'h0, (operand_a) > (operand_b)};
        end else if ((op) == (4'h9)) begin
          result <= {7'h0, (operand_a) <= (operand_b)};
        end else if ((op) == (4'hA)) begin
          result <= {7'h0, (operand_a) >= (operand_b)};
        end else if ((op) == (4'hB)) begin
          result <= (operand_a) + (operand_b);
        end else if ((op) == (4'hC)) begin
          result <= (operand_a) - (operand_b);
        end else begin
          assert ((op) <= (4'hC)) else $fatal;
        end
      end
    end
  end
endmodule

module control_flow_unit (
  input logic clock,
  input logic [2:0] act,
  input logic [7:0] data,
  input logic reset_branch,
  input logic [14:0] current_address,
  output logic branch,
  output logic [14:0] branch_address
);
  logic value;
  logic [1:0] op;

  logic [7:0] _part0;
  always_comb begin
    _part0 = data;
    op = _part0[1:0];
  end

  logic [14:0] _part1;
  always_comb _part1 = branch_address;
  logic [7:0] _part2;
  always_comb _part2 = data;
  logic [14:0] _part3;
  always_comb _part3 = branch_address;
  logic [7:0] _part4;
  always_comb _part4 = data;
  always_ff @(posedge clock) begin
    if (reset_branch) begin
      branch <= 1'h0;
    end
    if ((act) != (3'h0)) begin
      if ((act) == (3'h1)) begin
        branch_address <= {_part1[14:7], _part2[7:1]};
      end else if ((act) == (3'h2)) begin
        branch_address <= {data, _part3[6:0]};
      end else if ((act) == (3'h3)) begin
        value <= _part4[0:0];
      end else if ((act) == (3'h4)) begin
        if ((op) == (2'h0)) begin
          branch_address <= current_address;
        end else if ((op) == (2'h1)) begin
          if ((value) == (1'h0)) begin
            branch <= 1'h1;
          end
        end else if ((op) == (2'h2)) begin
          if ((value) != (1'h0)) begin
            branch <= 1'h1;
          end
        end else begin
          assert ((op) <= (2'h2)) else $fatal;
        end
      end else begin
        assert ((act) <= (3'h4)) else $fatal;
      end
    end
  end
endmodule

module instruction_fetch_unit (
  input logic clock,
  input logic jump,
  input logic [14:0] jump_address,
  input logic next,
  output logic [14:0] current_address
);
  always_ff @(posedge clock) begin
    if (jump) begin
      current_address <= jump_address;
    end else begin
      if (next) begin
        current_address <= (current_address) + (15'h2);
      end
    end
  end
endmodule

module literal_unit (
  input logic clock,
  input logic write,
  input logic [7:0] input_value,
  output logic [7:0] output_value
);
  always_ff @(posedge clock) begin
    if (write) begin
      output_value <= input_value;
    end
  end
endmodule

module load_store_unit (
  input logic clock,
  input logic [2:0] act,
  input logic [7:0] data,
  input logic reset_memory_access,
  input logic [15:0] memory_data,
  output logic memory_access_load_byte,
  output logic memory_access_load_halfword,
  output logic memory_access_store_byte,
  output logic memory_access_store_halfword,
  output logic [15:0] target_address,
  output logic [15:0] target_data
);
  logic [1:0] op;

  logic [7:0] _part0;
  always_comb begin
    _part0 = data;
    op = _part0[1:0];
  end

  logic [15:0] _part1;
  always_comb _part1 = target_address;
  logic [15:0] _part2;
  always_comb _part2 = target_address;
  logic [15:0] _part3;
  always_comb _part3 = target_data;
  logic [15:0] _part4;
  always_comb _part4 = target_data;
  logic [15:0] _part5;
  always_comb _part5 = target_data;
  logic [15:0] _part6;
  always_comb _part6 = memory_data;
  always_ff @(posedge clock) begin
    if (reset_memory_access) begin
      memory_access_load_byte <= 1'h0;
      memory_access_load_halfword <= 1'h0;
      memory_access_store_byte <= 1'h0;
      memory_access_store_halfword <= 1'h0;
    end
    if ((act) != (3'h0)) begin
      if ((act) == (3'h1)) begin
        target_address <= {_part1[15:8], data};
      end else if ((act) == (3'h2)) begin
        target_address <= {data, _part2[7:0]};
      end else if ((act) == (3'h3)) begin
        target_data <= {_part3[15:8], data};
      end else if ((act) == (3'h4)) begin
        target_data <= {data, _part4[7:0]};
      end else if ((act) == (3'h5)) begin
        if ((op) == (2'h0)) begin
          memory_access_load_byte <= 1'h1;
          target_data <= {_part5[15:8], _part6[7:0]};
        end else if ((op) == (2'h1)) begin
          memory_access_load_halfword <= 1'h1;
          target_data <= memory_data;
        end else if ((op) == (2'h2)) begin
          memory_access_store_byte <= 1'h1;
        end else if ((op) == (2'h3)) begin
          memory_access_store_halfword <= 1'h1;
        end
      end else begin
        assert ((act) <= (3'h5)) else $fatal;
      end
    end
  end
endmodule

module memory_unit (
  input logic clock,
  input logic write,
  input logic select_byte,
  input logic [15:0] address,
  input logic [15:0] input_data,
  output logic [15:0] output_data
);
  logic [7:0] memo_0;
  logic [7:0] memo_1;
  logic [7:0] memo_2;
  logic [7:0] memo_3;

  logic [15:0] _part0;
  always_comb _part0 = address;
  logic [15:0] _part1;
  always_comb _part1 = 16'h0;
  logic [15:0] _part2;
  always_comb _part2 = address;
  logic [15:0] _part3;
  always_comb _part3 = 16'h2;
  always_comb begin
    if ((_part0[15:1]) == (_part1[15:1])) begin
      output_data = {memo_1, memo_0};
    end else if ((_part2[15:1]) == (_part3[15:1])) begin
      output_data = {memo_3, memo_2};
    end
  end

  logic [15:0] _part4;
  always_comb _part4 = address;
  logic [15:0] _part5;
  always_comb _part5 = 16'h0;
  logic [15:0] _part6;
  always_comb _part6 = address;
  logic [15:0] _part7;
  always_comb _part7 = input_data;
  logic [15:0] _part8;
  always_comb _part8 = input_data;
  logic [15:0] _part9;
  always_comb _part9 = input_data;
  logic [15:0] _part10;
  always_comb _part10 = input_data;
  logic [15:0] _part11;
  always_comb _part11 = address;
  logic [15:0] _part12;
  always_comb _part12 = 16'h2;
  logic [15:0] _part13;
  always_comb _part13 = address;
  logic [15:0] _part14;
  always_comb _part14 = input_data;
  logic [15:0] _part15;
  always_comb _part15 = input_data;
  logic [15:0] _part16;
  always_comb _part16 = input_data;
  logic [15:0] _part17;
  always_comb _part17 = input_data;
  always_ff @(posedge clock) begin
    if (write) begin
      if ((_part4[15:1]) == (_part5[15:1])) begin
        if (select_byte) begin
          if ((_part6[0:0]) == (1'h0)) begin
            memo_0 <= _part7[7:0];
          end else begin
            memo_1 <= _part8[7:0];
          end
        end else begin
          memo_0 <= _part9[7:0];
          memo_1 <= _part10[15:8];
        end
      end else if ((_part11[15:1]) == (_part12[15:1])) begin
        if (select_byte) begin
          if ((_part13[0:0]) == (1'h0)) begin
            memo_2 <= _part14[7:0];
          end else begin
            memo_3 <= _part15[7:0];
          end
        end else begin
          memo_2 <= _part16[7:0];
          memo_3 <= _part17[15:8];
        end
      end
    end
  end
endmodule

module register_file_unit (
  input logic clock,
  input logic write,
  input logic [6:0] address,
  input logic [7:0] input_data,
  output logic [7:0] output_data
);
  logic [7:0] register_0;
  logic [7:0] register_1;
  logic [7:0] register_2;
  logic [7:0] register_3;
  always_comb begin
    if ((address) == (7'h0)) begin
      output_data = register_0;
    end else if ((address) == (7'h1)) begin
      output_data = register_1;
    end else if ((address) == (7'h2)) begin
      output_data = register_2;
    end else if ((address) == (7'h3)) begin
      output_data = register_3;
    end
  end

  always_ff @(posedge clock) begin
    if (write) begin
      if ((address) == (7'h0)) begin
        register_0 <= input_data;
      end else if ((address) == (7'h1)) begin
        register_1 <= input_data;
      end else if ((address) == (7'h2)) begin
        register_2 <= input_data;
      end else if ((address) == (7'h3)) begin
        register_3 <= input_data;
      end
    end
  end
endmodule

module socket_array_unit (
  input logic [15:0] instruction,
  input logic [7:0] from_lu_output_value,
  input logic [14:0] from_cfu_branch_address,
  input logic [7:0] from_rfu_output_data,
  input logic [15:0] from_lsu_target_data,
  input logic [7:0] from_alu_result,
  output logic illegal_instruction,
  output logic to_lu_write,
  output logic [7:0] to_lu_input_value,
  output logic [2:0] to_cfu_act,
  output logic [7:0] to_cfu_data,
  output logic to_rfu_write,
  output logic [6:0] to_rfu_address,
  output logic [7:0] to_rfu_input_data,
  output logic [2:0] to_lsu_act,
  output logic [7:0] to_lsu_data,
  output logic [1:0] to_alu_act,
  output logic [7:0] to_alu_data
);
  logic [7:0] alpha;
  logic [7:0] omega;

  logic [15:0] _part0;
  always_comb begin
    _part0 = instruction;
    alpha = _part0[7:0];
  end

  logic [15:0] _part1;
  always_comb begin
    _part1 = instruction;
    omega = _part1[15:8];
  end

  logic [7:0] _part2;
  logic [7:0] _part3;
  logic [14:0] _part4;
  logic [7:0] _part5;
  logic [14:0] _part6;
  logic [7:0] _part7;
  logic [15:0] _part8;
  logic [7:0] _part9;
  logic [15:0] _part10;
  logic [7:0] _part11;
  logic [7:0] _part12;
  logic [7:0] _part13;
  logic [7:0] _part14;
  logic [7:0] _part15;
  logic [7:0] _part16;
  logic [7:0] _part17;
  logic [7:0] _part18;
  logic [7:0] _part19;
  logic [7:0] _part20;
  logic [7:0] _part21;
  logic [7:0] _part22;
  logic [7:0] _part23;
  always_comb begin
    illegal_instruction = 1'h0;
    to_lu_write = 1'h0;
    to_cfu_act = 3'h0;
    to_rfu_write = 1'h0;
    to_lsu_act = 3'h0;
    to_alu_act = 2'h0;
    if (~(((alpha) == (8'h0)) & ((omega) == (8'h1)))) begin
      if (((alpha) == (8'h0)) & ((omega) == (8'h0))) begin
        illegal_instruction = 1'h1;
      end else if ((alpha) == (8'h1)) begin
        to_lu_input_value = omega;
        to_lu_write = 1'h1;
      end else if (((alpha) >= (8'h80)) & ((omega) <= (8'hFF))) begin
        if ((omega) == (8'h1)) begin
          _part2 = alpha;
          to_rfu_address = _part2[6:0];
          to_rfu_input_data = from_lu_output_value;
          to_rfu_write = 1'h1;
        end else if ((omega) == (8'h2)) begin
          _part3 = alpha;
          to_rfu_address = _part3[6:0];
          _part4 = from_cfu_branch_address;
          to_rfu_input_data = {_part4[6:0], 1'h0};
          to_rfu_write = 1'h1;
        end else if ((omega) == (8'h3)) begin
          _part5 = alpha;
          to_rfu_address = _part5[6:0];
          _part6 = from_cfu_branch_address;
          to_rfu_input_data = _part6[14:7];
          to_rfu_write = 1'h1;
        end else if ((omega) == (8'h8)) begin
          _part7 = alpha;
          to_rfu_address = _part7[6:0];
          _part8 = from_lsu_target_data;
          to_rfu_input_data = _part8[7:0];
          to_rfu_write = 1'h1;
        end else if ((omega) == (8'h9)) begin
          _part9 = alpha;
          to_rfu_address = _part9[6:0];
          _part10 = from_lsu_target_data;
          to_rfu_input_data = _part10[15:8];
          to_rfu_write = 1'h1;
        end else if ((omega) == (8'hD)) begin
          _part11 = alpha;
          to_rfu_address = _part11[6:0];
          to_rfu_input_data = from_alu_result;
          to_rfu_write = 1'h1;
        end else begin
          illegal_instruction = 1'h1;
        end
      end else if (((omega) >= (8'h80)) & ((omega) <= (8'hFF))) begin
        if ((alpha) == (8'h2)) begin
          _part12 = omega;
          to_rfu_address = _part12[6:0];
          to_cfu_data = from_rfu_output_data;
          to_cfu_act = 3'h1;
        end else if ((alpha) == (8'h3)) begin
          _part13 = omega;
          to_rfu_address = _part13[6:0];
          to_cfu_data = from_rfu_output_data;
          to_cfu_act = 3'h2;
        end else if ((alpha) == (8'h4)) begin
          _part14 = omega;
          to_rfu_address = _part14[6:0];
          to_cfu_data = from_rfu_output_data;
          to_cfu_act = 3'h3;
        end else if ((alpha) == (8'h5)) begin
          _part15 = omega;
          to_rfu_address = _part15[6:0];
          if ((from_rfu_output_data) <= (8'h2)) begin
            to_cfu_data = from_rfu_output_data;
            to_cfu_act = 3'h4;
          end else begin
            illegal_instruction = 1'h1;
          end
        end else if ((alpha) == (8'h6)) begin
          _part16 = omega;
          to_rfu_address = _part16[6:0];
          to_lsu_data = from_rfu_output_data;
          to_lsu_act = 3'h1;
        end else if ((alpha) == (8'h7)) begin
          _part17 = omega;
          to_rfu_address = _part17[6:0];
          to_lsu_data = from_rfu_output_data;
          to_lsu_act = 3'h2;
        end else if ((alpha) == (8'h8)) begin
          _part18 = omega;
          to_rfu_address = _part18[6:0];
          to_lsu_data = from_rfu_output_data;
          to_lsu_act = 3'h3;
        end else if ((alpha) == (8'h9)) begin
          _part19 = omega;
          to_rfu_address = _part19[6:0];
          to_lsu_data = from_rfu_output_data;
          to_lsu_act = 3'h4;
        end else if ((alpha) == (8'hA)) begin
          _part20 = omega;
          to_rfu_address = _part20[6:0];
          if ((from_rfu_output_data) <= (8'h3)) begin
            to_lsu_data = from_rfu_output_data;
            to_lsu_act = 3'h5;
          end else begin
            illegal_instruction = 1'h1;
          end
        end else if ((alpha) == (8'hB)) begin
          _part21 = omega;
          to_rfu_address = _part21[6:0];
          to_alu_data = from_rfu_output_data;
          to_alu_act = 2'h1;
        end else if ((alpha) == (8'hC)) begin
          _part22 = omega;
          to_rfu_address = _part22[6:0];
          to_alu_data = from_rfu_output_data;
          to_alu_act = 2'h2;
        end else if ((alpha) == (8'hE)) begin
          _part23 = omega;
          to_rfu_address = _part23[6:0];
          if ((from_rfu_output_data) <= (8'hC)) begin
            to_alu_data = from_rfu_output_data;
            to_alu_act = 2'h3;
          end else begin
            illegal_instruction = 1'h1;
          end
        end else begin
          illegal_instruction = 1'h1;
        end
      end else begin
        illegal_instruction = 1'h1;
      end
    end
  end
endmodule

module bsm1e (
  input logic clock,
  input logic reset
);
  logic current_state;
  logic next_state;
  logic [1:0] to_alu_act;
  logic [7:0] to_alu_data;
  logic [7:0] from_alu_result;
  logic [2:0] to_cfu_act;
  logic [7:0] to_cfu_data;
  logic to_cfu_reset_branch;
  logic [14:0] to_cfu_current_address;
  logic from_cfu_branch;
  logic [14:0] from_cfu_branch_address;
  logic to_ifu_jump;
  logic [14:0] to_ifu_jump_address;
  logic to_ifu_next;
  logic [14:0] from_ifu_current_address;
  logic to_lu_write;
  logic [7:0] to_lu_input_value;
  logic [7:0] from_lu_output_value;
  logic [2:0] to_lsu_act;
  logic [7:0] to_lsu_data;
  logic to_lsu_reset_memory_access;
  logic [15:0] to_lsu_memory_data;
  logic from_lsu_memory_access_load_byte;
  logic from_lsu_memory_access_load_halfword;
  logic from_lsu_memory_access_store_byte;
  logic from_lsu_memory_access_store_halfword;
  logic [15:0] from_lsu_target_address;
  logic [15:0] from_lsu_target_data;
  logic to_mu_write;
  logic to_mu_select_byte;
  logic [15:0] to_mu_address;
  logic [15:0] to_mu_input_data;
  logic [15:0] from_mu_output_data;
  logic to_ifu_write;
  logic [6:0] to_ifu_address;
  logic [7:0] to_ifu_input_data;
  logic [7:0] from_ifu_output_data;
  logic [15:0] to_sau_instruction;
  logic from_sau_illegal_instruction;

  arithmetic_logic_unit alu_instance (.clock(clock), .act(to_alu_act), .data(to_alu_data), .result(from_alu_result));
  control_flow_unit cfu_instance (.clock(clock), .act(to_cfu_act), .data(to_cfu_data), .reset_branch(to_cfu_reset_branch), .current_address(to_cfu_current_address), .branch(from_cfu_branch), .branch_address(from_cfu_branch_address));
  instruction_fetch_unit ifu_instance (.clock(clock), .jump(to_ifu_jump), .jump_address(to_ifu_jump_address), .next(to_ifu_next), .current_address(from_ifu_current_address));
  literal_unit lu_instance (.clock(clock), .write(to_lu_write), .input_value(to_lu_input_value), .output_value(from_lu_output_value));
  load_store_unit lsu_instance (.clock(clock), .act(to_lsu_act), .data(to_lsu_data), .reset_memory_access(to_lsu_reset_memory_access), .memory_data(to_lsu_memory_data), .memory_access_load_byte(from_lsu_memory_access_load_byte), .memory_access_load_halfword(from_lsu_memory_access_load_halfword), .memory_access_store_byte(from_lsu_memory_access_store_byte), .memory_access_store_halfword(from_lsu_memory_access_store_halfword), .target_address(from_lsu_target_address), .target_data(from_lsu_target_data));
  memory_unit mu_instance (.clock(clock), .write(to_mu_write), .select_byte(to_mu_select_byte), .address(to_mu_address), .input_data(to_mu_input_data), .output_data(from_mu_output_data));
  register_file_unit rfu_instance (.clock(clock), .write(to_ifu_write), .address(to_ifu_address), .input_data(to_ifu_input_data), .output_data(from_ifu_output_data));
  socket_array_unit sau_instance (.instruction(to_sau_instruction), .from_lu_output_value(from_lu_output_value), .from_cfu_branch_address(from_cfu_branch_address), .from_rfu_output_data(from_ifu_output_data), .from_lsu_target_data(from_lsu_target_data), .from_alu_result(from_alu_result), .illegal_instruction(from_sau_illegal_instruction), .to_lu_write(to_lu_write), .to_lu_input_value(to_lu_input_value), .to_cfu_act(to_cfu_act), .to_cfu_data(to_cfu_data), .to_rfu_write(to_ifu_write), .to_rfu_address(to_ifu_address), .to_rfu_input_data(to_ifu_input_data), .to_lsu_act(to_lsu_act), .to_lsu_data(to_lsu_data), .to_alu_act(to_alu_act), .to_alu_data(to_alu_data));

  always_comb begin
    next_state = current_state;
    to_cfu_reset_branch = 1'h0;
    to_ifu_jump = 1'h0;
    to_ifu_next = 1'h0;
    to_lsu_reset_memory_access = 1'h0;
    to_mu_write = 1'h0;
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      current_state <= 1'h0;
    end else begin
      current_state <= next_state;
    end
  end
endmodule
