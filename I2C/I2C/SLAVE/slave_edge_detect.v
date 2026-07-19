module slave_edge_detect(
    input clk,
    input rst,
    input scl_pin,
    input sda_pin,

    output scl_posedge,
    output scl_negedge,
    output sda_posedge,
    output sda_negedge,
)