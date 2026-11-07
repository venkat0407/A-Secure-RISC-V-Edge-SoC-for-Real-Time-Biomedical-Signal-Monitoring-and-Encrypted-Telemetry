`timescale 1ns/1ps

// ==============================================================================
// Module: tb_top (Alert LED DUT + UVM VIP)
// Description: Top-Level UVM Testbench connecting SentinelSoC DUT with Alert UVM VIP
//              - Uses uvm_config_db::set to register the physical interface
//              - Verifies autonomous alert_led hardware output from QRS Engine
//              - Dumps FSDB waveforms for Synopsys Verdi visualization
// ==============================================================================

module tb_top;

    import uvm_pkg::*;
    import alert_dut_pkg::*;

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
    alert_dut_if vif(clk, rst_n);

    // Other boundary wires
    wire [GPIO_BITS-1:0]  gpio_io;
    wire                  uart_tx;
    logic [11:0]          adc_sample_data;
    logic                 adc_sample_valid;
    wire                  wdt_reset_n;
    wire                  core_irq_out;

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

        // GPIO
        .gpio_io          (gpio_io),

        // ADC Interface
        .adc_sample_data  (adc_sample_data),
        .adc_sample_valid (adc_sample_valid),

        // Alert LED connected directly to UVM VIP Interface
        .alert_led        (vif.alert_led),

        // Other external boundary signals
        .wdt_reset_n      (wdt_reset_n),
        .core_irq_out     (core_irq_out)
    );

    // ------------------------------------------------------------------------
    // 3. DUT CPU Stimulus Thread: Arming QRS & Feeding ECG Peak Pulses
    // ------------------------------------------------------------------------
    initial begin
        adc_sample_data  = 12'h800;
        adc_sample_valid = 1'b0;

        @(posedge rst_n);
        repeat (15) @(posedge clk);

        $display("\n================================================================");
        $display("[DUT CPU] Arming SentinelSoC QRS Accelerator via AXI bus...");
        $display("================================================================");

        // Arm QRS engine at 0x1000_5000 & threshold at 0x1000_5004
        dut.u_cpu.cpu_write(32'h1000_5000, 32'h00000001, 4'hF);
        dut.u_cpu.cpu_write(32'h1000_5004, 32'h00000100, 4'hF);

        repeat (20) @(posedge clk);

        $display("[STREAM] Driving high-amplitude R-peak sample pulses into ADC streaming pipeline...");
        for (int p = 0; p < 8; p++) begin
            @(posedge clk);
            adc_sample_data  = 12'hB80; // High amplitude peak
            adc_sample_valid = 1'b1;
            @(posedge clk);
            adc_sample_valid = 1'b0;
            repeat (10) @(posedge clk);
        end

        // Wait to observe alert response
        repeat (100) @(posedge clk);
        $display("[DUT INTERFACE] alert_led pin level observed = %0b", vif.alert_led);
    end

    // ------------------------------------------------------------------------
    // 4. Waveform Generation for Synopsys Verdi (FSDB) & VCD
    // ------------------------------------------------------------------------
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("sentinelsoc_uvm_dut_alert.fsdb");
            $fsdbDumpvars(0, tb_top, "+all");
            $fsdbDumpMDA;
            $fsdbDumpSVA;
        `endif
        $dumpfile("sentinelsoc_uvm_dut_alert.vcd");
        $dumpvars(0, tb_top);
    end

    // ------------------------------------------------------------------------
    // 5. Register Interface with uvm_config_db and Start UVM Phase
    // ------------------------------------------------------------------------
    initial begin
        uvm_config_db#(virtual alert_dut_if)::set(null, "*", "vif", vif);
        $display("[TB_TOP] Successfully registered virtual interface in uvm_config_db using SET!");
        run_test("alert_dut_test");
    end

endmodule
