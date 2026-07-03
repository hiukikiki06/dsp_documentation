`timescale 1ns / 1ps

module top_tb;

    // 1. Khai báo các tín hiệu kết nối với UUT (Unit Under Test)
    reg signed [5:0] a;
    reg signed [5:0] b;
    wire signed [8:0] sum;

    // 2. Gọi cấu trúc Module cần kiểm tra
    top uut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    // 3. Khối tạo kịch bản mô phỏng
    initial begin
        // Tiêu đề bảng kết quả trên màn hình Console
        $display("\n==========================================================================");
        $display("Time\t A (Q2.4)\t B (Q3.3)\t B_ex (Q4.4)\t Sum (Q5.4)");
        $display("==========================================================================");
        
        // Cấu hình monitor tự động in kết quả khi có tín hiệu thay đổi
        // Phép chia cho 16.0 (2^4) và 8.0 (2^3) giúp đổi giá trị nguyên thô ra số thực
        $monitor("%0dns\t %6.4f (%b)\t %6.4f (%b)\t %6.4f\t\t %6.4f (%b)", 
                 $time, 
                 (a / 16.0), a, 
                 (b / 8.0), b, 
                 (uut.b_ex / 16.0),   // Đọc phân tích biến nội bộ b_ex của module top
                 (sum / 16.0), sum);

        // --- Case 1: Cả hai đều là số dương thông thường ---
        // a = 0.5 (Q2.4 -> 0.5 * 16 = 8)
        // b = 1.25 (Q3.3 -> 1.25 * 8 = 10)
        a = 6'sb00_1000;    
        b = 6'sb001_010; 
        #10; // Chờ 10ns

        // --- Case 2: A dương, B âm (Kiểm tra dịch trái có giữ bit dấu âm không) ---
        // a = 1.0 (Q2.4 -> 16)
        // b = -1.5 (Q3.3 -> -1.5 * 8 = -12) -> Bù 2 là 6'b110100
        a = 6'sb01_0000;
        b = 6'sb110_100;
        #10;

        // --- Case 3: A âm, B dương ---
        // a = -0.75 (Q2.4 -> -0.75 * 16 = -12) -> Bù 2 là 6'b110100
        // b = 2.0 (Q3.3 -> 2.0 * 8 = 16) -> Bù 2 là 6'b010000
        a = 6'sb11_0100;
        b = 6'sb010_000;
        #10;

        // --- Case 4: Cả hai đều là số âm ---
        // a = -1.25 (Q2.4 -> -20)
        // b = -0.625 (Q3.3 -> -5)
        a = 6'sb11_1100; // Khoan! Thử tính lại: -20 vượt quá khoảng trị số của 6-bit có dấu (-16 đến 15)
        // Sửa lại giá trị hợp lệ cho 6-bit Q2.4: 
        a = 6'sb10_1100; // a = -1.25 (Bù 2 của -20 trong dải rộng hơn, nhưng ở 6-bit max âm là -32)
        // Để an toàn, lấy giá trị nhỏ hơn: a = -0.5 (-8) và b = -0.5 (-4)
        a = 6'sb11_1000; // -0.5
        b = 6'sb111_100; // -0.5
        #10;

        // --- Case 5: Test giá trị biên (Cực đại) để xem ngõ ra 9-bit có chống tràn tốt không ---
        // a = Max dương Q2.4 = 01.1111 (+1.9375 -> Nguyên: 31)
        // b = Max dương Q3.3 = 011.111 (+3.875 -> Nguyên: 31)
        a = 6'sb01_1111;
        b = 6'sb011_111;
        #10; 

        $display("==========================================================================");
        $finish; // Kết thúc mô phỏng
    end

endmodule