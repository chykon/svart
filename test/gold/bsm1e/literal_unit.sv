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
