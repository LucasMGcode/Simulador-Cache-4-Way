module data_array #(
  parameter LINE_BITS = 2,
  parameter BLOCK_BITS = 2,
  parameter WAY_SIZE = 16
) (
  input                  clk,
  input                  wr,
  input  [LINE_BITS-1:0] line,
  input  [BLOCK_BITS-1:0] blk,
  input  [7:0]           din,
  output reg [7:0]       dout
);
  reg [7:0] memory [0:WAY_SIZE-1];
  wire [LINE_BITS+BLOCK_BITS-1:0] index;

  assign index = {line, blk};

  always @(posedge clk) begin
    if (wr)
      memory[index] <= din;
  end

  always @(*) begin
    dout = memory[index];
  end
endmodule
