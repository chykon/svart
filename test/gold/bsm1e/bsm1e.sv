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
        current_address <= (current_address) + (15'h1);
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
    end else begin
      target_data <= memory_data;
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
  logic [7:0] memo_4;
  logic [7:0] memo_5;
  logic [7:0] memo_6;
  logic [7:0] memo_7;
  logic [7:0] memo_8;
  logic [7:0] memo_9;
  logic [7:0] memo_10;
  logic [7:0] memo_11;
  logic [7:0] memo_12;
  logic [7:0] memo_13;
  logic [7:0] memo_14;
  logic [7:0] memo_15;
  logic [7:0] memo_16;
  logic [7:0] memo_17;
  logic [7:0] memo_18;
  logic [7:0] memo_19;
  logic [7:0] memo_20;
  logic [7:0] memo_21;
  logic [7:0] memo_22;
  logic [7:0] memo_23;
  logic [7:0] memo_24;
  logic [7:0] memo_25;
  logic [7:0] memo_26;
  logic [7:0] memo_27;
  logic [7:0] memo_28;
  logic [7:0] memo_29;
  logic [7:0] memo_30;
  logic [7:0] memo_31;

  initial begin
    memo_0 = 8'h1;
    memo_1 = 8'hFE;
    memo_2 = 8'h80;
    memo_3 = 8'h1;
    memo_4 = 8'h1;
    memo_5 = 8'h1;
    memo_6 = 8'h81;
    memo_7 = 8'h1;
    memo_8 = 8'h1;
    memo_9 = 8'hB;
    memo_10 = 8'h82;
    memo_11 = 8'h1;
    memo_12 = 8'hB;
    memo_13 = 8'h80;
    memo_14 = 8'hC;
    memo_15 = 8'h81;
    memo_16 = 8'hE;
    memo_17 = 8'h82;
    memo_18 = 8'h83;
    memo_19 = 8'hD;
    memo_20 = 8'h0;
    memo_21 = 8'h1;
  end

  logic [15:0] _part0;
  always_comb _part0 = address;
  logic [15:0] _part1;
  always_comb _part1 = 16'h0;
  logic [15:0] _part2;
  always_comb _part2 = address;
  logic [15:0] _part3;
  always_comb _part3 = 16'h2;
  logic [15:0] _part4;
  always_comb _part4 = address;
  logic [15:0] _part5;
  always_comb _part5 = 16'h4;
  logic [15:0] _part6;
  always_comb _part6 = address;
  logic [15:0] _part7;
  always_comb _part7 = 16'h6;
  logic [15:0] _part8;
  always_comb _part8 = address;
  logic [15:0] _part9;
  always_comb _part9 = 16'h8;
  logic [15:0] _part10;
  always_comb _part10 = address;
  logic [15:0] _part11;
  always_comb _part11 = 16'hA;
  logic [15:0] _part12;
  always_comb _part12 = address;
  logic [15:0] _part13;
  always_comb _part13 = 16'hC;
  logic [15:0] _part14;
  always_comb _part14 = address;
  logic [15:0] _part15;
  always_comb _part15 = 16'hE;
  logic [15:0] _part16;
  always_comb _part16 = address;
  logic [15:0] _part17;
  always_comb _part17 = 16'h10;
  logic [15:0] _part18;
  always_comb _part18 = address;
  logic [15:0] _part19;
  always_comb _part19 = 16'h12;
  logic [15:0] _part20;
  always_comb _part20 = address;
  logic [15:0] _part21;
  always_comb _part21 = 16'h14;
  logic [15:0] _part22;
  always_comb _part22 = address;
  logic [15:0] _part23;
  always_comb _part23 = 16'h16;
  logic [15:0] _part24;
  always_comb _part24 = address;
  logic [15:0] _part25;
  always_comb _part25 = 16'h18;
  logic [15:0] _part26;
  always_comb _part26 = address;
  logic [15:0] _part27;
  always_comb _part27 = 16'h1A;
  logic [15:0] _part28;
  always_comb _part28 = address;
  logic [15:0] _part29;
  always_comb _part29 = 16'h1C;
  logic [15:0] _part30;
  always_comb _part30 = address;
  logic [15:0] _part31;
  always_comb _part31 = 16'h1E;
  always_comb begin
    if ((_part0[15:1]) == (_part1[15:1])) begin
      output_data = {memo_1, memo_0};
    end else if ((_part2[15:1]) == (_part3[15:1])) begin
      output_data = {memo_3, memo_2};
    end else if ((_part4[15:1]) == (_part5[15:1])) begin
      output_data = {memo_5, memo_4};
    end else if ((_part6[15:1]) == (_part7[15:1])) begin
      output_data = {memo_7, memo_6};
    end else if ((_part8[15:1]) == (_part9[15:1])) begin
      output_data = {memo_9, memo_8};
    end else if ((_part10[15:1]) == (_part11[15:1])) begin
      output_data = {memo_11, memo_10};
    end else if ((_part12[15:1]) == (_part13[15:1])) begin
      output_data = {memo_13, memo_12};
    end else if ((_part14[15:1]) == (_part15[15:1])) begin
      output_data = {memo_15, memo_14};
    end else if ((_part16[15:1]) == (_part17[15:1])) begin
      output_data = {memo_17, memo_16};
    end else if ((_part18[15:1]) == (_part19[15:1])) begin
      output_data = {memo_19, memo_18};
    end else if ((_part20[15:1]) == (_part21[15:1])) begin
      output_data = {memo_21, memo_20};
    end else if ((_part22[15:1]) == (_part23[15:1])) begin
      output_data = {memo_23, memo_22};
    end else if ((_part24[15:1]) == (_part25[15:1])) begin
      output_data = {memo_25, memo_24};
    end else if ((_part26[15:1]) == (_part27[15:1])) begin
      output_data = {memo_27, memo_26};
    end else if ((_part28[15:1]) == (_part29[15:1])) begin
      output_data = {memo_29, memo_28};
    end else if ((_part30[15:1]) == (_part31[15:1])) begin
      output_data = {memo_31, memo_30};
    end
  end

  logic [15:0] _part32;
  always_comb _part32 = address;
  logic [15:0] _part33;
  always_comb _part33 = 16'h0;
  logic [15:0] _part34;
  always_comb _part34 = address;
  logic [15:0] _part35;
  always_comb _part35 = input_data;
  logic [15:0] _part36;
  always_comb _part36 = input_data;
  logic [15:0] _part37;
  always_comb _part37 = input_data;
  logic [15:0] _part38;
  always_comb _part38 = input_data;
  logic [15:0] _part39;
  always_comb _part39 = address;
  logic [15:0] _part40;
  always_comb _part40 = 16'h2;
  logic [15:0] _part41;
  always_comb _part41 = address;
  logic [15:0] _part42;
  always_comb _part42 = input_data;
  logic [15:0] _part43;
  always_comb _part43 = input_data;
  logic [15:0] _part44;
  always_comb _part44 = input_data;
  logic [15:0] _part45;
  always_comb _part45 = input_data;
  logic [15:0] _part46;
  always_comb _part46 = address;
  logic [15:0] _part47;
  always_comb _part47 = 16'h4;
  logic [15:0] _part48;
  always_comb _part48 = address;
  logic [15:0] _part49;
  always_comb _part49 = input_data;
  logic [15:0] _part50;
  always_comb _part50 = input_data;
  logic [15:0] _part51;
  always_comb _part51 = input_data;
  logic [15:0] _part52;
  always_comb _part52 = input_data;
  logic [15:0] _part53;
  always_comb _part53 = address;
  logic [15:0] _part54;
  always_comb _part54 = 16'h6;
  logic [15:0] _part55;
  always_comb _part55 = address;
  logic [15:0] _part56;
  always_comb _part56 = input_data;
  logic [15:0] _part57;
  always_comb _part57 = input_data;
  logic [15:0] _part58;
  always_comb _part58 = input_data;
  logic [15:0] _part59;
  always_comb _part59 = input_data;
  logic [15:0] _part60;
  always_comb _part60 = address;
  logic [15:0] _part61;
  always_comb _part61 = 16'h8;
  logic [15:0] _part62;
  always_comb _part62 = address;
  logic [15:0] _part63;
  always_comb _part63 = input_data;
  logic [15:0] _part64;
  always_comb _part64 = input_data;
  logic [15:0] _part65;
  always_comb _part65 = input_data;
  logic [15:0] _part66;
  always_comb _part66 = input_data;
  logic [15:0] _part67;
  always_comb _part67 = address;
  logic [15:0] _part68;
  always_comb _part68 = 16'hA;
  logic [15:0] _part69;
  always_comb _part69 = address;
  logic [15:0] _part70;
  always_comb _part70 = input_data;
  logic [15:0] _part71;
  always_comb _part71 = input_data;
  logic [15:0] _part72;
  always_comb _part72 = input_data;
  logic [15:0] _part73;
  always_comb _part73 = input_data;
  logic [15:0] _part74;
  always_comb _part74 = address;
  logic [15:0] _part75;
  always_comb _part75 = 16'hC;
  logic [15:0] _part76;
  always_comb _part76 = address;
  logic [15:0] _part77;
  always_comb _part77 = input_data;
  logic [15:0] _part78;
  always_comb _part78 = input_data;
  logic [15:0] _part79;
  always_comb _part79 = input_data;
  logic [15:0] _part80;
  always_comb _part80 = input_data;
  logic [15:0] _part81;
  always_comb _part81 = address;
  logic [15:0] _part82;
  always_comb _part82 = 16'hE;
  logic [15:0] _part83;
  always_comb _part83 = address;
  logic [15:0] _part84;
  always_comb _part84 = input_data;
  logic [15:0] _part85;
  always_comb _part85 = input_data;
  logic [15:0] _part86;
  always_comb _part86 = input_data;
  logic [15:0] _part87;
  always_comb _part87 = input_data;
  logic [15:0] _part88;
  always_comb _part88 = address;
  logic [15:0] _part89;
  always_comb _part89 = 16'h10;
  logic [15:0] _part90;
  always_comb _part90 = address;
  logic [15:0] _part91;
  always_comb _part91 = input_data;
  logic [15:0] _part92;
  always_comb _part92 = input_data;
  logic [15:0] _part93;
  always_comb _part93 = input_data;
  logic [15:0] _part94;
  always_comb _part94 = input_data;
  logic [15:0] _part95;
  always_comb _part95 = address;
  logic [15:0] _part96;
  always_comb _part96 = 16'h12;
  logic [15:0] _part97;
  always_comb _part97 = address;
  logic [15:0] _part98;
  always_comb _part98 = input_data;
  logic [15:0] _part99;
  always_comb _part99 = input_data;
  logic [15:0] _part100;
  always_comb _part100 = input_data;
  logic [15:0] _part101;
  always_comb _part101 = input_data;
  logic [15:0] _part102;
  always_comb _part102 = address;
  logic [15:0] _part103;
  always_comb _part103 = 16'h14;
  logic [15:0] _part104;
  always_comb _part104 = address;
  logic [15:0] _part105;
  always_comb _part105 = input_data;
  logic [15:0] _part106;
  always_comb _part106 = input_data;
  logic [15:0] _part107;
  always_comb _part107 = input_data;
  logic [15:0] _part108;
  always_comb _part108 = input_data;
  logic [15:0] _part109;
  always_comb _part109 = address;
  logic [15:0] _part110;
  always_comb _part110 = 16'h16;
  logic [15:0] _part111;
  always_comb _part111 = address;
  logic [15:0] _part112;
  always_comb _part112 = input_data;
  logic [15:0] _part113;
  always_comb _part113 = input_data;
  logic [15:0] _part114;
  always_comb _part114 = input_data;
  logic [15:0] _part115;
  always_comb _part115 = input_data;
  logic [15:0] _part116;
  always_comb _part116 = address;
  logic [15:0] _part117;
  always_comb _part117 = 16'h18;
  logic [15:0] _part118;
  always_comb _part118 = address;
  logic [15:0] _part119;
  always_comb _part119 = input_data;
  logic [15:0] _part120;
  always_comb _part120 = input_data;
  logic [15:0] _part121;
  always_comb _part121 = input_data;
  logic [15:0] _part122;
  always_comb _part122 = input_data;
  logic [15:0] _part123;
  always_comb _part123 = address;
  logic [15:0] _part124;
  always_comb _part124 = 16'h1A;
  logic [15:0] _part125;
  always_comb _part125 = address;
  logic [15:0] _part126;
  always_comb _part126 = input_data;
  logic [15:0] _part127;
  always_comb _part127 = input_data;
  logic [15:0] _part128;
  always_comb _part128 = input_data;
  logic [15:0] _part129;
  always_comb _part129 = input_data;
  logic [15:0] _part130;
  always_comb _part130 = address;
  logic [15:0] _part131;
  always_comb _part131 = 16'h1C;
  logic [15:0] _part132;
  always_comb _part132 = address;
  logic [15:0] _part133;
  always_comb _part133 = input_data;
  logic [15:0] _part134;
  always_comb _part134 = input_data;
  logic [15:0] _part135;
  always_comb _part135 = input_data;
  logic [15:0] _part136;
  always_comb _part136 = input_data;
  logic [15:0] _part137;
  always_comb _part137 = address;
  logic [15:0] _part138;
  always_comb _part138 = 16'h1E;
  logic [15:0] _part139;
  always_comb _part139 = address;
  logic [15:0] _part140;
  always_comb _part140 = input_data;
  logic [15:0] _part141;
  always_comb _part141 = input_data;
  logic [15:0] _part142;
  always_comb _part142 = input_data;
  logic [15:0] _part143;
  always_comb _part143 = input_data;
  always_ff @(posedge clock) begin
    if (write) begin
      if ((_part32[15:1]) == (_part33[15:1])) begin
        if (select_byte) begin
          if ((_part34[0:0]) == (1'h0)) begin
            memo_0 <= _part35[7:0];
          end else begin
            memo_1 <= _part36[7:0];
          end
        end else begin
          memo_0 <= _part37[7:0];
          memo_1 <= _part38[15:8];
        end
      end else if ((_part39[15:1]) == (_part40[15:1])) begin
        if (select_byte) begin
          if ((_part41[0:0]) == (1'h0)) begin
            memo_2 <= _part42[7:0];
          end else begin
            memo_3 <= _part43[7:0];
          end
        end else begin
          memo_2 <= _part44[7:0];
          memo_3 <= _part45[15:8];
        end
      end else if ((_part46[15:1]) == (_part47[15:1])) begin
        if (select_byte) begin
          if ((_part48[0:0]) == (1'h0)) begin
            memo_4 <= _part49[7:0];
          end else begin
            memo_5 <= _part50[7:0];
          end
        end else begin
          memo_4 <= _part51[7:0];
          memo_5 <= _part52[15:8];
        end
      end else if ((_part53[15:1]) == (_part54[15:1])) begin
        if (select_byte) begin
          if ((_part55[0:0]) == (1'h0)) begin
            memo_6 <= _part56[7:0];
          end else begin
            memo_7 <= _part57[7:0];
          end
        end else begin
          memo_6 <= _part58[7:0];
          memo_7 <= _part59[15:8];
        end
      end else if ((_part60[15:1]) == (_part61[15:1])) begin
        if (select_byte) begin
          if ((_part62[0:0]) == (1'h0)) begin
            memo_8 <= _part63[7:0];
          end else begin
            memo_9 <= _part64[7:0];
          end
        end else begin
          memo_8 <= _part65[7:0];
          memo_9 <= _part66[15:8];
        end
      end else if ((_part67[15:1]) == (_part68[15:1])) begin
        if (select_byte) begin
          if ((_part69[0:0]) == (1'h0)) begin
            memo_10 <= _part70[7:0];
          end else begin
            memo_11 <= _part71[7:0];
          end
        end else begin
          memo_10 <= _part72[7:0];
          memo_11 <= _part73[15:8];
        end
      end else if ((_part74[15:1]) == (_part75[15:1])) begin
        if (select_byte) begin
          if ((_part76[0:0]) == (1'h0)) begin
            memo_12 <= _part77[7:0];
          end else begin
            memo_13 <= _part78[7:0];
          end
        end else begin
          memo_12 <= _part79[7:0];
          memo_13 <= _part80[15:8];
        end
      end else if ((_part81[15:1]) == (_part82[15:1])) begin
        if (select_byte) begin
          if ((_part83[0:0]) == (1'h0)) begin
            memo_14 <= _part84[7:0];
          end else begin
            memo_15 <= _part85[7:0];
          end
        end else begin
          memo_14 <= _part86[7:0];
          memo_15 <= _part87[15:8];
        end
      end else if ((_part88[15:1]) == (_part89[15:1])) begin
        if (select_byte) begin
          if ((_part90[0:0]) == (1'h0)) begin
            memo_16 <= _part91[7:0];
          end else begin
            memo_17 <= _part92[7:0];
          end
        end else begin
          memo_16 <= _part93[7:0];
          memo_17 <= _part94[15:8];
        end
      end else if ((_part95[15:1]) == (_part96[15:1])) begin
        if (select_byte) begin
          if ((_part97[0:0]) == (1'h0)) begin
            memo_18 <= _part98[7:0];
          end else begin
            memo_19 <= _part99[7:0];
          end
        end else begin
          memo_18 <= _part100[7:0];
          memo_19 <= _part101[15:8];
        end
      end else if ((_part102[15:1]) == (_part103[15:1])) begin
        if (select_byte) begin
          if ((_part104[0:0]) == (1'h0)) begin
            memo_20 <= _part105[7:0];
          end else begin
            memo_21 <= _part106[7:0];
          end
        end else begin
          memo_20 <= _part107[7:0];
          memo_21 <= _part108[15:8];
        end
      end else if ((_part109[15:1]) == (_part110[15:1])) begin
        if (select_byte) begin
          if ((_part111[0:0]) == (1'h0)) begin
            memo_22 <= _part112[7:0];
          end else begin
            memo_23 <= _part113[7:0];
          end
        end else begin
          memo_22 <= _part114[7:0];
          memo_23 <= _part115[15:8];
        end
      end else if ((_part116[15:1]) == (_part117[15:1])) begin
        if (select_byte) begin
          if ((_part118[0:0]) == (1'h0)) begin
            memo_24 <= _part119[7:0];
          end else begin
            memo_25 <= _part120[7:0];
          end
        end else begin
          memo_24 <= _part121[7:0];
          memo_25 <= _part122[15:8];
        end
      end else if ((_part123[15:1]) == (_part124[15:1])) begin
        if (select_byte) begin
          if ((_part125[0:0]) == (1'h0)) begin
            memo_26 <= _part126[7:0];
          end else begin
            memo_27 <= _part127[7:0];
          end
        end else begin
          memo_26 <= _part128[7:0];
          memo_27 <= _part129[15:8];
        end
      end else if ((_part130[15:1]) == (_part131[15:1])) begin
        if (select_byte) begin
          if ((_part132[0:0]) == (1'h0)) begin
            memo_28 <= _part133[7:0];
          end else begin
            memo_29 <= _part134[7:0];
          end
        end else begin
          memo_28 <= _part135[7:0];
          memo_29 <= _part136[15:8];
        end
      end else if ((_part137[15:1]) == (_part138[15:1])) begin
        if (select_byte) begin
          if ((_part139[0:0]) == (1'h0)) begin
            memo_30 <= _part140[7:0];
          end else begin
            memo_31 <= _part141[7:0];
          end
        end else begin
          memo_30 <= _part142[7:0];
          memo_31 <= _part143[15:8];
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

module bsm1e (
  input logic clock,
  input logic reset
);
  logic [2:0] current_state;
  logic [2:0] next_state;
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
  logic to_rfu_write;
  logic [6:0] to_rfu_address;
  logic [7:0] to_rfu_input_data;
  logic [7:0] from_rfu_output_data;
  logic [15:0] to_sau_instruction;
  logic to_sau_enable;
  logic from_sau_illegal_instruction;

  arithmetic_logic_unit alu_instance (.clock(clock), .act(to_alu_act), .data(to_alu_data), .result(from_alu_result));
  control_flow_unit cfu_instance (.clock(clock), .act(to_cfu_act), .data(to_cfu_data), .reset_branch(to_cfu_reset_branch), .current_address(to_cfu_current_address), .branch(from_cfu_branch), .branch_address(from_cfu_branch_address));
  instruction_fetch_unit ifu_instance (.clock(clock), .jump(to_ifu_jump), .jump_address(to_ifu_jump_address), .next(to_ifu_next), .current_address(from_ifu_current_address));
  literal_unit lu_instance (.clock(clock), .write(to_lu_write), .input_value(to_lu_input_value), .output_value(from_lu_output_value));
  load_store_unit lsu_instance (.clock(clock), .act(to_lsu_act), .data(to_lsu_data), .reset_memory_access(to_lsu_reset_memory_access), .memory_data(to_lsu_memory_data), .memory_access_load_byte(from_lsu_memory_access_load_byte), .memory_access_load_halfword(from_lsu_memory_access_load_halfword), .memory_access_store_byte(from_lsu_memory_access_store_byte), .memory_access_store_halfword(from_lsu_memory_access_store_halfword), .target_address(from_lsu_target_address), .target_data(from_lsu_target_data));
  memory_unit mu_instance (.clock(clock), .write(to_mu_write), .select_byte(to_mu_select_byte), .address(to_mu_address), .input_data(to_mu_input_data), .output_data(from_mu_output_data));
  register_file_unit rfu_instance (.clock(clock), .write(to_rfu_write), .address(to_rfu_address), .input_data(to_rfu_input_data), .output_data(from_rfu_output_data));
  socket_array_unit sau_instance (.instruction(to_sau_instruction), .enable(to_sau_enable), .from_lu_output_value(from_lu_output_value), .from_cfu_branch_address(from_cfu_branch_address), .from_rfu_output_data(from_rfu_output_data), .from_lsu_target_data(from_lsu_target_data), .from_alu_result(from_alu_result), .illegal_instruction(from_sau_illegal_instruction), .to_lu_write(to_lu_write), .to_lu_input_value(to_lu_input_value), .to_cfu_act(to_cfu_act), .to_cfu_data(to_cfu_data), .to_rfu_write(to_rfu_write), .to_rfu_address(to_rfu_address), .to_rfu_input_data(to_rfu_input_data), .to_lsu_act(to_lsu_act), .to_lsu_data(to_lsu_data), .to_alu_act(to_alu_act), .to_alu_data(to_alu_data));

  always_comb begin
    next_state = current_state;
    to_cfu_reset_branch = 1'h0;
    to_ifu_jump = 1'h0;
    to_ifu_next = 1'h0;
    to_lsu_reset_memory_access = 1'h0;
    to_mu_write = 1'h0;
    to_sau_enable = 1'h0;
    if ((next_state) == (3'h0)) begin
      to_cfu_reset_branch = 1'h1;
      to_ifu_jump_address = 15'h0;
      to_ifu_jump = 1'h1;
      to_lsu_reset_memory_access = 1'h1;
      next_state = 3'h1;
    end else if ((next_state) == (3'h1)) begin
      to_mu_address = {from_ifu_current_address, 1'h0};
      to_sau_instruction = from_mu_output_data;
      to_sau_enable = 1'h1;
      to_ifu_next = 1'h1;
      if (from_sau_illegal_instruction) begin
        next_state = 3'h5;
      end else if (from_lsu_memory_access_load_byte) begin
        to_sau_enable = 1'h0;
        to_ifu_next = 1'h0;
        to_mu_address = from_lsu_target_address;
        to_lsu_memory_data = from_mu_output_data;
        next_state = 3'h3;
      end else if (from_cfu_branch) begin
        to_cfu_reset_branch = 1'h1;
        to_ifu_jump_address = from_cfu_branch_address;
        to_ifu_jump = 1'h1;
      end
    end else if ((next_state) == (3'h3)) begin
      to_lsu_memory_data = from_mu_output_data;
      to_lsu_reset_memory_access = 1'h1;
      next_state = 3'h1;
    end
  end

  always_ff @(posedge clock) begin
    if (reset) begin
      current_state <= 3'h0;
    end else begin
      current_state <= next_state;
    end
  end
endmodule
