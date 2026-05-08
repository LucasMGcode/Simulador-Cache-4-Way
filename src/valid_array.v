module valid_array #(
  parameter LINE_BITS = 2,
  parameter LINES = 4
) (
  input                  clk,
  input                  reset,
  input                  wr,
  input  [LINE_BITS-1:0] line,
  output reg             dout
);
  reg memory [0:LINES-1];
  integer i;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < LINES; i = i + 1)
        memory[i] <= 1'b0;
    end else if (wr) begin
      memory[line] <= 1'b1;
    end
  end

  always @(*) begin
    dout = memory[line];
  end
endmodule
