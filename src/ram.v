module ram #(
  parameter RAM_BITS = 12,
  parameter RAM_SIZE = 4096
) (
  input                clk,
  input                reset,
  input                wr,
  input  [RAM_BITS-1:0] addr,
  input  [7:0]         din,
  output reg [7:0]     dout
);
  reg [7:0] memory [0:RAM_SIZE-1];
  integer i;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < RAM_SIZE; i = i + 1)
        memory[i] <= i[7:0];
    end else if (wr) begin
      memory[addr] <= din;
    end
  end

  always @(*) begin
    dout = memory[addr];
  end
endmodule
