`timescale 1ns/1ps

// ==============================================================================
// Interface: uart_dut_if
// Description: Physical interface connecting SentinelSoC DUT boundary pins to UVM VIP
// ==============================================================================

interface uart_dut_if(input logic clk, input logic rst_n);

    // Boundary Signals
    logic uart_rx;  // Driven by VIP Driver -> Input to DUT
    logic uart_tx;  // Driven by DUT Output -> Sampled by VIP Monitor/Driver

    // Modport for VIP Driver (bipolar testbench driving)
    modport drv_mp (
        input  clk, rst_n, uart_tx,
        output uart_rx
    );

    // Modport for VIP Monitor (passive sampling)
    modport mon_mp (
        input clk, rst_n, uart_rx, uart_tx
    );

endinterface
