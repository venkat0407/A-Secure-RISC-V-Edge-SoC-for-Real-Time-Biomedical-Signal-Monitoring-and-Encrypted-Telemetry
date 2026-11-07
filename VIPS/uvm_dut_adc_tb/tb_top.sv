`timescale 1ns/1ps

// ==============================================================================
// Module: tb_top (ADC DUT + UVM VIP)
// Description: Top-Level UVM Testbench connecting SentinelSoC DUT with ADC UVM VIP
//              - Uses uvm_config_db::set to register the physical interface
//              - Drives digitized ECG stream from VIP into SentinelSoC DUT
//              - Dumps FSDB waveforms for Synopsys Verdi visualization
// ==============================================================================

module tb_top;

    import uvm_pkg::*;
    import adc_dut_pkg::*;

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
    adc_dut_if vif(clk, rst_n);

    // Other boundary wires
    wire [GPIO_BITS-1:0]  gpio_io;
    wire                  uart_tx;
    wire                  alert_led;
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

        // ADC Interface connected directly to UVM VIP Interface
        .adc_sample_data  (vif.adc_sample_data),   // Driven by VIP Driver -> into DUT
        .adc_sample_valid (vif.adc_sample_valid),  // Driven by VIP Driver -> into DUT

        // Other external boundary signals
        .alert_led        (alert_led),
        .wdt_reset_n      (wdt_reset_n),
        .core_irq_out     (core_irq_out)
    );

    // ------------------------------------------------------------------------
    // 3. DUT CPU Stimulus Thread: Initializing ADC via AXI Interconnect
    // ------------------------------------------------------------------------
    initial begin
        logic [31:0] rdata;
        @(posedge rst_n);
        repeat (15) @(posedge clk);

        $display("\n================================================================");
        $display("[DUT CPU] Initializing SentinelSoC ADC controller via AXI bus...");
        $display("================================================================");

        // Configure ADC sample divider at 0x1000_300C
        dut.u_cpu.cpu_write(32'h1000_300C, 32'h0000000A, 4'hF);

        repeat (10) @(posedge clk);

        // Enable ADC at 0x1000_3000
        $display("[DUT CPU] Enabling ADC controller...");
        dut.u_cpu.cpu_write(32'h1000_3000, 32'h00000001, 4'hF);

        repeat (80) @(posedge clk);

        // Read ADC status register at 0x1000_3004
        dut.u_cpu.cpu_read(32'h1000_3004, rdata);
        $display("[DUT CPU <- INTERFACE] ADC Status = 0x%08h", rdata);

        // Read ADC captured sample data register at 0x1000_3008
        dut.u_cpu.cpu_read(32'h1000_3008, rdata);
        $display("[DUT CPU <- INTERFACE] Readback Captured ADC Data = 0x%03h", rdata[11:0]);
    end

    // ------------------------------------------------------------------------
    // 4. Waveform Generation for Synopsys Verdi (FSDB) & VCD
    // ------------------------------------------------------------------------
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("sentinelsoc_uvm_dut_adc.fsdb");
            $fsdbDumpvars(0, tb_top, "+all");
            $fsdbDumpMDA;
            $fsdbDumpSVA;
        `endif
        $dumpfile("sentinelsoc_uvm_dut_adc.vcd");
        $dumpvars(0, tb_top);
    end

    // ------------------------------------------------------------------------
    // 5. Register Interface with uvm_config_db and Start UVM Phase
    // ------------------------------------------------------------------------
    initial begin
        uvm_config_db#(virtual adc_dut_if)::set(null, "*", "vif", vif);
        $display("[TB_TOP] Successfully registered virtual interface in uvm_config_db using SET!");
        run_test("adc_dut_test");
    end

endmodule
