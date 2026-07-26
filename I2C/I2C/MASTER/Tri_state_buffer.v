module tri_state(
    input sda_en,
    input sda_out,
    output sda_in,
    inout pad
);
    assign pad = sda_en ? sda_out : 1'bz;
    assign sda_in = pad;
endmodule
