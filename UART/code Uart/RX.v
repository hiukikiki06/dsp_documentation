module uart_rx (
    input clk,
    input reset,
    input rx,               // Chân Rx nối tiếp đầu vào
    input tick,             // Xung từ bộ Baud Rate Gen
    output reg rx_done_tick,// Báo hiệu đã nhận xong 1 byte
    output [7:0] dout       // Dữ liệu 8-bit đầu ra song song
);

    localparam [1:0] IDLE  = 2'b00,
                     START = 2'b01,
                     DATA  = 2'b10,
                     STOP  = 2'b11;

    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;       // Đếm tick (0-15)
    reg [2:0] n_reg, n_next;       // Đếm bit nhận (0-7)
    reg [7:0] d_reg, d_next;       // Thanh ghi lưu dữ liệu đang dịch vào

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg <= 0;
            n_reg <= 0;
            d_reg <= 0;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            d_reg <= d_next;
        end
    end

    always @* begin
        state_next = state_reg;
        s_next = s_reg;
        n_next = n_reg;
        d_next = d_reg;
        rx_done_tick = 1'b0;

        case (state_reg)
            IDLE: begin
                if (~rx) begin // Phát hiện cạnh xuống (Bit Start)
                    state_next = START;
                    s_next = 0;
                end
            end

            START: begin
                if (tick) begin
                    if (s_reg == 7) begin // Lấy mẫu ở GIỮA bit Start
                        state_next = DATA;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end

            DATA: begin
                if (tick) begin
                    if (s_reg == 15) begin // Lấy mẫu ở GIỮA bit dữ liệu (cứ sau mỗi 16 ticks)
                        s_next = 0;
                        d_next = {rx, d_reg[7:1]}; // Dịch bit nhận được vào MSB
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
                if (tick) begin
                    if (s_reg == 15) begin // Đợi hết bit Stop
                        state_next = IDLE;
                        rx_done_tick = 1'b1; // Báo nhận thành công
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
        endcase
    end

    assign dout = d_reg;
endmodule