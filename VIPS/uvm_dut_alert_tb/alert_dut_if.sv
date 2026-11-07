`timescale 1ns/1ps

// ==============================================================================
// Interface: alert_dut_if
// Description: Physical interface connecting SentinelSoC DUT alert_led pin to UVM VIP
// ==============================================================================

interface alert_dut_if(input logic clk, input logic rst_n);

    // Boundary Signals
    logic alert_led;  // Driven by DUT Output -> Input to VIP Monitor

    // Modport for VIP Monitor
    modport mon_mp (
        input clk, rst_n, alert_led
    );

endinterface
