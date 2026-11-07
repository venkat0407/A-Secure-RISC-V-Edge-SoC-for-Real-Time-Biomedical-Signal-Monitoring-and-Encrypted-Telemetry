`timescale 1ns/1ps

// ==============================================================================
// Interface: boundary_dut_if
// Description: Unified Physical Boundary Interface for SentinelSoC DUT & UVM VIP
// ==============================================================================

interface boundary_dut_if(input logic clk, input logic rst_n);

    // 1. UART Boundary Signals
    logic        uart_rx;
    logic        uart_tx;

    // 2. GPIO Bidirectional Bus
    wire [7:0]   gpio_io;
    logic [7:0]  gpio_drv_data;
    logic [7:0]  gpio_drv_en;

    assign gpio_io[0] = gpio_drv_en[0] ? gpio_drv_data[0] : 1'bz;
    assign gpio_io[1] = gpio_drv_en[1] ? gpio_drv_data[1] : 1'bz;
    assign gpio_io[2] = gpio_drv_en[2] ? gpio_drv_data[2] : 1'bz;
    assign gpio_io[3] = gpio_drv_en[3] ? gpio_drv_data[3] : 1'bz;
    assign gpio_io[4] = gpio_drv_en[4] ? gpio_drv_data[4] : 1'bz;
    assign gpio_io[5] = gpio_drv_en[5] ? gpio_drv_data[5] : 1'bz;
    assign gpio_io[6] = gpio_drv_en[6] ? gpio_drv_data[6] : 1'bz;
    assign gpio_io[7] = gpio_drv_en[7] ? gpio_drv_data[7] : 1'bz;

    // 3. ADC Streaming Interface
    logic [11:0] adc_sample_data;
    logic        adc_sample_valid;

    // 4. Safety & Diagnostic Outputs
    logic        alert_led;
    logic        wdt_reset_n;
    logic        core_irq_out;

    // Modport for VIP Driver
    modport drv_mp (
        input  clk, rst_n, uart_tx, alert_led, wdt_reset_n, core_irq_out,
        inout  gpio_io,
        output uart_rx, gpio_drv_data, gpio_drv_en, adc_sample_data, adc_sample_valid
    );

    // Modport for VIP Monitor
    modport mon_mp (
        input clk, rst_n, uart_rx, uart_tx, gpio_io, adc_sample_data, adc_sample_valid,
              alert_led, wdt_reset_n, core_irq_out
    );

endinterface
