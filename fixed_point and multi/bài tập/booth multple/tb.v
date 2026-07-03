`timescale 1ns/1ps

module tb_boost;
    // 1. Khai báo các tín hiệu kết nối với Module cần test (UUT)
    reg clk;
    reg rst;
    reg start;
    reg signed [3:0] a;
    reg signed [3:0] b;
    wire signed [7:0] product;
    wire done;

    // 2. Gọi module bộ nhân Booth (UUT - Unit Under Test)
    top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a(a),
        .b(b),
        .product(product),
        .done(done)
    );

    // 3. Tạo xung Clock chu kỳ 10ns (Tần số 100MHz)
    initial clk = 0;
    always begin
        #5 clk = ~clk;
    end

    // 4. Kịch bản mô phỏng (Stimulus)
    initial begin
        // Khởi tạo trạng thái ban đầu của các ngõ vào
        rst = 1;
        start = 0;
        a = 0;
        b = 0;
        #20;
        
        rst = 0; // Nhả reset
        #10;

        // --- Kiểm tra trường hợp 1: Dương x Dương (3 x 5 = 15) ---
        a = 4'sd3;  // Khai báo kiểu số thập phân có dấu (signed decimal)
        b = 4'sd5;
        start = 1;  // Kích hoạt tín hiệu bắt đầu nhân
        #10;
        start = 0;  // Hạ start xuống sau 1 chu kỳ clock để mạch tự chạy
        
        @(posedge done); // Chờ cho đến khi mạch tính xong (done nhảy lên 1)
        $display("Test 1 [Duong x Duong]: %d x %d = %d", a, b, product);
        if (product == 8'sd15) $display("-> CHINH XAC!\n"); else $display("-> SAI!\n");
        #30;

        // --- Kiểm tra trường hợp 2: Am x Duong (-3 x 7 = -21) ---
        a = -4'sd3; 
        b = 4'sd7;
        start = 1;
        #10;
        start = 0;
        
        @(posedge done);
        $display("Test 2 [Am x Duong]: %d x %d = %d", a, b, product);
        if (product == -8'sd21) $display("-> CHINH XAC!\n"); else $display("-> SAI!\n");
        #30;

        // --- Kiểm tra trường hợp 3: Am x Am (-4 x -3 = 12) ---
        a = -4'sd4; 
        b = -4'sd3;
        start = 1;
        #10;
        start = 0;
        
        @(posedge done);
        $display("Test 3 [Am x Am]: %d x %d = %d", a, b, product);
        if (product == 8'sd12) $display("-> CHINH XAC!\n"); else $display("-> SAI!\n");

        #40;
        $finish; // Kết thúc mô phỏng
    end

endmodule