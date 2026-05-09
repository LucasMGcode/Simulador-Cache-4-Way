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
  integer trace_file;
  integer step;

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
    input [127:0] event_name;
    reg observed_hit;
    reg [1:0] observed_way;
    reg [7:0] observed_dout;
    reg [2:0] observed_state;
    reg [TAG_BITS-1:0] expected_tag;
    reg [LINE_BITS-1:0] expected_line;
    reg [BLOCK_BITS-1:0] expected_blk;
    begin
      step = step + 1;
      expected_tag = addr[RAM_BITS-1:LINE_BITS+BLOCK_BITS];
      expected_line = addr[LINE_BITS+BLOCK_BITS-1:BLOCK_BITS];
      expected_blk = addr[BLOCK_BITS-1:0];

      address = addr;
      @(posedge clk);
      wait(done == 1'b1);
      #1;

      observed_hit = hit;
      observed_way = selected_way;
      observed_dout = dout;
      observed_state = state_debug;

      $display("\nACCESS %-24s addr=%0d tag=%0d line=%0d blk=%0d hit=%0b way=%0d dout=%0d lru={%0d,%0d,%0d,%0d}",
               label,
               address,
               Cache.tag,
               Cache.line,
               Cache.blk,
               observed_hit,
               observed_way,
               observed_dout,
               Cache.lru0,
               Cache.lru1,
               Cache.lru2,
               Cache.lru3);

      expect_equal("hit", observed_hit, expected_hit);
      expect_equal("selected_way", observed_way, expected_way);
      expect_equal("dout", observed_dout, expected_dout);
      expect_equal("tag", Cache.tag, expected_tag);
      expect_equal("line", Cache.line, expected_line);
      expect_equal("blk", Cache.blk, expected_blk);

      // LRU, tag and valid metadata are written on the clock edge after done is observed.
      @(posedge clk);
      #1;
      expect_equal("lru0", Cache.lru0, expected_lru0);
      expect_equal("lru1", Cache.lru1, expected_lru1);
      expect_equal("lru2", Cache.lru2, expected_lru2);
      expect_equal("lru3", Cache.lru3, expected_lru3);

      $fwrite(trace_file,
              "%0d,%0s,%0s,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
              step,
              label,
              event_name,
              address,
              Cache.tag,
              Cache.line,
              Cache.blk,
              observed_hit,
              observed_way,
              observed_dout,
              observed_state,
              Cache.lru0,
              Cache.lru1,
              Cache.lru2,
              Cache.lru3,
              Cache.v0,
              Cache.v1,
              Cache.v2,
              Cache.v3,
              Cache.tag0,
              Cache.tag1,
              Cache.tag2,
              Cache.tag3);
    end
  endtask

  initial begin
    $dumpfile("cache4.vcd");
    $dumpvars(0, tb_cache4);

    failures = 0;
    step = 0;
    trace_file = $fopen("trace.csv", "w");
    if (trace_file == 0) begin
      $display("FAIL could not open trace.csv");
      $fatal(1);
    end
    $fwrite(trace_file, "step,label,event,addr,tag,line,blk,hit,selected_way,dout,state,lru0,lru1,lru2,lru3,valid0,valid1,valid2,valid3,tag0,tag1,tag2,tag3\n");

    din = 8'd0;
    address = 0;
    reset = 1'b1;
    #4;
    reset = 1'b0;

    read_and_check(12'd0,  1'b0, 2'd0, 8'd0,  2'd0, 2'd1, 2'd2, 2'd3, "miss_fills_invalid_way0", "miss-fill");
    read_and_check(12'd16, 1'b0, 2'd1, 8'd16, 2'd1, 2'd0, 2'd2, 2'd3, "miss_fills_invalid_way1", "miss-fill");
    read_and_check(12'd32, 1'b0, 2'd2, 8'd32, 2'd2, 2'd1, 2'd0, 2'd3, "miss_fills_invalid_way2", "miss-fill");
    read_and_check(12'd48, 1'b0, 2'd3, 8'd48, 2'd3, 2'd2, 2'd1, 2'd0, "miss_fills_invalid_way3", "miss-fill");
    read_and_check(12'd0,  1'b1, 2'd0, 8'd0,  2'd0, 2'd3, 2'd2, 2'd1, "hit_updates_lru", "hit");
    read_and_check(12'd64, 1'b0, 2'd1, 8'd64, 2'd1, 2'd0, 2'd3, 2'd2, "miss_replaces_lru_way1", "miss-replace");

    read_and_check(12'd4,  1'b0, 2'd0, 8'd4,  2'd0, 2'd1, 2'd2, 2'd3, "line1_miss_way0", "miss-line");
    read_and_check(12'd8,  1'b0, 2'd0, 8'd8,  2'd0, 2'd1, 2'd2, 2'd3, "line2_miss_way0", "miss-line");
    read_and_check(12'd12, 1'b0, 2'd0, 8'd12, 2'd0, 2'd1, 2'd2, 2'd3, "line3_miss_way0", "miss-line");
    read_and_check(12'd4,  1'b1, 2'd0, 8'd4,  2'd0, 2'd1, 2'd2, 2'd3, "line1_hit_way0", "hit-line");
    read_and_check(12'd8,  1'b1, 2'd0, 8'd8,  2'd0, 2'd1, 2'd2, 2'd3, "line2_hit_way0", "hit-line");
    read_and_check(12'd12, 1'b1, 2'd0, 8'd12, 2'd0, 2'd1, 2'd2, 2'd3, "line3_hit_way0", "hit-line");

    read_and_check(12'd26, 1'b0, 2'd1, 8'd26, 2'd1, 2'd0, 2'd2, 2'd3, "offset2_miss_way1", "miss-offset");
    read_and_check(12'd24, 1'b1, 2'd1, 8'd24, 2'd1, 2'd0, 2'd2, 2'd3, "offset0_hit_way1", "hit-offset");
    read_and_check(12'd25, 1'b1, 2'd1, 8'd25, 2'd1, 2'd0, 2'd2, 2'd3, "offset1_hit_way1", "hit-offset");
    read_and_check(12'd26, 1'b1, 2'd1, 8'd26, 2'd1, 2'd0, 2'd2, 2'd3, "offset2_hit_way1", "hit-offset");
    read_and_check(12'd27, 1'b1, 2'd1, 8'd27, 2'd1, 2'd0, 2'd2, 2'd3, "offset3_hit_way1", "hit-offset");

    if (failures == 0) begin
      $display("\nALL TESTS PASSED");
      $fclose(trace_file);
      $finish;
    end else begin
      $display("\nTESTS FAILED failures=%0d", failures);
      $fclose(trace_file);
      $fatal(1);
    end
  end
endmodule
