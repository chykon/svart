module counter4bit (
  input logic clock,
  input logic reset,
  input logic enable,
  output logic [3:0] value
);
  always_ff @(posedge clock) begin
    if (reset) begin
      value <= 4'h0;
    end else begin
      if (enable) begin
        value <= (value) + (4'h1);
      end
    end
  end
endmodule
