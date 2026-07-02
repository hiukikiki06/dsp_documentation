// module top_boost(
//     input clk,
//     input rst,
//     input start,
//     input signed [3:0] a,
//     input signed [3:0] b,
//     output wire signed [7:0] product,
//     output reg done
// );
//     reg signed [3:0] tmp_a, tmp_a2;
//     reg signed [8:0] tmp; // Khai báo tmp có dấu luôn để khi dịch >>> không lo bị lỗi
//     reg busy;
//     reg [2:0] cnt; 
//     always @(posedge clk) begin
//         if (rst) begin
//             busy <= 0;
//             cnt  <= 0;
//             done <= 0;
//             tmp  <= 0;
//         end
//         else begin
//             if (start && !busy) begin
//                 tmp_a  <= a;
//                 tmp_a2 <= ~a + 1'b1; // Lấy bù 2 của a (-a)
//                 busy   <= 1;
//                 done   <= 0;
//                 cnt    <= 0;
//                 tmp    <= {4'b0, b, 1'b0}; 
//             end
//             else if (busy) begin
//                 if (cnt < 4) begin
//                     // Sửa cú pháp case và đổi 2'b11 thành 2'b10 cho đúng luật Booth
//                     // Đồng thời thực hiện Cộng/Trừ và Dịch phải số học (>>>) cùng lúc
//                     case ({tmp[1], tmp[0]})
//                         // Bọc $signed() ra ngoài toàn bộ chuỗi ngoặc nhọn trước khi dịch >>> 1
//                         2'b01:   tmp <= $signed({tmp[8:5] + tmp_a,  tmp[4:0]}) >>> 1; 
//                         2'b10:   tmp <= $signed({tmp[8:5] + tmp_a2, tmp[4:0]}) >>> 1;
//                         default: tmp <= tmp >>> 1; // Dòng này đúng vì tmp độc lập đã có thuộc tính signed
//                     endcase
                    
//                     cnt <= cnt + 1'b1;
//                 end
//                 else begin
//                     busy <= 0;
//                     done <= 1;
//                 end
//             end
//         end
//     end

//     // Kết quả lấy từ bit 8 đến bit 1 (bỏ bit B_-1 ở vị trí 0)
//     assign product = tmp[8:1]; 
// endmodule


module top_boost(
    input clk,
    input rst,
    input start,
    input signed [3:0] a,
    input signed [3:0] b,
    output wire signed [7:0] product,
    output reg done
);
    reg signed [3:0] tmp_a;
    reg signed [8:0] tmp; // [8:5]: Tích lũy (Accumulator), [4:1]: Số nhân B, [0]: Bit phụ B_-1
    reg busy;
    reg [2:0] cnt; 

    // Khai báo một biến tạm thời có dấu để chứa kết quả sau phép Cộng/Trừ (Trước khi dịch)
    reg signed [4:0] sum; 

    always @(posedge clk) begin
        if (rst) begin
            busy  <= 1'b0;
            cnt   <= 3'd0;
            done  <= 1'b0;
            tmp   <= 9'd0;
            tmp_a <= 4'd0;
        end
        else begin
            if (start && !busy) begin
                tmp_a <= a;
                busy  <= 1'b1;
                done  <= 1'b0;
                cnt   <= 3'd0;
                tmp   <= {4'b0, b, 1'b0}; // Khởi tạo: [0000][ b ][0]
            end
            else if (busy) begin
                if (cnt < 3'd4) begin
                    
                    // BƯỚC 1: Thực hiện phép toán Cộng / Trừ / Giữ nguyên dựa trên 2 bit cuối
                    case ({tmp[1], tmp[0]})
                        // Gặp 01: Cộng A vào nửa đầu. Cần ép kiểu lên 5 bit để không mất bit dấu khi cộng
                        2'b01:   sum = $signed(tmp[8:5]) + $signed(tmp_a);
                        
                        // Gặp 10: Trừ A khỏi nửa đầu (Tương đương cộng với số bù 2 của A)
                        2'b10:   sum = $signed(tmp[8:5]) - $signed(tmp_a);
                        
                        // Gặp 00 hoặc 11: Giữ nguyên nửa đầu
                        default: sum = $signed(tmp[8:5]); 
                    endcase

                    // BƯỚC 2: Thực hiện gán kết quả đã tính và DỊCH PHẢI SỐ HỌC (>>> 1) chuẩn chỉ
                    // Do sum (5-bit) ghép với tmp[4:1] (4-bit) tạo thành một chuỗi 9-bit có thuộc tính signed hoàn chỉnh.
                    // Khi dịch >>> 1, bit dấu cao nhất của sum sẽ tự động được nhân bản bảo toàn cấu trúc!
                    tmp <= $signed({sum, tmp[4:0]}) >>> 1;
                    
                    cnt <= cnt + 1'b1;
                end
                else begin
                    busy <= 1'b0;
                    done <= 1'b1;
                end
            end
        end
    end

    // Kết quả lấy từ bit 8 đến bit 1 (bỏ bit phụ B_-1 ở vị trí 0)
    assign product = tmp[8:1]; 

endmodule
