module delay_line #(
    parameter WIDTH = 16,
    parameter DEPTH = 4
)(
    input clk,
    input rst,
    input signed [WIDTH-1:0] din,
    output reg signed [WIDTH-1:0] d0,
    output reg signed [WIDTH-1:0] d1,
    output reg signed [WIDTH-1:0] d2,
    output reg signed [WIDTH-1:0] d3
);
    always @(posedge clk) begin
        if (rst) begin
            d0 <= 0;
            d1 <= 0;
            d2 <= 0;
            d3 <= 0;
        end
        else begin
            d0 <= din;
            d1 <= d0;
            d2 <= d1;
            d3 <= d2;
        end
    end
endmodule