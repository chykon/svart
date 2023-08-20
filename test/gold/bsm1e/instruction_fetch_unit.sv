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
