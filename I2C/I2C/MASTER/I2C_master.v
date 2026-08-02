module i2c_master(
    input clk,
    input rst,
    input start,
    input read_en,
    input [6:0] slave_addr,
    input [7:0] re_addr,
    input [7:0] data_in,

    output reg [7:0] data_out,
    output reg ready, // 1: rảnh, 0: bận
    output reg ack_error,
    output reg i2c_scl,
    inout  i2c_sda
  );
  // Module chia tần
  wire scl_clk;
  baud_gen u1(
             .clk(clk),
             .rst(rst),
             .scl_clk(scl_clk)
           );

  // Module tri_state
  reg sda_out;
  wire sda_in;
  reg sda_en;
  tri_state u2(
              .en(sda_en),
              .din(sda_out),
              .dout(sda_in),
              .pad(i2c_sda)
            );

  // Máy trạng thái (14 trạng thái)
  localparam IDLE         = 4'd0;
  localparam START        = 4'd1;
  localparam SLAVE_WR     = 4'd2;
  localparam ACK_SLAVE_WR = 4'd3;
  localparam REG_ADDR     = 4'd4;
  localparam ACK_REG      = 4'd5;
  localparam WRITE_DATA   = 4'd6;
  localparam ACK_DATA     = 4'd7;
  localparam REP_START    = 4'd8;
  localparam SLAVE_RD     = 4'd9;
  localparam ACK_SLAVE_RD = 4'd10;
  localparam READ_DATA    = 4'd11;
  localparam NACK_MASTER  = 4'd12;
  localparam STOP         = 4'd13;

  reg [3:0] current_state, next_state;
  reg [3:0] bit_cnt;
  reg [7:0] shift_reg;

  // KHỐI 1: Cập nhật trạng thái
  always @(posedge scl_clk or posedge rst)
  begin
    if (rst)
      current_state <= IDLE;
    else
      current_state <= next_state;
  end

  // KHỐI 2: Mạch tạo trạng thái kế tiếp (Combinational FSM)
  always @(*)
  begin
    next_state = current_state;
    case (current_state)
      IDLE:
      begin
        if (start)
          next_state = START;
      end
      START:
      begin
        next_state = SLAVE_WR;
      end
      SLAVE_WR:
      begin
        if (bit_cnt == 0 && i2c_scl == 0)
          next_state = ACK_SLAVE_WR;
      end
      ACK_SLAVE_WR:
      begin
        if (i2c_scl == 0)
          next_state = REG_ADDR;
      end
      REG_ADDR:
      begin
        if (bit_cnt == 0 && i2c_scl == 0)
          next_state = ACK_REG;
      end
      ACK_REG:
      begin
        if (i2c_scl == 0)
        begin
          if (read_en)
            next_state = REP_START;
          else
            next_state = WRITE_DATA;
        end
      end
      WRITE_DATA:
      begin
        if (bit_cnt == 0 && i2c_scl == 0)
          next_state = ACK_DATA;
      end
      ACK_DATA:
      begin
        if (i2c_scl == 0)
          next_state = STOP;
      end
      REP_START:
      begin
        if (i2c_scl == 1 && sda_out == 0)
          next_state = SLAVE_RD;
      end
      SLAVE_RD:
      begin
        if (bit_cnt == 0 && i2c_scl == 0)
          next_state = ACK_SLAVE_RD;
      end
      ACK_SLAVE_RD:
      begin
        if (i2c_scl == 0)
          next_state = READ_DATA;
      end
      READ_DATA:
      begin
        if (bit_cnt == 0 && i2c_scl == 0)
          next_state = NACK_MASTER;
      end
      NACK_MASTER:
      begin
        if (i2c_scl == 0)
          next_state = STOP;
      end
      STOP:
      begin
        if (i2c_scl == 1 && sda_out == 1)
          next_state = IDLE;
      end
      default:
        next_state = IDLE;
    endcase
  end

  // KHỐI 3: Điều khiển ngõ ra & Thanh ghi (Sequential Logic)
  always @(posedge scl_clk or posedge rst)
  begin
    if (rst)
    begin
      bit_cnt   <= 7;
      sda_out   <= 1;
      sda_en    <= 1;
      i2c_scl   <= 1;
      ack_error <= 0;
      data_out  <= 0;
      ready     <= 1;
      shift_reg <= 0;
    end
    else
    begin
      case (current_state)
        IDLE:
        begin
          ready       <= 1;
          i2c_scl     <= 1;
          sda_out     <= 1;
          sda_en      <= 1;
          bit_cnt     <= 7;
          ack_error   <= 0;
        end

        START:
        begin
          ready     <= 0;
          sda_out   <= 0;
          sda_en    <= 1;
          i2c_scl   <= 1;
          shift_reg <= {slave_addr, 1'b0};
          bit_cnt   <= 7;
        end

        SLAVE_WR:
        begin
          i2c_scl <= ~i2c_scl;
          if (i2c_scl == 0)
          begin
            sda_en    <= 1;
            sda_out   <= shift_reg[7];
            shift_reg <= shift_reg << 1;
            if (bit_cnt == 0)
              bit_cnt <= 7;
            else
              bit_cnt <= bit_cnt - 1;
          end
        end

        ACK_SLAVE_WR:
        begin
          i2c_scl <= ~i2c_scl;
          if (i2c_scl == 0)
          begin
            sda_en <= 0;
          end
          else
          begin
            ack_error <= sda_in;
            shift_reg <= re_addr;
          end
        end

        REG_ADDR:
        begin
          i2c_scl <= ~i2c_scl;
          if (i2c_scl == 0)
          begin
            sda_en    <= 1;
            sda_out   <= shift_reg[7];
            shift_reg <= shift_reg << 1;
            if (bit_cnt == 0)
              bit_cnt <= 7;
            else
              bit_cnt <= bit_cnt - 1;
          end
        end

        ACK_REG:
        begin
          i2c_scl <= ~i2c_scl;
          if (i2c_scl == 0)
          begin
            sda_en <= 0;
          end
          else
          begin
            ack_error <= sda_in;
            shift_reg <= data_in;
          end
        end

        WRITE_DATA:
        begin
          i2c_scl <= ~i2c_scl;
          if (i2c_scl == 0)
          begin
            sda_en    <= 1;
            sda_out   <= shift_reg[7];
            shift_reg <= shift_reg << 1;
            if (bit_cnt == 0)
              bit_cnt <= 7;
            else
              bit_cnt <= bit_cnt - 1;
          end
        end

        ACK_DATA:
        begin
          i2c_scl <= ~i2c_scl;
          if (i2c_scl == 0)
          begin
            sda_en <= 0;
          end
          else
          begin
            ack_error <= sda_in;
          end
        end

        REP_START:
        begin
          if (i2c_scl == 0)
          begin
            sda_en  <= 1;
            sda_out <= 1;
            i2c_scl <= 1;
          end
          else
          begin
            sda_out   <= 0; // SCL=1, kéo SDA xuống 0 -> REPEAT START
            bit_cnt   <= 7;
            shift_reg <= {slave_addr, 1'b1};
          end
        end

        SLAVE_RD:
        begin
          i2c_scl <= ~i2c_scl;
          if (i2c_scl == 0)
          begin
            sda_en    <= 1;
            sda_out   <= shift_reg[7];
            shift_reg <= shift_reg << 1;
            if (bit_cnt == 0)
              bit_cnt <= 7;
            else
              bit_cnt <= bit_cnt - 1;
          end
        end

        ACK_SLAVE_RD:
        begin
          i2c_scl <= ~i2c_scl;
          if (i2c_scl == 0)
          begin
            sda_en <= 0;
          end
          else
          begin
            ack_error <= sda_in;
          end
        end

        READ_DATA:
        begin
          i2c_scl <= ~i2c_scl;
          if (i2c_scl == 0)
          begin
            sda_en <= 0;
          end
          else
          begin
            shift_reg <= {shift_reg[6:0], sda_in};
            if (bit_cnt == 0)
              bit_cnt <= 7;
            else
              bit_cnt <= bit_cnt - 1;
          end
        end

        NACK_MASTER:
        begin
          i2c_scl  <= ~i2c_scl;
          data_out <= shift_reg;
          if (i2c_scl == 0)
          begin
            sda_en  <= 1;
            sda_out <= 1; // Master gửi NACK (1) kết thúc
          end
        end

        STOP:
        begin
          i2c_scl <= 1;
          if (i2c_scl == 1)
          begin
            sda_en  <= 1;
            sda_out <= 1;
          end
        end
      endcase
    end
  end
endmodule
