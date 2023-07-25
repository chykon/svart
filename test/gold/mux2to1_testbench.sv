module mux2to1 (
  input logic a,
  input logic b,
  input logic sel,
  output logic y
);
  always_comb begin
    if (sel) begin
      y = a;
    end else begin
      y = b;
    end
  end
endmodule

module mux2to1_testbench;
  logic a;
  logic b;
  logic sel;
  logic y;

  mux2to1 mux2to1_instance (.a(a), .b(b), .sel(sel), .y(y));

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, mux2to1_testbench);
    a = 1'h0;
    b = 1'h0;
    sel = 1'h0;
    #1;
    assert ((y) == (1'h0)) else $fatal;
    a = 1'h1;
    b = 1'h0;
    sel = 1'h0;
    #1;
    assert ((y) == (1'h0)) else $fatal;
    a = 1'h0;
    b = 1'h1;
    sel = 1'h0;
    #1;
    assert ((y) == (1'h1)) else $fatal;
    a = 1'h1;
    b = 1'h1;
    sel = 1'h0;
    #1;
    assert ((y) == (1'h1)) else $fatal;
    a = 1'h0;
    b = 1'h0;
    sel = 1'h1;
    #1;
    assert ((y) == (1'h0)) else $fatal;
    a = 1'h1;
    b = 1'h0;
    sel = 1'h1;
    #1;
    assert ((y) == (1'h1)) else $fatal;
    a = 1'h0;
    b = 1'h1;
    sel = 1'h1;
    #1;
    assert ((y) == (1'h0)) else $fatal;
    a = 1'h1;
    b = 1'h1;
    sel = 1'h1;
    #1;
    assert ((y) == (1'h1)) else $fatal;
  end
endmodule
