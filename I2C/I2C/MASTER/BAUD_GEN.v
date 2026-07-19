module baud_gen(
    input clk, // xung clk hệ thống 50Mhz
    input rst,
    output reg scl_clk // chia thành 100khz
);
    reg [7:0] clk_cnt;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scl_clk <= 0;
            clk_cnt <=0;
        end
        else begin
            if (clk_cnt == 249) begin
                scl_clk <= ~scl_clk;
                clk_cnt <= 0;
            end
            else clk_cnt <= clk_cnt + 1;
        end
    end
endmodule

