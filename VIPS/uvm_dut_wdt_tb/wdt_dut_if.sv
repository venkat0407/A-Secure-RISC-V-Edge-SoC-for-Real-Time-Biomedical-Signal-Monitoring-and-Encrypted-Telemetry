`timescale 1ns/1ps

// ==============================================================================
// Interface: wdt_dut_if
// Description: Physical interface connecting SentinelSoC DUT wdt_reset_n to UVM VIP
// ==============================================================================

interface wdt_dut_if(input logic clk, input logic rst_n);

    // Boundary Signal
    logic wdt_reset_n;  // Driven by DUT Output -> Sampled by VIP Monitor

    // Modport for VIP Monitor
    modport mon_mp (
        input clk, rst_n, wdt_reset_n
    );

endinterface
