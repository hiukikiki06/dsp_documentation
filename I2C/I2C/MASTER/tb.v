`timescale 1ns/1ps

module i2c_master_tb;

    // 1. Khai báo tín hiệu kết nối
    reg        clk;
    reg        rst;
    reg        start;
    reg        read_en;
    reg  [6:0] slave_addr;
    reg  [7:0] re_addr;
    reg  [7:0] data_in;

    wire [7:0] data_out;
    wire       ready;
    wire       ack_error;
    wire       i2c_scl;
    wire       i2c_sda;

    // Tín hiệu giả lập Slave kéo SDA xuống 0 để trả ACK
    reg        slave_ack_drive;
    assign i2c_sda = slave_ack_drive ? 1'b0 : 1'bz;

    // 2. Khởi tạo UUT (Unit Under Test)
    i2c_master uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .read_en(read_en),
        .slave_addr(slave_addr),
        .re_addr(re_addr),
        .data_in(data_in),
        .data_out(data_out),
        .ready(ready),
        .ack_error(ack_error),
        .i2c_scl(i2c_scl),
        .i2c_sda(i2c_sda)
    );

    // 3. Tạo xung clock 50MHz (T = 20ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // 4. Mạch giả lập Slave trả ACK ở mỗi nhịp thứ 9
    initial begin
        slave_ack_drive = 0;
        forever begin
            // Mỗi khi SCL xuống thấp ở nhịp chuẩn bị ACK, Slave kéo SDA = 0
            @(negedge i2c_scl);
            if (uut.current_state == uut.ACK_SLAVE_WR || 
                uut.current_state == uut.ACK_REG      || 
                uut.current_state == uut.ACK_DATA     || 
                uut.current_state == uut.ACK_SLAVE_RD) begin
                
                slave_ack_drive = 1; // Kéo SDA xuống 0 (Trả ACK)
                @(negedge i2c_scl);
                slave_ack_drive = 0; // Thả nổi lại SDA
            end
        end
    end

    // 5. Kịch bản chạy mô phỏng
    initial begin
        // Khởi tạo các giá trị
        rst        = 1;
        start      = 0;
        read_en    = 0;       // Chế độ Ghi (Write)
        slave_addr = 7'h3C;   // Địa chỉ Slave: 0x3C
        re_addr    = 8'h1F;   // Địa chỉ Thanh ghi: 0x1F
        data_in    = 8'hA5;   // Dữ liệu ghi: 0xA5

        // Nhấn Reset trong 100ns
        #100;
        rst = 0;
        #100;

        // --- TESTCASE 1: Thực hiện chu trình GHI (WRITE) ---
        $display("[TB] Bat dau truyen goi I2C WRITE...");
        start = 1;
        #40;
        start = 0;

        // Chờ Master chạy xong và quay về trạng thái rảnh (ready = 1)
        wait(ready == 1);
        #200;
        $display("[TB] Hoan thanh truyen GHI!");

        // --- TESTCASE 2: Thực hiện chu trình ĐỌC (READ) ---
        #500;
        $display("[TB] Bat dau truyen goi I2C READ...");
        read_en = 1; // Bật chế độ Đọc
        start   = 1;
        #40;
        start   = 0;

        // Chờ Master đọc xong
        wait(ready == 1);
        #200;
        $display("[TB] Hoan thanh truyen DOC! Data nhan duoc: 0x%0h", data_out);

        #500;
        $finish; // Kết thúc mô phỏng
    end

endmodule