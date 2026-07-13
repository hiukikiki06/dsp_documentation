module uart_tx (
    input clk,
    input reset,
    input tx_start,         // Tín hiệu kích hoạt truyền
    input tick,             // Xung từ bộ Baud Rate Gen
    input [7:0] din,        // Dữ liệu 8-bit đầu vào
    output reg tx_done_tick,// Báo hiệu đã truyền xong
    output reg tx           // Chân Tx nối tiếp đầu ra
);

    // Định nghĩa các trạng thái
    localparam [1:0] IDLE  = 2'b00,
                     START = 2'b01,
                     DATA  = 2'b10,
                     STOP  = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;       // Đếm từ 0 đến 15 (đủ 16 ticks cho 1 bit)
    reg [2:0] n_reg, n_next;       // Đếm số bit dữ liệu đã truyền (0 đến 7)
    reg [7:0] b_reg, b_next;       // Thanh ghi dịch lưu dữ liệu truyền
    reg tx_reg, tx_next;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1'b1; // UART mặc định ở mức cao (High) khi rảnh
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end

    always @* begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;
        tx_done_tick = 1'b0;

        case (state_reg)
            IDLE: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    state_next = START;
                    s_next = 0;
                    b_next = din;
                end
            end
            
            START: begin
                tx_next = 1'b0; // Bit Start luôn là 0
                if (tick) begin
                    if (s_reg == 15) begin
                        state_next = DATA;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = b_reg[0]; // Truyền bit LSB trước
                if (tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = b_reg >> 1; // Dịch phải để chuẩn bị bit tiếp theo
                        if (n_reg == 7)
                            state_next = STOP;
                        else
                            n_next = n_reg + 1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1; // Bit Stop luôn là 1
                if (tick) begin
                    if (s_reg == 15) begin
                        state_next = IDLE;
                        tx_done_tick = 1'b1; // Báo truyền xong
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
        endcase
    end

    always @(posedge clk) tx <= tx_reg;
endmodule