`timescale 1ns/1ps

// ==============================================================================
// Interface: gpio_dut_if
// Description: Physical interface connecting SentinelSoC DUT GPIO pins to UVM VIP
// ==============================================================================

interface gpio_dut_if(input logic clk, input logic rst_n);

    // Physical Bidirectional GPIO bus
    wire [7:0] gpio_io;

    // Driver control lines
    logic [7:0] drv_data;
    logic [7:0] drv_en;

    // Tristate drive to the wire
    assign gpio_io[0] = drv_en[0] ? drv_data[0] : 1'bz;
    assign gpio_io[1] = drv_en[1] ? drv_data[1] : 1'bz;
    assign gpio_io[2] = drv_en[2] ? drv_data[2] : 1'bz;
    assign gpio_io[3] = drv_en[3] ? drv_data[3] : 1'bz;
    assign gpio_io[4] = drv_en[4] ? drv_data[4] : 1'bz;
    assign gpio_io[5] = drv_en[5] ? drv_data[5] : 1'bz;
    assign gpio_io[6] = drv_en[6] ? drv_data[6] : 1'bz;
    assign gpio_io[7] = drv_en[7] ? drv_data[7] : 1'bz;

    // Modport for VIP Driver
    modport drv_mp (
        input  clk, rst_n,
        inout  gpio_io,
        output drv_data, drv_en
    );

    // Modport for VIP Monitor
    modport mon_mp (
        input clk, rst_n, gpio_io
    );

endinterface
