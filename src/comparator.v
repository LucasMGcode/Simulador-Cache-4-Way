module comparator #(
  parameter TAG_BITS = 8
) (
  input  [TAG_BITS-1:0] tag,
  input  [TAG_BITS-1:0] stored_tag,
  output                equal
);
  assign equal = (tag == stored_tag);
endmodule
