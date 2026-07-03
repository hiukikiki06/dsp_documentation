module fixed_point_align (
    input signed [5:0] a, // Q2.4
    input signed [7:0] b, // Q4.4
    output wire signed [8:0] sum
);
    wire signed [7:0] a_ext;
    assign a_ext = {{2{a[5]}}, a };
    assign sum = $signed(a_ext) + $signed(b); 
endmodule