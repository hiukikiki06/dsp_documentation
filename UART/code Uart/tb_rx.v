`timescale 1ns / 1ps

module uart_rx_tb;

    reg clk;
    reg reset;
    reg rx;
    reg tick;
    wire rx_done_tick;
    wire [7:0] dout;

    uart_rx dut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tick(tick), 
        .rx_done_tick(rx_done_tick),
        .dout(dout)
    );

    // 1. Tạo xung clock chính (cứ 10ns đổi trạng thái một lần)
    always #10 clk = ~clk;

    // 2. Tạo xung tick (cứ 20ns đổi trạng thái một lần)
    always #20 tick = ~tick;

    // 3. Quá trình test: Gửi byte 8'b01000011 (số 0x43)
    // Lưu ý: Gửi bit Start trước (0), rồi đến các bit dữ liệu từ phải qua trái, cuối cùng là bit Stop (1)
    initial begin
        // Khởi tạo ban đầu
        clk = 0;
        tick = 0;
        reset = 1;
        rx = 1;         // UART mặc định ở mức cao (Idle)
        #50;            
        
        reset = 0;      // Nhả reset
        #50;

        // --- BẮT ĐẦU GỬI BYTE 0x43 (8'b01000011) ---
        
        rx = 0;         // Bit START
        #640;           // Chờ hết 1 bit thời gian (16 ticks)

        rx = 1;         // Bit 0 của data
        #640;
        
        rx = 1;         // Bit 1 của data
        #640;
        
        rx = 0;         // Bit 2 của data
        #640;
        
        rx = 0;         // Bit 3 của data
        #640;
        
        rx = 0;         // Bit 4 của data
        #640;
        
        rx = 0;         // Bit 5 của data
        #640;
        
        rx = 1;         // Bit 6 của data
        #640;
        
        rx = 0;         // Bit 7 của data
        #640;

        rx = 1;         // Bit STOP
        #640;

        // --- KẾT THÚC ---
        #200;
        $finish;        // Dừng mô phỏng
    end

endmodule