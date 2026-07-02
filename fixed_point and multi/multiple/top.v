module top(
    input clk,
    input rst,
    input [7:0] A,B, // a la so bi nhan b la so nhan
    input enable, // tin hieu cho phep nhan
    output reg [15:0] product,
    output reg done // da dem xong
);
    reg [7:0] tmp_A, tmp_B;
    reg busy;
    reg [3:0] cnt; // đếm xem đã nhân đủ chưa
    always @( posedge clk ) begin
        if ( rst )  begin
            busy <= 0;
            product <= 0;
            done <= 0;
            cnt <= 0;
        end
        else begin
            if ( enable && !busy ) begin
                busy <= 1;
                done <= 0;
                tmp_A <= A;
                tmp_B <= B;
                product <= 16'd0;
                cnt <= 4'd0;
            end
            else if ( busy ) begin
                if ( cnt < 4'd8 ) begin
                    if ( tmp_B[0] ) begin
                        product <= product + (tmp_A << cnt);
                        // vì do product có 16 bit nên sẽ tự mở rộng bit product <= product + ({8'b0, tmp_A} << cnt);
                    end
                    tmp_B <= tmp_B >> 1;
                    cnt <= cnt + 1;
                end
                else begin
                    busy <= 0;
                    done <= 1;
                end
            end
        end            
    end
endmodule