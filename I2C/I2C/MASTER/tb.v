`timescale 1ns / 1ps

module tb_i2c_master_simple();

    // 1. Khai báo các tín hiệu kết nối với DUT
    reg clk;
    reg rst;
    reg start;
    reg read_en;
    reg [6:0] slave_addr;
    reg [7:0] re_addr;
    reg [7:0] data_in;
    
    wire [7:0] data_out;
    wire ready;
    wire ack_error;
    wire i2c_scl;
    wire i2c_sda;

    // Tín hiệu dùng để giả lập Slave phản hồi lên chân inout sda
    reg sda_slave_reg;
    reg sda_slave_en;
    assign i2c_sda = (sda_slave_en) ? sda_slave_reg : 1'bz;

    // 2. Gọi DUT
    i2c_master dut (
        .clk(clk), .rst(rst), .start(start), .read_en(read_en),
        .slave_addr(slave_addr), .re_addr(re_addr), .data_in(data_in),
        .data_out(data_out), .ready(ready), .ack_error(ack_error),
        .i2c_scl(i2c_scl), .i2c_sda(i2c_sda)
    );

    // 3. Tạo xung nhịp hệ thống (50MHz)
    always #10 clk = ~clk;

    // 4. Kịch bản chạy mô phỏng tuyến tính đơn giản
    initial begin
        // Khởi tạo trạng thái ban đầu
        clk          = 0;
        rst          = 1;
        start        = 0;
        read_en      = 0;
        slave_addr   = 7'h50; 
        re_addr      = 8'h2A; 
        data_in      = 8'h3C; 
        sda_slave_en = 0;
        sda_slave_reg= 1;

        // Giải phóng Reset
        #100;
        rst = 0;
        #40;

        // ==========================================
        // KHỐI GHI (WRITE TIẾN TRÌNH)
        // ==========================================
        $display("--- KICH BAN 1: GHI DU LIEU ---");
        @(posedge clk);
        start = 1;      // Kích hoạt Start
        @(posedge clk);
        start = 0;

        // --- Giả lập Slave trả ACK lần 1 (Sau khi Master gửi xong Slave Addr) ---
        // Đợi trạng thái ACK_SLAVE_WR (Master nhả dây SDA cho Slave điều khiển)
        wait(dut.current_state == 4'd3); 
        @(posedge i2c_scl); // Đợi lúc SCL lên cao để Slave giữ mức 0 an toàn
        sda_slave_en  = 1;
        sda_slave_reg = 0; // Trả về ACK (mức 0)
        
        @(negedge i2c_scl); // Hết chu kỳ ACK, nhả dây SDA ra
        sda_slave_en  = 0;

        // --- Giả lập Slave trả ACK lần 2 (Sau khi Master gửi xong Register Addr) ---
        wait(dut.current_state == 4'd5); // Trạng thái ACK_REG
        @(posedge i2c_scl);
        sda_slave_en  = 1;
        sda_slave_reg = 0; // Trả về ACK
        
        @(negedge i2c_scl);
        sda_slave_en  = 0;

        // --- Giả lập Slave trả ACK lần 3 (Sau khi Master ghi xong Data) ---
        wait(dut.current_state == 4'd7); // Trạng thái ACK_DATA
        @(posedge i2c_scl);
        sda_slave_en  = 1;
        sda_slave_reg = 0; // Trả về ACK
        
        @(negedge i2c_scl);
        sda_slave_en  = 0;

        // Chờ Master kết thúc chu trình Ghi và quay về IDLE
        wait(ready == 1);
        $display("-> Ghi thanh cong! ack_error = %b", ack_error);
        #200;

        // ==========================================
        // KHỐI ĐỌC (READ TIẾN TRÌNH)
        // ==========================================
        $display("\n--- KICH BAN 2: DOC DU LIEU ---");
        @(posedge clk);
        read_en = 1;    // Bật chế độ đọc
        start   = 1;
        @(posedge clk);
        start   = 0;

        // --- Trả ACK lần 1 (Slave Addr trước khi đổi nhánh) ---
        wait(dut.current_state == 4'd3); // ACK_SLAVE_WR
        @(posedge i2c_scl); sda_slave_en = 1; sda_slave_reg = 0;
        @(negedge i2c_scl); sda_slave_en = 0;

        // --- Trả ACK lần 2 (Register Addr) ---
        wait(dut.current_state == 4'd5); // ACK_REG
        @(posedge i2c_scl); sda_slave_en = 1; sda_slave_reg = 0;
        @(negedge i2c_scl); sda_slave_en = 0;

        // --- Trả ACK lần 3 (Slave Addr sau khi Repeated Start) ---
        wait(dut.current_state == 4'd10); // ACK_SLAVE_RD
        @(posedge i2c_scl); sda_slave_en = 1; sda_slave_reg = 0;
        @(negedge i2c_scl); sda_slave_en = 0;

        // --- Giả lập Slave truyền Data mẫu về cho Master đọc (Ví dụ số: 8'h96 tức là 10010110) ---
        wait(dut.current_state == 4'd11); // Trạng thái READ_DATA
        sda_slave_en = 1;
        
        // Đẩy tuần tự từng bit mỗi khi SCL xuống thấp (Master chuẩn bị đọc khi SCL lên cao)
        sda_slave_reg = 1; @(negedge i2c_scl); // bit 7
        sda_slave_reg = 0; @(negedge i2c_scl); // bit 6
        sda_slave_reg = 0; @(negedge i2c_scl); // bit 5
        sda_slave_reg = 1; @(negedge i2c_scl); // bit 4
        sda_slave_reg = 0; @(negedge i2c_scl); // bit 3
        sda_slave_reg = 1; @(negedge i2c_scl); // bit 2
        sda_slave_reg = 1; @(negedge i2c_scl); // bit 1
        sda_slave_reg = 0; @(negedge i2c_scl); // bit 0

        // Hết 8 bit dữ liệu, nhả SDA để Master phát NACK
        sda_slave_en = 0;

        // Chờ Master kết thúc hoàn toàn chu trình đọc
        wait(ready == 1);
        $display("-> Doc thanh cong!");
        $display("-> Du lieu Master doc duoc tai data_out: 8'h%h (Ky vong: 8'h96)", data_out);

        #200;
        $finish;
    end

endmodule