module tag_array #(
  parameter LINE_BITS = 2,
  parameter TAG_BITS = 8,
  parameter LINES = 4
) (
  input                      clk,
  input                      reset,
  input                      wr,
  input  [LINE_BITS-1:0]     line,
  input  [TAG_BITS-1:0]      din,
  output reg [TAG_BITS-1:0]  dout
);
  reg [TAG_BITS-1:0] memory [0:LINES-1];
  integer i;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < LINES; i = i + 1)
        memory[i] <= {TAG_BITS{1'b0}};
    end else if (wr) begin
      memory[line] <= din;
    end
  end

  always @(*) begin
    dout = memory[line];
  end
endmodule
