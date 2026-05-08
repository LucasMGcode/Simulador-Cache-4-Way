`include "encoder4.v"
`include "decoder2to4.v"
`include "comparator.v"
`include "tag_array.v"
`include "valid_array.v"
`include "data_array.v"
`include "ram.v"
`include "block_counter.v"
`include "lru_update.v"
`include "lru_array.v"
`include "cache4_fsm.v"

module cache_4way_read_only #(
  parameter CACHE_SIZE = 64,
  parameter RAM_SIZE = 4096,
  parameter BLOCK_SIZE = 4,
  parameter WAYS = 4,
  parameter CACHE_LINES = CACHE_SIZE / (WAYS * BLOCK_SIZE),
  parameter LINE_BITS = 2,
  parameter RAM_BITS = 12,
  parameter BLOCK_BITS = 2,
  parameter TAG_BITS = RAM_BITS - LINE_BITS - BLOCK_BITS,
  parameter WAY_SIZE = CACHE_SIZE / WAYS
) (
  input                 clk,
  input                 reset,
  input  [RAM_BITS-1:0] address,
  input  [7:0]          din,
  output [7:0]          dout,
  output                done,
  output                hit,
  output [1:0]          selected_way,
  output [2:0]          state_debug
);
  wire [TAG_BITS-1:0] tag;
  wire [LINE_BITS-1:0] line;
  wire [BLOCK_BITS-1:0] blk;

  assign tag = address[RAM_BITS-1:LINE_BITS+BLOCK_BITS];
  assign line = address[LINE_BITS+BLOCK_BITS-1:BLOCK_BITS];
  assign blk = address[BLOCK_BITS-1:0];

  wire [TAG_BITS-1:0] tag0, tag1, tag2, tag3;
  wire v0, v1, v2, v3;
  wire c0, c1, c2, c3;
  wire [3:0] hit_bits;
  wire [1:0] hit_way;

  comparator #(TAG_BITS) cmp0(.tag(tag), .stored_tag(tag0), .equal(c0));
  comparator #(TAG_BITS) cmp1(.tag(tag), .stored_tag(tag1), .equal(c1));
  comparator #(TAG_BITS) cmp2(.tag(tag), .stored_tag(tag2), .equal(c2));
  comparator #(TAG_BITS) cmp3(.tag(tag), .stored_tag(tag3), .equal(c3));

  assign hit_bits = {c3 & v3, c2 & v2, c1 & v1, c0 & v0};
  encoder4 hit_encoder(.in(hit_bits), .sel(hit_way), .hit(hit));

  wire [1:0] lru0, lru1, lru2, lru3;
  wire [1:0] lru_new0, lru_new1, lru_new2, lru_new3;
  wire [1:0] lru_victim;

  assign lru_victim = (lru0 == 2'd3) ? 2'd0 :
                      (lru1 == 2'd3) ? 2'd1 :
                      (lru2 == 2'd3) ? 2'd2 : 2'd3;

  wire [1:0] fill_way;
  assign fill_way = (!v0) ? 2'd0 :
                    (!v1) ? 2'd1 :
                    (!v2) ? 2'd2 :
                    (!v3) ? 2'd3 : lru_victim;

  assign selected_way = hit ? hit_way : fill_way;

  wire fill_active;
  wire write_tag_valid;
  wire update_lru;
  wire use_counter_addr;
  wire counter_reset;
  wire [BLOCK_BITS-1:0] counter_blk;
  wire block_done;
  wire [BLOCK_BITS-1:0] cache_blk;
  wire [RAM_BITS-1:0] ram_addr;
  wire [7:0] ram_dout;

  assign cache_blk = use_counter_addr ? counter_blk : blk;
  assign ram_addr = {tag, line, counter_blk};

  cache4_fsm fsm(
    .clk(clk),
    .reset(reset),
    .hit(hit),
    .block_done(block_done),
    .fill_active(fill_active),
    .write_tag_valid(write_tag_valid),
    .update_lru(update_lru),
    .done(done),
    .use_counter_addr(use_counter_addr),
    .counter_reset(counter_reset),
    .state_debug(state_debug)
  );

  block_counter #(BLOCK_BITS, BLOCK_SIZE) counter(
    .clk(clk),
    .reset(reset | counter_reset),
    .enable(fill_active),
    .out(counter_blk),
    .done(block_done)
  );

  ram #(RAM_BITS, RAM_SIZE) main_memory(
    .clk(clk),
    .reset(reset),
    .wr(1'b0),
    .addr(ram_addr),
    .din(din),
    .dout(ram_dout)
  );

  wire [3:0] write_way;
  decoder2to4 write_decoder(.sel(fill_way), .out(write_way));

  tag_array #(LINE_BITS, TAG_BITS, CACHE_LINES) tags0(.clk(clk), .reset(reset), .wr(write_tag_valid & write_way[0]), .line(line), .din(tag), .dout(tag0));
  tag_array #(LINE_BITS, TAG_BITS, CACHE_LINES) tags1(.clk(clk), .reset(reset), .wr(write_tag_valid & write_way[1]), .line(line), .din(tag), .dout(tag1));
  tag_array #(LINE_BITS, TAG_BITS, CACHE_LINES) tags2(.clk(clk), .reset(reset), .wr(write_tag_valid & write_way[2]), .line(line), .din(tag), .dout(tag2));
  tag_array #(LINE_BITS, TAG_BITS, CACHE_LINES) tags3(.clk(clk), .reset(reset), .wr(write_tag_valid & write_way[3]), .line(line), .din(tag), .dout(tag3));

  valid_array #(LINE_BITS, CACHE_LINES) valid0(.clk(clk), .reset(reset), .wr(write_tag_valid & write_way[0]), .line(line), .dout(v0));
  valid_array #(LINE_BITS, CACHE_LINES) valid1(.clk(clk), .reset(reset), .wr(write_tag_valid & write_way[1]), .line(line), .dout(v1));
  valid_array #(LINE_BITS, CACHE_LINES) valid2(.clk(clk), .reset(reset), .wr(write_tag_valid & write_way[2]), .line(line), .dout(v2));
  valid_array #(LINE_BITS, CACHE_LINES) valid3(.clk(clk), .reset(reset), .wr(write_tag_valid & write_way[3]), .line(line), .dout(v3));

  wire [7:0] data0, data1, data2, data3;

  data_array #(LINE_BITS, BLOCK_BITS, WAY_SIZE) data_way0(.clk(clk), .wr(fill_active & write_way[0]), .line(line), .blk(cache_blk), .din(ram_dout), .dout(data0));
  data_array #(LINE_BITS, BLOCK_BITS, WAY_SIZE) data_way1(.clk(clk), .wr(fill_active & write_way[1]), .line(line), .blk(cache_blk), .din(ram_dout), .dout(data1));
  data_array #(LINE_BITS, BLOCK_BITS, WAY_SIZE) data_way2(.clk(clk), .wr(fill_active & write_way[2]), .line(line), .blk(cache_blk), .din(ram_dout), .dout(data2));
  data_array #(LINE_BITS, BLOCK_BITS, WAY_SIZE) data_way3(.clk(clk), .wr(fill_active & write_way[3]), .line(line), .blk(cache_blk), .din(ram_dout), .dout(data3));

  assign dout = (selected_way == 2'd3) ? data3 :
                (selected_way == 2'd2) ? data2 :
                (selected_way == 2'd1) ? data1 : data0;

  wire [1:0] accessed_age;
  assign accessed_age = (selected_way == 2'd3) ? lru3 :
                        (selected_way == 2'd2) ? lru2 :
                        (selected_way == 2'd1) ? lru1 : lru0;

  lru_update lru_update0(.enable(update_lru), .current_age(lru0), .accessed_age(accessed_age), .next_age(lru_new0));
  lru_update lru_update1(.enable(update_lru), .current_age(lru1), .accessed_age(accessed_age), .next_age(lru_new1));
  lru_update lru_update2(.enable(update_lru), .current_age(lru2), .accessed_age(accessed_age), .next_age(lru_new2));
  lru_update lru_update3(.enable(update_lru), .current_age(lru3), .accessed_age(accessed_age), .next_age(lru_new3));

  lru_array #(LINE_BITS, CACHE_LINES, 2'd0) lru_way0(.clk(clk), .reset(reset), .wr(update_lru), .line(line), .din(lru_new0), .dout(lru0));
  lru_array #(LINE_BITS, CACHE_LINES, 2'd1) lru_way1(.clk(clk), .reset(reset), .wr(update_lru), .line(line), .din(lru_new1), .dout(lru1));
  lru_array #(LINE_BITS, CACHE_LINES, 2'd2) lru_way2(.clk(clk), .reset(reset), .wr(update_lru), .line(line), .din(lru_new2), .dout(lru2));
  lru_array #(LINE_BITS, CACHE_LINES, 2'd3) lru_way3(.clk(clk), .reset(reset), .wr(update_lru), .line(line), .din(lru_new3), .dout(lru3));
endmodule
