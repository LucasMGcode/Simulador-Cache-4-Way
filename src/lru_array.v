module lru_array #(
  parameter LINE_BITS = 2,
  parameter LINES = 4,
  parameter [1:0] RESET_AGE = 2'd0
) (
  input                  clk,
  input                  reset,
  input                  wr,
  input  [LINE_BITS-1:0] line,
  input  [1:0]           din,
  output reg [1:0]       dout
);
  reg [1:0] memory [0:LINES-1];
  integer i;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < LINES; i = i + 1)
        memory[i] <= RESET_AGE;
    end else if (wr) begin
      memory[line] <= din;
    end
  end

  always @(*) begin
    dout = memory[line];
  end
endmodule
