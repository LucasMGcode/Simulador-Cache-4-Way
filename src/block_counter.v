module block_counter #(
  parameter BLOCK_BITS = 2,
  parameter BLOCK_SIZE = 4
) (
  input                    clk,
  input                    reset,
  input                    enable,
  output reg [BLOCK_BITS-1:0] out,
  output                   done
);
  assign done = (out == BLOCK_SIZE - 1);

  always @(posedge clk or posedge reset) begin
    if (reset)
      out <= {BLOCK_BITS{1'b0}};
    else if (enable)
      out <= out + 1'b1;
  end
endmodule
