`timescale 1ns/1ps

// ==============================================================================
// Module: tb_top (Unified Boundary DUT + UVM VIP)
// Description: Top-Level UVM Testbench connecting SentinelSoC DUT with Unified VIP
//              - Covers all 8 boundary signals simultaneously
//              - Uses uvm_config_db::set to register the physical interface
//              - Dumps FSDB waveforms for Synopsys Verdi visualization
// ==============================================================================

module tb_top;

    import uvm_pkg::*;
    import boundary_dut_pkg::*;

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
    boundary_dut_if vif(clk, rst_n);

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

        // UART Interface
        .uart_rx          (vif.uart_rx),
        .uart_tx          (vif.uart_tx),

        // GPIO Bidirectional Bus
        .gpio_io          (vif.gpio_io),

        // ADC Streaming Interface
        .adc_sample_data  (vif.adc_sample_data),
        .adc_sample_valid (vif.adc_sample_valid),

        // Safety & Diagnostic Lines
        .alert_led        (vif.alert_led),
        .wdt_reset_n      (vif.wdt_reset_n),
        .core_irq_out     (vif.core_irq_out)
    );

    // ------------------------------------------------------------------------
    // 3. DUT CPU Stimulus Thread: Multi-Peripheral Activity
    // ------------------------------------------------------------------------
    initial begin
        logic [31:0] rdata;
        @(posedge rst_n);
        repeat (15) @(posedge clk);

        $display("\n================================================================");
        $display("[DUT CPU] Initializing SentinelSoC Boundary Peripherals via AXI...");
        $display("================================================================");

        // 1. Configure UART divisor
        dut.u_cpu.cpu_write(32'h1000_0008, 32'h00000010, 4'hF);

        // 2. Configure GPIO DIR: lower 4 out, upper 4 in
        dut.u_cpu.cpu_write(32'h1000_2008, 32'h0000000F, 4'hF);

        // 3. Enable ADC
        dut.u_cpu.cpu_write(32'h1000_300C, 32'h0000000A, 4'hF);
        dut.u_cpu.cpu_write(32'h1000_3000, 32'h00000001, 4'hF);

        repeat (20) @(posedge clk);

        // Write UART character 'B' (0x42)
        $display("[DUT CPU] Transmitting 'B' over UART...");
        dut.u_cpu.cpu_write(32'h1000_0000, 32'h00000042, 4'hF);

        // Write GPIO DATA_O = 0x09
        $display("[DUT CPU] Driving GPIO DATA_O = 0x09...");
        dut.u_cpu.cpu_write(32'h1000_2004, 32'h00000009, 4'hF);

        repeat (50) @(posedge clk);

        // Readback GPIO
        dut.u_cpu.cpu_read(32'h1000_2000, rdata);
        $display("[DUT CPU] Readback GPIO DATA_I = 0x%02h", rdata[7:0]);
    end

    // ------------------------------------------------------------------------
    // 4. Waveform Generation for Synopsys Verdi (FSDB) & VCD
    // ------------------------------------------------------------------------
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("sentinelsoc_uvm_dut_boundary.fsdb");
            $fsdbDumpvars(0, tb_top, "+all");
            $fsdbDumpMDA;
            $fsdbDumpSVA;
        `endif
        $dumpfile("sentinelsoc_uvm_dut_boundary.vcd");
        $dumpvars(0, tb_top);
    end

    // ------------------------------------------------------------------------
    // 5. Register Interface with uvm_config_db and Start UVM Phase
    // ------------------------------------------------------------------------
    initial begin
        uvm_config_db#(virtual boundary_dut_if)::set(null, "*", "vif", vif);
        $display("[TB_TOP] Successfully registered virtual interface in uvm_config_db using SET!");
        run_test("boundary_dut_test");
    end

endmodule
