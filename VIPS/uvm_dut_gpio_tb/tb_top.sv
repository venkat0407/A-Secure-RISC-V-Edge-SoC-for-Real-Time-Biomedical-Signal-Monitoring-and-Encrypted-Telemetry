`timescale 1ns/1ps

// ==============================================================================
// Module: tb_top (GPIO DUT + UVM VIP)
// Description: Top-Level UVM Testbench connecting SentinelSoC DUT with GPIO UVM VIP
//              - Uses uvm_config_db::set to register the physical interface
//              - Drives bidirectional data between DUT and VIP
//              - Dumps FSDB waveforms for Synopsys Verdi visualization
// ==============================================================================

module tb_top;

    import uvm_pkg::*;
    import gpio_dut_pkg::*;

    parameter CLK_PERIOD = 20; // 50 MHz (20ns)
    parameter GPIO_BITS  = 8;

    logic clk;
    logic rst_n;

    // Clock Generation
    initial clk = 0;
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Reset Generation
    initial begin
        rst_n = 0;
        #(CLK_PERIOD * 5);
        rst_n = 1;
    end

    // ------------------------------------------------------------------------
    // 1. Static VIP Interface Instantiation
    // ------------------------------------------------------------------------
    gpio_dut_if vif(clk, rst_n);

    // Other boundary wires
    wire        uart_tx;
    wire        alert_led;
    wire        wdt_reset_n;
    wire        core_irq_out;

    // ------------------------------------------------------------------------
    // 2. Instantiate SentinelSoC Device Under Test (DUT)
    // ------------------------------------------------------------------------
    sentinelsoc_top #(
        .GPIO_BITS  (GPIO_BITS),
        .DATA_WIDTH (32),
        .ADDR_WIDTH (32),
        .ID_WIDTH   (8)
    ) dut (
        .clk              (clk),
        .rst_n            (rst_n),

        // UART Interface (Tied off to idle)
        .uart_rx          (1'b1),
        .uart_tx          (uart_tx),

        // GPIO Bidirectional Bus connected directly to VIP Interface
        .gpio_io          (vif.gpio_io),

        // Other external boundary signals
        .adc_sample_data  (12'h800),
        .adc_sample_valid (1'b0),
        .alert_led        (alert_led),
        .wdt_reset_n      (wdt_reset_n),
        .core_irq_out     (core_irq_out)
    );

    // ------------------------------------------------------------------------
    // 3. DUT CPU Stimulus Thread: Interacting with GPIO via AXI Interconnect
    // ------------------------------------------------------------------------
    initial begin
        logic [31:0] rdata;
        @(posedge rst_n);
        repeat (15) @(posedge clk);

        $display("\n================================================================");
        $display("[DUT CPU] Initializing SentinelSoC GPIO peripheral via AXI bus...");
        $display("================================================================");

        // Configure DIR register at 0x1000_2008: lower 4 bits OUT (1), upper 4 bits IN (0)
        $display("[DUT CPU] Setting GPIO Direction: Lower 4 bits output, Upper 4 bits input...");
        dut.u_cpu.cpu_write(32'h1000_2008, 32'h0000000F, 4'hF);

        repeat (20) @(posedge clk);

        // Write DATA_O at 0x1000_2004: 0x0A
        $display("[DUT CPU -> INTERFACE] Writing 0x0A to GPIO DATA_O register...");
        dut.u_cpu.cpu_write(32'h1000_2004, 32'h0000000A, 4'hF);

        repeat (50) @(posedge clk);

        // Write DATA_O at 0x1000_2004: 0x05
        $display("[DUT CPU -> INTERFACE] Writing 0x05 to GPIO DATA_O register...");
        dut.u_cpu.cpu_write(32'h1000_2004, 32'h00000005, 4'hF);

        repeat (50) @(posedge clk);

        // Read DATA_I at 0x1000_2000 (reading external inputs driven by VIP)
        dut.u_cpu.cpu_read(32'h1000_2000, rdata);
        $display("[DUT CPU <- INTERFACE] Readback GPIO DATA_I = 0x%02h (External VIP + DUT output)", rdata[7:0]);
    end

    // ------------------------------------------------------------------------
    // 4. Waveform Generation for Synopsys Verdi (FSDB) & VCD
    // ------------------------------------------------------------------------
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("sentinelsoc_uvm_dut_gpio.fsdb");
            $fsdbDumpvars(0, tb_top, "+all");
            $fsdbDumpMDA;
            $fsdbDumpSVA;
        `endif
        $dumpfile("sentinelsoc_uvm_dut_gpio.vcd");
        $dumpvars(0, tb_top);
    end

    // ------------------------------------------------------------------------
    // 5. Register Interface with uvm_config_db and Start UVM Phase
    // ------------------------------------------------------------------------
    initial begin
        uvm_config_db#(virtual gpio_dut_if)::set(null, "*", "vif", vif);
        $display("[TB_TOP] Successfully registered virtual interface in uvm_config_db using SET!");
        run_test("gpio_dut_test");
    end

endmodule
