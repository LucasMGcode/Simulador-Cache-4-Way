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
  integer grid_trace_file;
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

      write_grid_snapshot(label, event_name, expected_line, observed_way);
    end
  endtask

  task write_grid_snapshot;
    input [255:0] label;
    input [127:0] event_name;
    input [LINE_BITS-1:0] active_set;
    input [1:0] active_way;
    integer set_idx;
    integer way_idx;
    reg snapshot_valid;
    reg [TAG_BITS-1:0] snapshot_tag;
    reg [1:0] snapshot_lru;
    begin
      for (set_idx = 0; set_idx < CACHE_LINES; set_idx = set_idx + 1) begin
        for (way_idx = 0; way_idx < WAYS; way_idx = way_idx + 1) begin
          case (way_idx)
            0: begin
              snapshot_valid = Cache.valid0.memory[set_idx];
              snapshot_tag = Cache.tags0.memory[set_idx];
              snapshot_lru = Cache.lru_way0.memory[set_idx];
            end
            1: begin
              snapshot_valid = Cache.valid1.memory[set_idx];
              snapshot_tag = Cache.tags1.memory[set_idx];
              snapshot_lru = Cache.lru_way1.memory[set_idx];
            end
            2: begin
              snapshot_valid = Cache.valid2.memory[set_idx];
              snapshot_tag = Cache.tags2.memory[set_idx];
              snapshot_lru = Cache.lru_way2.memory[set_idx];
            end
            default: begin
              snapshot_valid = Cache.valid3.memory[set_idx];
              snapshot_tag = Cache.tags3.memory[set_idx];
              snapshot_lru = Cache.lru_way3.memory[set_idx];
            end
          endcase

          $fwrite(grid_trace_file,
                  "%0d,%0s,%0s,%0d,%0d,%0d,%0d,%0d,%0d,%0d\n",
                  step,
                  label,
                  event_name,
                  active_set,
                  active_way,
                  set_idx,
                  way_idx,
                  snapshot_valid,
                  snapshot_tag,
                  snapshot_lru);
        end
      end
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
    grid_trace_file = $fopen("trace_grid.csv", "w");
    if (grid_trace_file == 0) begin
      $display("FAIL could not open trace_grid.csv");
      $fatal(1);
    end
    $fwrite(trace_file, "step,label,event,addr,tag,line,blk,hit,selected_way,dout,state,lru0,lru1,lru2,lru3,valid0,valid1,valid2,valid3,tag0,tag1,tag2,tag3\n");
    $fwrite(grid_trace_file, "step,label,event,active_set,active_way,set,way,valid,tag,lru\n");

    din = 8'd0;
    address = 0;
    reset = 1'b1;
    #4;
    reset = 1'b0;

    $display("\n=== VALIDATION TRACE ===");

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

    $fclose(trace_file);
    $fclose(grid_trace_file);

    step = 0;
    address = 0;
    reset = 1'b1;
    #4;
    reset = 1'b0;

    trace_file = $fopen("trace_demo.csv", "w");
    if (trace_file == 0) begin
      $display("FAIL could not open trace_demo.csv");
      $fatal(1);
    end
    grid_trace_file = $fopen("trace_grid_demo.csv", "w");
    if (grid_trace_file == 0) begin
      $display("FAIL could not open trace_grid_demo.csv");
      $fatal(1);
    end
    $fwrite(trace_file, "step,label,event,addr,tag,line,blk,hit,selected_way,dout,state,lru0,lru1,lru2,lru3,valid0,valid1,valid2,valid3,tag0,tag1,tag2,tag3\n");
    $fwrite(grid_trace_file, "step,label,event,active_set,active_way,set,way,valid,tag,lru\n");

    $display("\n=== GLOBAL DEMONSTRATION TRACE ===");

    read_and_check(12'd0,  1'b0, 2'd0, 8'd0,  2'd0, 2'd1, 2'd2, 2'd3, "phase1_fill_set0_way0", "miss-fill");
    read_and_check(12'd16, 1'b0, 2'd1, 8'd16, 2'd1, 2'd0, 2'd2, 2'd3, "phase1_fill_set0_way1", "miss-fill");
    read_and_check(12'd32, 1'b0, 2'd2, 8'd32, 2'd2, 2'd1, 2'd0, 2'd3, "phase1_fill_set0_way2", "miss-fill");
    read_and_check(12'd48, 1'b0, 2'd3, 8'd48, 2'd3, 2'd2, 2'd1, 2'd0, "phase1_fill_set0_way3", "miss-fill");
    read_and_check(12'd4,  1'b0, 2'd0, 8'd4,  2'd0, 2'd1, 2'd2, 2'd3, "phase1_fill_set1_way0", "miss-fill");
    read_and_check(12'd20, 1'b0, 2'd1, 8'd20, 2'd1, 2'd0, 2'd2, 2'd3, "phase1_fill_set1_way1", "miss-fill");
    read_and_check(12'd36, 1'b0, 2'd2, 8'd36, 2'd2, 2'd1, 2'd0, 2'd3, "phase1_fill_set1_way2", "miss-fill");
    read_and_check(12'd52, 1'b0, 2'd3, 8'd52, 2'd3, 2'd2, 2'd1, 2'd0, "phase1_fill_set1_way3", "miss-fill");
    read_and_check(12'd8,  1'b0, 2'd0, 8'd8,  2'd0, 2'd1, 2'd2, 2'd3, "phase1_fill_set2_way0", "miss-fill");
    read_and_check(12'd24, 1'b0, 2'd1, 8'd24, 2'd1, 2'd0, 2'd2, 2'd3, "phase1_fill_set2_way1", "miss-fill");
    read_and_check(12'd40, 1'b0, 2'd2, 8'd40, 2'd2, 2'd1, 2'd0, 2'd3, "phase1_fill_set2_way2", "miss-fill");
    read_and_check(12'd56, 1'b0, 2'd3, 8'd56, 2'd3, 2'd2, 2'd1, 2'd0, "phase1_fill_set2_way3", "miss-fill");
    read_and_check(12'd12, 1'b0, 2'd0, 8'd12, 2'd0, 2'd1, 2'd2, 2'd3, "phase1_fill_set3_way0", "miss-fill");
    read_and_check(12'd28, 1'b0, 2'd1, 8'd28, 2'd1, 2'd0, 2'd2, 2'd3, "phase1_fill_set3_way1", "miss-fill");
    read_and_check(12'd44, 1'b0, 2'd2, 8'd44, 2'd2, 2'd1, 2'd0, 2'd3, "phase1_fill_set3_way2", "miss-fill");
    read_and_check(12'd60, 1'b0, 2'd3, 8'd60, 2'd3, 2'd2, 2'd1, 2'd0, "phase1_fill_set3_way3", "miss-fill");

    read_and_check(12'd0,  1'b1, 2'd0, 8'd0,  2'd0, 2'd3, 2'd2, 2'd1, "phase2_lru_set0_way0", "hit-lru");
    read_and_check(12'd32, 1'b1, 2'd2, 8'd32, 2'd1, 2'd3, 2'd0, 2'd2, "phase2_lru_set0_way2", "hit-lru");
    read_and_check(12'd20, 1'b1, 2'd1, 8'd20, 2'd3, 2'd0, 2'd2, 2'd1, "phase2_lru_set1_way1", "hit-lru");
    read_and_check(12'd52, 1'b1, 2'd3, 8'd52, 2'd3, 2'd1, 2'd2, 2'd0, "phase2_lru_set1_way3", "hit-lru");
    read_and_check(12'd40, 1'b1, 2'd2, 8'd40, 2'd3, 2'd2, 2'd0, 2'd1, "phase2_lru_set2_way2", "hit-lru");
    read_and_check(12'd8,  1'b1, 2'd0, 8'd8,  2'd0, 2'd3, 2'd1, 2'd2, "phase2_lru_set2_way0", "hit-lru");
    read_and_check(12'd60, 1'b1, 2'd3, 8'd60, 2'd3, 2'd2, 2'd1, 2'd0, "phase2_lru_set3_way3", "hit-lru");
    read_and_check(12'd28, 1'b1, 2'd1, 8'd28, 2'd3, 2'd0, 2'd2, 2'd1, "phase2_lru_set3_way1", "hit-lru");

    read_and_check(12'd64, 1'b0, 2'd1, 8'd64, 2'd2, 2'd0, 2'd1, 2'd3, "phase3_replace_set0", "miss-replace");
    read_and_check(12'd68, 1'b0, 2'd0, 8'd68, 2'd0, 2'd2, 2'd3, 2'd1, "phase3_replace_set1", "miss-replace");
    read_and_check(12'd72, 1'b0, 2'd1, 8'd72, 2'd1, 2'd0, 2'd2, 2'd3, "phase3_replace_set2", "miss-replace");
    read_and_check(12'd76, 1'b0, 2'd0, 8'd76, 2'd0, 2'd1, 2'd3, 2'd2, "phase3_replace_set3", "miss-replace");

    read_and_check(12'd1,  1'b1, 2'd0, 8'd1,  2'd0, 2'd1, 2'd2, 2'd3, "phase4_offset_set0_way0", "hit-offset");
    read_and_check(12'd22, 1'b1, 2'd1, 8'd22, 2'd1, 2'd0, 2'd3, 2'd2, "phase4_offset_set1_way1", "hit-offset");
    read_and_check(12'd42, 1'b1, 2'd2, 8'd42, 2'd2, 2'd1, 2'd0, 2'd3, "phase4_offset_set2_way2", "hit-offset");
    read_and_check(12'd63, 1'b1, 2'd3, 8'd63, 2'd1, 2'd2, 2'd3, 2'd0, "phase4_offset_set3_way3", "hit-offset");

    read_and_check(12'd64, 1'b1, 2'd1, 8'd64, 2'd1, 2'd0, 2'd2, 2'd3, "phase5_replaced_hit_set0", "hit-replaced");
    read_and_check(12'd68, 1'b1, 2'd0, 8'd68, 2'd0, 2'd1, 2'd3, 2'd2, "phase5_replaced_hit_set1", "hit-replaced");
    read_and_check(12'd72, 1'b1, 2'd1, 8'd72, 2'd2, 2'd0, 2'd1, 2'd3, "phase5_replaced_hit_set2", "hit-replaced");
    read_and_check(12'd76, 1'b1, 2'd0, 8'd76, 2'd0, 2'd2, 2'd3, 2'd1, "phase5_replaced_hit_set3", "hit-replaced");

    if (failures == 0) begin
      $display("\nALL TESTS PASSED");
      $fclose(trace_file);
      $fclose(grid_trace_file);
      $finish;
    end else begin
      $display("\nTESTS FAILED failures=%0d", failures);
      $fclose(trace_file);
      $fclose(grid_trace_file);
      $fatal(1);
    end
  end
endmodule
