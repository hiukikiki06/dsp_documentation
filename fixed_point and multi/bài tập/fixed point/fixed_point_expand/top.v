module top(
    input signed [5:0] a, // Q2.4
    input signed [5:0] b, // Q3.3
    output signed [8:0] sum // Q5.4
);
    wire signed [7:0] b_ex;
	 wire signed [7:0] a_ex;
	 assign a_ex = {{2{a[5]}}, a};
    assign b_ex = b <<< 1;
    assign sum = b_ex + a;
endmodule