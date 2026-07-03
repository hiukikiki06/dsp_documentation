module top (
    input  [3:0] A,    
    input  [3:0] B,   
    input        C_in, // bit vào đầu tiên
    output [3:0] S,    
    output       C_out // bit ra cuối cùng
);
    wire [3:0] P; // propagation
    wire [3:0] G; // generator
    wire [4:0] C;
    // KHỐI 1: Tiền xử lý (Tính toán P và G cho từng cặp bit)

    assign G = A & B;     
    assign P = A ^ B;      
    // KHỐI 2: Logic mang tải sớm (Carry-Lookahead Generator)
    // không nên dùng for để tính C do trình tổng hợp sẽ hiểu là bộ cộng RCA do phụ thuộc vào Ci
    // nếu cộng đến 32 bit thì mạch sẽ chia nhỏ tạo ra 8 bộ cla 4 bit r cộng chúng lại với nhau O(log(n))
    assign C[0] = C_in;
    
    assign C[1] = G[0] | (P[0] & C[0]);
    
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    
    assign C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & C[0]);

    assign C_out = C[4];
    // KHỐI 3: Khối tính Tổng (Post-processing)
    assign S = P ^ C[3:0]; 

endmodule