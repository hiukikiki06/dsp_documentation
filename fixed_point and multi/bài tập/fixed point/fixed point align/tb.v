`timescale 1ns / 1ps

module fixed_point_align_tb;

    // 1. Khai báo các tín hiệu kết nối với UUT (Unit Under Test)
    reg signed [5:0] a;
    reg signed [7:0] b;
    wire signed [8:0] sum;

    // 2. Gọi cấu trúc Module cần test (UUT)
    fixed_point_align uut (
        .a(a),
        .b(b),
        .sum(sum)
    );

    // 3. Khối tạo kịch bản kiểm tra (Stimulus)
    initial begin
        // Hiển thị tiêu đề trên Console để dễ theo dõi kết quả
        $display("Time\t A (Q2.4)\t B (Q4.4)\t Sum (Q5.4) [Expected]");
        $monitor("%0d\t %d (%b)\t %d (%b)\t %d (%b)", $time, a, a, b, b, sum, sum);

        // --- Case 1: Cả hai đều là số dương nhỏ ---
        a = 6'sb00_0100; // +0.25 (Dạng số nguyên trong mạch là 4)
        b = 8'sb0000_1000; // +0.50 (Dạng số nguyên trong mạch là 8)
        #10;

        // --- Case 2: A âm, B dương (Test Sign Extension của A) ---
        a = 6'sb11_1000; // -0.50 (Dạng bù 2 là -8)
        b = 8'sb0001_0000; // +1.00 (Dạng bù 2 là 16)
        #10;

        // --- Case 3: A dương, B âm (Test Sign Extension của B) ---
        a = 6'sb01_0000; // +1.00 (Dạng bù 2 là 16)
        b = 8'sb1111_0000; // -1.00 (Dạng bù 2 là -16)
        #10;

        // --- Case 4: Cả hai đều là số âm ---
        a = 6'sb10_0000; // Giá trị âm lớn nhất của Q2.4 (-2.0)
        b = 8'sb1110_0000; // -2.0
        #10;

        // --- Case 5: Test giá trị cực đại để xem có bị tràn (Overflow) không ---
        a = 6'sb01_1111; // Max dương của A (+1.9375)
        b = 8'sb0111_1111; // Max dương của B (+7.9375)
        #10; // Kết quả sum phải là 9'sb010011110 (+9.875) an toàn, không bão hòa

        // Kết thúc mô phỏng
        $finish;
    end

endmodule