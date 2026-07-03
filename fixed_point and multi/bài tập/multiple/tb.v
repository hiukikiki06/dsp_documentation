`timescale 1ns/1ps

module tb;
    reg clk;
    reg rst;
    reg [7:0] A, B;
    reg enable;
    wire [15:0] product;
    wire done;

    // Gọi module cần kiểm tra (UUT)
    top uut(
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .enable(enable),
        .product(product),
        .done(done)
    );

    // Sửa lỗi khởi tạo Clock: Gán clk = 0 ban đầu
    initial clk = 0;
    always begin
        #5 clk = ~clk; // Tạo xung clock chu kỳ 10ns
    end

    // Khối nạp dữ liệu test
    initial begin // Đã sửa thành "initial"
        enable = 0;
        rst = 1;
        A = 0;
        B = 0;
        #15;
        rst = 0;   // Nhả reset
        
        // --- Phép tính 1: 15 x 24 = 360 ---
        #10; 
        A = 8'd15;
        B = 8'd24; // Đã sửa thành 8'd24;
        enable = 1;
        #10; 
        enable = 0; // Hạ enable sau 1 chu kỳ clock
        
        @(posedge done);
        // Đã sửa chuỗi hiển thị bổ sung thêm %d cho product
        $display("Ket qua: %d x %d = %d", A, B, product);
        
        // --- Phép tính 2: 0 x 10 = 0 ---
        #20; 
        A = 8'd00; 
        B = 8'd10; 
        enable = 1;
        #10; 
        enable = 0;
        
        @(posedge done); // Đã thêm dấu ;
        $display("Ket qua: %d x %d = %d", A, B, product);
        
        #20; 
        $finish;
    end
endmodule