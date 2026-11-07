`timescale 1ns/1ps

// ==============================================================================
// Interface: irq_dut_if
// Description: Physical interface connecting SentinelSoC DUT core_irq_out to UVM VIP
// ==============================================================================

interface irq_dut_if(input logic clk, input logic rst_n);

    // Boundary Signal
    logic core_irq_out;  // Driven by DUT Output -> Sampled by VIP Monitor

    // Modport for VIP Monitor
    modport mon_mp (
        input clk, rst_n, core_irq_out
    );

endinterface
