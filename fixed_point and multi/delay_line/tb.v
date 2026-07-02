`timescale 1ns/1ps

module tb;

    parameter WIDTH = 8;
    parameter DEPTH = 4;

    // DUT input
    reg clk;
    reg rst;
    reg signed [WIDTH-1:0] din;

    // DUT output
    wire signed [WIDTH-1:0] d0;
    wire signed [WIDTH-1:0] d1;
    wire signed [WIDTH-1:0] d2;
    wire signed [WIDTH-1:0] d3;

    //==================================================
    // DUT
    //==================================================
    delay_line #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .d0(d0),
        .d1(d1),
        .d2(d2),
        .d3(d3)
    );

    //==================================================
    // Clock Generation (10ns period)
    //==================================================
    initial clk = 0;
    always #5 clk = ~clk;

    //==================================================
    // Dump waveform
    //==================================================
    initial begin
        $dumpfile("delay_line.vcd");
        $dumpvars(0, tb);
    end

    //==================================================
    // Monitor
    //==================================================
    initial begin
        $display("-----------------------------------------------");
        $display(" Time   din   d0   d1   d2   d3");
        $display("-----------------------------------------------");

        $monitor("%4t   %4d  %4d %4d %4d %4d",
                 $time, din, d0, d1, d2, d3);
    end

    //==================================================
    // Stimulus
    //==================================================
    initial begin

        rst = 1;
        din = 0;

        // giữ reset qua 2 chu kỳ clock
        repeat(2) @(posedge clk);

        rst = 0;

        @(posedge clk);
        din = 1;

        @(posedge clk);
        din = 2;

        @(posedge clk);
        din = 3;

        @(posedge clk);
        din = 4;

        @(posedge clk);
        din = 5;

        @(posedge clk);
        din = -2;

        @(posedge clk);
        din = 7;

        repeat(3) @(posedge clk);

        $finish;

    end

endmodule