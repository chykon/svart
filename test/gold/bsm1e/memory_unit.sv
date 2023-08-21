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

  initial begin
    memo_0 = 8'h1;
    memo_1 = 8'hFE;
    memo_2 = 8'h80;
    memo_3 = 8'h1;
    memo_4 = 8'h1;
    memo_5 = 8'h1;
    memo_6 = 8'h81;
    memo_7 = 8'h1;
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
  always_comb begin
    if ((_part0[15:1]) == (_part1[15:1])) begin
      output_data = {memo_1, memo_0};
    end else if ((_part2[15:1]) == (_part3[15:1])) begin
      output_data = {memo_3, memo_2};
    end else if ((_part4[15:1]) == (_part5[15:1])) begin
      output_data = {memo_5, memo_4};
    end else if ((_part6[15:1]) == (_part7[15:1])) begin
      output_data = {memo_7, memo_6};
    end
  end

  logic [15:0] _part8;
  always_comb _part8 = address;
  logic [15:0] _part9;
  always_comb _part9 = 16'h0;
  logic [15:0] _part10;
  always_comb _part10 = address;
  logic [15:0] _part11;
  always_comb _part11 = input_data;
  logic [15:0] _part12;
  always_comb _part12 = input_data;
  logic [15:0] _part13;
  always_comb _part13 = input_data;
  logic [15:0] _part14;
  always_comb _part14 = input_data;
  logic [15:0] _part15;
  always_comb _part15 = address;
  logic [15:0] _part16;
  always_comb _part16 = 16'h2;
  logic [15:0] _part17;
  always_comb _part17 = address;
  logic [15:0] _part18;
  always_comb _part18 = input_data;
  logic [15:0] _part19;
  always_comb _part19 = input_data;
  logic [15:0] _part20;
  always_comb _part20 = input_data;
  logic [15:0] _part21;
  always_comb _part21 = input_data;
  logic [15:0] _part22;
  always_comb _part22 = address;
  logic [15:0] _part23;
  always_comb _part23 = 16'h4;
  logic [15:0] _part24;
  always_comb _part24 = address;
  logic [15:0] _part25;
  always_comb _part25 = input_data;
  logic [15:0] _part26;
  always_comb _part26 = input_data;
  logic [15:0] _part27;
  always_comb _part27 = input_data;
  logic [15:0] _part28;
  always_comb _part28 = input_data;
  logic [15:0] _part29;
  always_comb _part29 = address;
  logic [15:0] _part30;
  always_comb _part30 = 16'h6;
  logic [15:0] _part31;
  always_comb _part31 = address;
  logic [15:0] _part32;
  always_comb _part32 = input_data;
  logic [15:0] _part33;
  always_comb _part33 = input_data;
  logic [15:0] _part34;
  always_comb _part34 = input_data;
  logic [15:0] _part35;
  always_comb _part35 = input_data;
  always_ff @(posedge clock) begin
    if (write) begin
      if ((_part8[15:1]) == (_part9[15:1])) begin
        if (select_byte) begin
          if ((_part10[0:0]) == (1'h0)) begin
            memo_0 <= _part11[7:0];
          end else begin
            memo_1 <= _part12[7:0];
          end
        end else begin
          memo_0 <= _part13[7:0];
          memo_1 <= _part14[15:8];
        end
      end else if ((_part15[15:1]) == (_part16[15:1])) begin
        if (select_byte) begin
          if ((_part17[0:0]) == (1'h0)) begin
            memo_2 <= _part18[7:0];
          end else begin
            memo_3 <= _part19[7:0];
          end
        end else begin
          memo_2 <= _part20[7:0];
          memo_3 <= _part21[15:8];
        end
      end else if ((_part22[15:1]) == (_part23[15:1])) begin
        if (select_byte) begin
          if ((_part24[0:0]) == (1'h0)) begin
            memo_4 <= _part25[7:0];
          end else begin
            memo_5 <= _part26[7:0];
          end
        end else begin
          memo_4 <= _part27[7:0];
          memo_5 <= _part28[15:8];
        end
      end else if ((_part29[15:1]) == (_part30[15:1])) begin
        if (select_byte) begin
          if ((_part31[0:0]) == (1'h0)) begin
            memo_6 <= _part32[7:0];
          end else begin
            memo_7 <= _part33[7:0];
          end
        end else begin
          memo_6 <= _part34[7:0];
          memo_7 <= _part35[15:8];
        end
      end
    end
  end
endmodule
