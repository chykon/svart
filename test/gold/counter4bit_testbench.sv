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

module counter4bit_testbench;
  logic clock;
  logic reset;
  logic enable;
  logic [3:0] value;

  counter4bit counter4bit_instance (.clock(clock), .reset(reset), .enable(enable), .value(value));

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, counter4bit_testbench);
    clock = 1'h0;
    reset = 1'h1;
    enable = 1'h0;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h0)) else $fatal;
    reset = 1'h0;
    enable = 1'h1;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h1)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h2)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h3)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h4)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h5)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h6)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h7)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h8)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h9)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'hA)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'hB)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'hC)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'hD)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'hE)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'hF)) else $fatal;
    clock = 1'h0;
    #1;
    clock = 1'h1;
    #1;
    assert ((value) == (4'h0)) else $fatal;
  end
endmodule
