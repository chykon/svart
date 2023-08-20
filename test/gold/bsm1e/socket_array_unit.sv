module socket_array_unit (
  input logic [15:0] instruction,
  input logic enable,
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
    if (enable) begin
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
  end
endmodule
