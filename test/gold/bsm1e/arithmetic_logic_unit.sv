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
