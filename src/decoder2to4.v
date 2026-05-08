module decoder2to4(
  input  [1:0] sel,
  output [3:0] out
);
  assign out[0] = (sel == 2'd0);
  assign out[1] = (sel == 2'd1);
  assign out[2] = (sel == 2'd2);
  assign out[3] = (sel == 2'd3);
endmodule
