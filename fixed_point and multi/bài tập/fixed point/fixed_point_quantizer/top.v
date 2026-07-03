module fixed_point_quantizer(
    input signed [11:0] product, // Q5.7
    output signed [8:0] data_trunc, // Q5.4
    output signed [8:0] data_round
);
    assign data_trunc = product[11:3];
endmodule