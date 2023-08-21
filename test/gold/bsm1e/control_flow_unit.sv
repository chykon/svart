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
