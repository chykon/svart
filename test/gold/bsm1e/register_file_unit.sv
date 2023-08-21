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
  logic [7:0] register_4;
  logic [7:0] register_5;
  logic [7:0] register_6;
  logic [7:0] register_7;

  always_comb begin
    if ((address) == (7'h0)) begin
      output_data = register_0;
    end else if ((address) == (7'h1)) begin
      output_data = register_1;
    end else if ((address) == (7'h2)) begin
      output_data = register_2;
    end else if ((address) == (7'h3)) begin
      output_data = register_3;
    end else if ((address) == (7'h4)) begin
      output_data = register_4;
    end else if ((address) == (7'h5)) begin
      output_data = register_5;
    end else if ((address) == (7'h6)) begin
      output_data = register_6;
    end else if ((address) == (7'h7)) begin
      output_data = register_7;
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
      end else if ((address) == (7'h4)) begin
        register_4 <= input_data;
      end else if ((address) == (7'h5)) begin
        register_5 <= input_data;
      end else if ((address) == (7'h6)) begin
        register_6 <= input_data;
      end else if ((address) == (7'h7)) begin
        register_7 <= input_data;
      end
    end
  end
endmodule
