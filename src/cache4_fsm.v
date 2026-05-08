module cache4_fsm(
  input        clk,
  input        reset,
  input        hit,
  input        block_done,
  output reg   fill_active,
  output reg   write_tag_valid,
  output reg   update_lru,
  output reg   done,
  output reg   use_counter_addr,
  output reg   counter_reset,
  output reg [2:0] state_debug
);
  parameter COMPARE    = 3'd0;
  parameter HIT        = 3'd1;
  parameter MISS       = 3'd2;
  parameter FILL_BLOCK = 3'd3;
  parameter UPDATE_TAG = 3'd4;

  reg [2:0] state;
  reg [2:0] next_state;

  always @(posedge clk or posedge reset) begin
    if (reset)
      state <= COMPARE;
    else
      state <= next_state;
  end

  always @(*) begin
    next_state = state;

    case (state)
      COMPARE:
        next_state = hit ? HIT : MISS;

      HIT:
        next_state = COMPARE;

      MISS:
        next_state = FILL_BLOCK;

      FILL_BLOCK:
        next_state = block_done ? UPDATE_TAG : FILL_BLOCK;

      UPDATE_TAG:
        next_state = COMPARE;

      default:
        next_state = COMPARE;
    endcase
  end

  always @(*) begin
    fill_active     = (state == FILL_BLOCK);
    write_tag_valid = (state == UPDATE_TAG);
    update_lru      = (state == HIT) || (state == UPDATE_TAG);
    done            = (state == HIT) || (state == UPDATE_TAG);
    use_counter_addr = (state == FILL_BLOCK);
    counter_reset   = (state != FILL_BLOCK);
    state_debug     = state;
  end
endmodule
