module utf8decoder (
  input logic clock,
  input logic reset,
  input logic enable,
  input logic [7:0] octet,
  output logic [2:0] status,
  output logic [20:0] codepoint
);
  logic [1:0] bytes_seen;
  logic [1:0] bytes_needed;
  logic [7:0] lower_boundary;
  logic [7:0] upper_boundary;

  always_ff @(posedge clock) begin
    if (reset) begin
      codepoint <= 21'h0;
      bytes_seen <= 2'h0;
      bytes_needed <= 2'h0;
      lower_boundary <= 8'h80;
      upper_boundary <= 8'hBF;
      status <= 3'h0;
    end else begin
      if (enable) begin
        if ((bytes_needed) == (2'h0)) begin
          if (((octet) >= (8'h0)) & ((octet) <= (8'h7F))) begin
            codepoint <= {13'h0, octet};
            status <= 3'h2;
          end else if (((octet) >= (8'hC2)) & ((octet) <= (8'hDF))) begin
            bytes_needed <= 2'h1;
            codepoint <= {13'h0, (octet) & (8'h1F)};
            status <= 3'h1;
          end else if (((octet) >= (8'hE0)) & ((octet) <= (8'hEF))) begin
            if ((octet) == (8'hE0)) begin
              lower_boundary <= 8'hA0;
            end else begin
              if ((octet) == (8'hED)) begin
                upper_boundary <= 8'h9F;
              end
            end
            bytes_needed <= 2'h2;
            codepoint <= {13'h0, (octet) & (8'hF)};
            status <= 3'h1;
          end else if (((octet) >= (8'hF0)) & ((octet) <= (8'hF4))) begin
            if ((octet) == (8'hF0)) begin
              lower_boundary <= 8'h90;
            end else begin
              if ((octet) == (8'hF4)) begin
                upper_boundary <= 8'h8F;
              end
            end
            bytes_needed <= 2'h3;
            codepoint <= {13'h0, (octet) & (8'h7)};
            status <= 3'h1;
          end else begin
            status <= 3'h3;
          end
        end else begin
          if (((octet) >= (lower_boundary)) & ((octet) <= (upper_boundary))) begin
            lower_boundary <= 8'h80;
            upper_boundary <= 8'hBF;
            codepoint <= ((codepoint) << 6) | ({13'h0, (octet) & (8'h3F)});
            if (((bytes_seen) + (2'h1)) == (bytes_needed)) begin
              bytes_needed <= 2'h0;
              bytes_seen <= 2'h0;
              status <= 3'h2;
            end else begin
              bytes_seen <= (bytes_seen) + (2'h1);
            end
          end else begin
            codepoint <= 21'h0;
            bytes_needed <= 2'h0;
            bytes_seen <= 2'h0;
            lower_boundary <= 8'h80;
            upper_boundary <= 8'hBF;
            status <= 3'h4;
          end
        end
      end
    end
  end
endmodule
