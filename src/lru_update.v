module lru_update(
  input        enable,
  input  [1:0] current_age,
  input  [1:0] accessed_age,
  output reg [1:0] next_age
);
  always @(*) begin
    next_age = current_age;

    if (enable) begin
      if (current_age == accessed_age)
        next_age = 2'd0;
      else if (current_age < accessed_age)
        next_age = current_age + 1'b1;
      else
        next_age = current_age;
    end
  end
endmodule
