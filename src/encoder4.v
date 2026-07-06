module encoder4(
  input  [3:0] in,
  output [1:0] sel,
  output       hit
);
  assign hit = |in;

  assign sel[1] = in[3] | in[2];
  assign sel[0] = in[3] | in[1];
endmodule
