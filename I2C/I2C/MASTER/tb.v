`timescale 1ns/1ps

module i2c_master_tb;

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

    // Tín hiệu giả lập từ Testbench đóng vai Slave kéo SDA xuống 0 để trả ACK
    reg        slave_ack_drive;
    assign i2c_sda = slave_ack_drive ? 1'b0 : 1'bz;

    // Điện trở kéo lên (Pull-up) mặc định cho bus I2C trong môi trường mô phỏng
    pullup(i2c_sda);
    pullup(i2c_scl);

    // 2. Khởi tạo module I2C Master cần test
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

    // 3. Tạo xung Clock hệ thống 50MHz (T = 20ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    // 4. GIẢ LẬP SLAVE: Bắt đúng các trạng thái ACK_... để kéo SDA = 0
    initial begin
        slave_ack_drive = 0;
        forever begin
            @(negedge i2c_scl);
            // Khi Master chuyển sang các trạng thái chờ ACK từ Slave
            if (uut.current_state == uut.ACK_SLAVE_WR || 
                uut.current_state == uut.ACK_REG      || 
                uut.current_state == uut.ACK_DATA     || 
                uut.current_state == uut.ACK_SLAVE_RD) begin
                
                slave_ack_drive = 1; // Slave trả ACK (mức 0)
                @(negedge i2c_scl);
                slave_ack_drive = 0; // Thả nổi lại bus SDA
            end
        end
    end

    // 5. KỊCH BẢN MÔ PHỎNG CHÍNH (STIMULUS)
    initial begin
        // --- BƯỚC 1: Khởi tạo giá trị ban đầu ---
        rst        = 1;
        start      = 0;
        read_en    = 0;       // Mặc định chế độ Ghi
        slave_addr = 7'h3C;   // Địa chỉ Slave: 0x3C
        re_addr    = 8'h1F;   // Địa chỉ Thanh ghi: 0x1F
        data_in    = 8'hA5;   // Dữ liệu cần ghi: 0xA5

        // Nhấn Reset trong 100ns
        #100;
        rst = 0;
        #200; // Chờ hệ thống ổn định

        // --- TESTCASE 1: Thực hiện chu trình GHI (WRITE OPERATION) ---
        $display("\n[TB LOG] === BAT DAU CHU TRINH I2C WRITE ===");
        read_en = 0;
        start   = 1;

        // GIẢI PHÁP SỬA LỖI: Đợi FSM bắt đầu bận (ready rớt xuống 0) rồi mới hạ start
        @(negedge ready);
        start   = 0;

        // Đợi Master hoàn tất truyền byte và quay về IDLE (ready lên 1 lại)
        wait(ready == 1);
        #5000; // Chờ 5us quan sát
        $display("[TB LOG] === HOAN THANH CHU TRINH I2C WRITE! ===");


        // --- TESTCASE 2: Thực hiện chu trình ĐỌC (READ OPERATION) ---
        $display("\n[TB LOG] === BAT DAU CHU TRINH I2C READ ===");
        read_en = 1; // Chuyển sang chế độ Đọc
        start   = 1;

        // Đợi FSM bắt đầu bận rồi nhả start
        @(negedge ready);
        start   = 0;

        // Đợi Master hoàn tất đọc byte về
        wait(ready == 1);
        #5000;
        $display("[TB LOG] === HOAN THANH CHU TRINH I2C READ! ===");
        $display("[TB LOG] Data nhan duoc tu Slave (data_out) = 0x%0h", data_out);

        #10000;
        $finish; // Kết thúc mô phỏng
    end

endmodule