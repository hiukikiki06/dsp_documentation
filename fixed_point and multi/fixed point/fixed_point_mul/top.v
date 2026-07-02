module fixed_point_mul(
    input signed [5:0] a, // Q2.4
    input signed [5:0] b, // Q3.3
    output signed [11:0] product // Q5.7
);
    assign product = a * b;
endmodule