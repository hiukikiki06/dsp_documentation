module uart_top (
    input clk,
    input reset,
    // Các chân nối tiếp ra ngoài
    input rx,
    output tx,
    // Giao tiếp với logic bên trong FPGA
    input tx_start,
    input [7:0] tx_data,
    output tx_done,
    output rx_done,
    output [7:0] rx_data
);

    wire tick;

    // Gọi bộ sinh Baud Rate
    baud_rate_generator baud_gen (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    // Gọi bộ nhận Rx
    uart_rx receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tick(tick),
        .rx_done_tick(rx_done),
        .dout(rx_data)
    );

    // Gọi bộ truyền Tx
    uart_tx transmitter (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tick(tick),
        .din(tx_data),
        .tx_done_tick(tx_done),
        .tx(tx)
    );

endmodule