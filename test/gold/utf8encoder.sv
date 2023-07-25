module utf8encoder (
  input logic [20:0] codepoint,
  output logic status,
  output logic [31:0] bytes
);
  logic [1:0] count;
  logic [7:0] offset;
  logic [7:0] octet;

  logic [20:0] _part0;
  logic [20:0] _part1;
  logic [31:0] _part2;
  logic [31:0] _part3;
  logic [20:0] _part4;
  logic [31:0] _part5;
  logic [31:0] _part6;
  logic [20:0] _part7;
  logic [31:0] _part8;
  always_comb begin
    count = 2'h0;
    if (((codepoint) >= (21'h0)) & ((codepoint) <= (21'h7F))) begin
      bytes = {11'h0, codepoint};
      status = 1'h0;
    end else if (((codepoint) >= (21'h80)) & ((codepoint) <= (21'h7FF))) begin
      count = 2'h1;
      offset = 8'hC0;
    end else if (((codepoint) >= (21'h800)) & ((codepoint) <= (21'hFFFF))) begin
      count = 2'h2;
      offset = 8'hE0;
    end else if (((codepoint) >= (21'h10000)) & ((codepoint) <= (21'h10FFFF))) begin
      count = 2'h3;
      offset = 8'hF0;
    end else begin
      status = 1'h1;
    end
    if ((count) != (2'h0)) begin
      _part0 = ((codepoint) >> ((5'h6) * ({3'h0, count}))) + ({13'h0, offset});
      octet = _part0[7:0];
      bytes = {24'h0, octet};
      _part1 = (21'h80) | (((codepoint) >> ((4'h6) * ({2'h0, (count) - (2'h1)}))) & (21'h3F));
      octet = _part1[7:0];
      _part2 = bytes;
      _part3 = bytes;
      bytes = {{_part2[31:16], octet}, _part3[7:0]};
      count = (count) - (2'h1);
      if ((count) == (2'h0)) begin
        status = 1'h0;
      end else begin
        _part4 = (21'h80) | (((codepoint) >> ((3'h6) * ({1'h0, (count) - (2'h1)}))) & (21'h3F));
        octet = _part4[7:0];
        _part5 = bytes;
        _part6 = bytes;
        bytes = {{_part5[31:24], octet}, _part6[15:0]};
        count = (count) - (2'h1);
        if ((count) == (2'h0)) begin
          status = 1'h0;
        end else begin
          _part7 = (21'h80) | ((codepoint) & (21'h3F));
          octet = _part7[7:0];
          _part8 = bytes;
          bytes = {octet, _part8[23:0]};
          status = 1'h0;
        end
      end
    end
  end
endmodule
