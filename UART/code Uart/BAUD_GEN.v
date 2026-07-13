module baud_rate_generator (
    input clk,          // Clock hệ thống (50MHz)
    input reset,        // Reset tích cực cao
    output reg tick     // Xung tick cho Rx và Tx (gấp 16 lần Baud rate)
);

    reg [8:0] counter; // 326 cần 9 bits (2^9 = 512)

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            tick <= 0;
        end else begin
            if (counter == 325) begin // Đếm từ 0 đến 325 là 326 chu kỳ
                counter <= 0;
                tick <= 1;
            end else begin
                counter <= counter + 1;
                tick <= 0;
            end
        end
    end
endmodule