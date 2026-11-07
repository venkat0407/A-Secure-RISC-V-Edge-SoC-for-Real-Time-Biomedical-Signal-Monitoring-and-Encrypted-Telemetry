`timescale 1ns/1ps

// ==============================================================================
// Interface: adc_dut_if
// Description: Physical interface connecting SentinelSoC DUT ADC pins to UVM VIP
// ==============================================================================

interface adc_dut_if(input logic clk, input logic rst_n);

    // Boundary Signals
    logic [11:0] adc_sample_data;   // Driven by VIP Driver -> Input to DUT
    logic        adc_sample_valid;  // Driven by VIP Driver -> Input strobe to DUT

    // Modport for VIP Driver
    modport drv_mp (
        input  clk, rst_n,
        output adc_sample_data, adc_sample_valid
    );

    // Modport for VIP Monitor
    modport mon_mp (
        input clk, rst_n, adc_sample_data, adc_sample_valid
    );

endinterface
