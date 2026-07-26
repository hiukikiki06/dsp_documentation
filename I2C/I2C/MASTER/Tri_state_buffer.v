module tri_state(
    input en,       
    input din,
    output dout,
    inout pad
);
    assign pad = en ? din : 1'bz;
    assign dout = pad;
endmodule
