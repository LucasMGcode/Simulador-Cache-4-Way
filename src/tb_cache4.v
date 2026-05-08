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

  integer failures;

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

  task expect_equal;
    input [127:0] label;
    input integer actual;
    input integer expected;
    begin
      if (actual !== expected) begin
        $display("FAIL %-16s expected=%0d actual=%0d", label, expected, actual);
        failures = failures + 1;
      end else begin
        $display("PASS %-16s value=%0d", label, actual);
      end
    end
  endtask

  task read_and_check;
    input [RAM_BITS-1:0] addr;
    input expected_hit;
    input [1:0] expected_way;
    input [7:0] expected_dout;
    input [1:0] expected_lru0;
    input [1:0] expected_lru1;
    input [1:0] expected_lru2;
    input [1:0] expected_lru3;
    input [255:0] label;
    begin
      address = addr;
      @(posedge clk);
      wait(done == 1'b1);
      #1;

      $display("\nACCESS %-24s addr=%0d tag=%0d line=%0d blk=%0d hit=%0b way=%0d dout=%0d lru={%0d,%0d,%0d,%0d}",
               label,
               address,
               Cache.tag,
               Cache.line,
               Cache.blk,
               hit,
               selected_way,
               dout,
               Cache.lru0,
               Cache.lru1,
               Cache.lru2,
               Cache.lru3);

      expect_equal("hit", hit, expected_hit);
      expect_equal("selected_way", selected_way, expected_way);
      expect_equal("dout", dout, expected_dout);

      // LRU metadata is written on the clock edge after done is observed.
      @(posedge clk);
      #1;
      expect_equal("lru0", Cache.lru0, expected_lru0);
      expect_equal("lru1", Cache.lru1, expected_lru1);
      expect_equal("lru2", Cache.lru2, expected_lru2);
      expect_equal("lru3", Cache.lru3, expected_lru3);
    end
  endtask

  initial begin
    $dumpfile("cache4.vcd");
    $dumpvars(0, tb_cache4);

    failures = 0;
    din = 8'd0;
    address = 0;
    reset = 1'b1;
    #4;
    reset = 1'b0;

    read_and_check(12'd0,  1'b0, 2'd0, 8'd0,  2'd0, 2'd1, 2'd2, 2'd3, "miss fills invalid way0");
    read_and_check(12'd16, 1'b0, 2'd1, 8'd16, 2'd1, 2'd0, 2'd2, 2'd3, "miss fills invalid way1");
    read_and_check(12'd32, 1'b0, 2'd2, 8'd32, 2'd2, 2'd1, 2'd0, 2'd3, "miss fills invalid way2");
    read_and_check(12'd48, 1'b0, 2'd3, 8'd48, 2'd3, 2'd2, 2'd1, 2'd0, "miss fills invalid way3");
    read_and_check(12'd0,  1'b1, 2'd0, 8'd0,  2'd0, 2'd3, 2'd2, 2'd1, "hit updates LRU");
    read_and_check(12'd64, 1'b0, 2'd1, 8'd64, 2'd1, 2'd0, 2'd3, 2'd2, "miss replaces LRU way1");

    if (failures == 0) begin
      $display("\nALL TESTS PASSED");
      $finish;
    end else begin
      $display("\nTESTS FAILED failures=%0d", failures);
      $fatal(1);
    end
  end
endmodule
