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
