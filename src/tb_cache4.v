`include "cache4_read_only.v"

module tb_cache4();
  parameter CACHE_SIZE = 64;
  parameter RAM_SIZE = 4096;
  parameter BLOCK_SIZE = 4;
  parameter WAYS = 4;
  parameter CACHE_LINES = CACHE_SIZE / (WAYS * BLOCK_SIZE);
  parameter LINE_BITS = 2;
  parameter RAM_BITS = 12;
  parameter BLOCK_BITS = 2;
  parameter TAG_BITS = RAM_BITS - LINE_BITS - BLOCK_BITS;
  parameter WAY_SIZE = CACHE_SIZE / WAYS;

  reg clk;
  reg reset;
  reg [RAM_BITS-1:0] address;
  reg [7:0] din;
  wire [7:0] dout;
  wire done;
  wire hit;
  wire [1:0] selected_way;
  wire [2:0] state_debug;

  cache_4way_read_only #(
    CACHE_SIZE,
    RAM_SIZE,
    BLOCK_SIZE,
    WAYS,
    CACHE_LINES,
    LINE_BITS,
    RAM_BITS,
    BLOCK_BITS,
    TAG_BITS,
    WAY_SIZE
  ) Cache (
    .clk(clk),
    .reset(reset),
    .address(address),
    .din(din),
    .dout(dout),
    .done(done),
    .hit(hit),
    .selected_way(selected_way),
    .state_debug(state_debug)
  );

  initial begin
    clk = 0;
    forever #1 clk = ~clk;
  end

  task read_addr;
    input [RAM_BITS-1:0] addr;
    begin
      address = addr;
      @(posedge clk);
      wait(done == 1'b1);
      #1;
      $display("addr=%0d tag=%0d line=%0d blk=%0d hit=%0b way=%0d dout=%0d state=%0d",
               address,
               Cache.tag,
               Cache.line,
               Cache.blk,
               hit,
               selected_way,
               dout,
               state_debug);
      @(posedge clk);
    end
  endtask

  initial begin
    $dumpfile("cache4.vcd");
    $dumpvars(0, tb_cache4);

    din = 8'd0;
    address = 0;
    reset = 1'b1;
    #4;
    reset = 1'b0;

    read_addr(12'd0);
    read_addr(12'd16);
    read_addr(12'd32);
    read_addr(12'd48);
    read_addr(12'd0);
    read_addr(12'd64);
    read_addr(12'd16);
    read_addr(12'd80);
    read_addr(12'd32);

    $finish;
  end
endmodule
