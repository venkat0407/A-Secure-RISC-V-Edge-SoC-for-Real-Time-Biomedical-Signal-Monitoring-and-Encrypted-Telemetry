`timescale 1ns/1ps

// ==============================================================================
// Module: tb_top (WDT DUT + UVM VIP)
// Description: Top-Level UVM Testbench connecting SentinelSoC DUT with WDT UVM VIP
//              - Uses uvm_config_db::set to register the physical interface
//              - Verifies failsafe Watchdog timer countdown and reset assertion
//              - Dumps FSDB waveforms for Synopsys Verdi visualization
// ==============================================================================

module tb_top;

    import uvm_pkg::*;
    import wdt_dut_pkg::*;

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
    wdt_dut_if vif(clk, rst_n);

    // Other boundary wires
    wire [GPIO_BITS-1:0]  gpio_io;
    wire                  uart_tx;
    wire                  alert_led;
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

        // ADC
        .adc_sample_data  (12'h800),
        .adc_sample_valid (1'b0),

        // Alert LED
        .alert_led        (alert_led),

        // WDT Reset connected directly to VIP Interface
        .wdt_reset_n      (vif.wdt_reset_n),

        // Diagnostic IRQ
        .core_irq_out     (core_irq_out)
    );

    // ------------------------------------------------------------------------
    // 3. DUT CPU Stimulus Thread: WDT Configuration, Feed, and Expiration
    // ------------------------------------------------------------------------
    initial begin
        logic [31:0] rdata;
        @(posedge rst_n);
        repeat (15) @(posedge clk);

        $display("\n================================================================");
        $display("[DUT CPU] Initializing SentinelSoC Watchdog Timer via AXI bus...");
        $display("================================================================");

        // Configure reload count = 64 cycles at 0x1000_7004
        $display("[DUT CPU] Setting WDT reload = 64 cycles...");
        dut.u_cpu.cpu_write(32'h1000_7004, 32'h00000040, 4'hF);

        repeat (5) @(posedge clk);

        // Enable WDT + reset output enable at 0x1000_7000
        $display("[DUT CPU] Enabling Watchdog and arming reset generation...");
        dut.u_cpu.cpu_write(32'h1000_7000, 32'h00000007, 4'hF);

        repeat (20) @(posedge clk);

        // Feed Watchdog with magic key 0xA55AFEED at 0x1000_700C
        $display("[DUT CPU] Feeding watchdog with magic key 0xA55AFEED...");
        dut.u_cpu.cpu_write(32'h1000_700C, 32'hA55AFEED, 4'hF);

        repeat (10) @(posedge clk);
        dut.u_cpu.cpu_read(32'h1000_7008, rdata);
        $display("[DUT CPU] Current WDT countdown register = 0x%08h", rdata);

        // Allow WDT to count down past 0 without feeding to trigger hardware reset
        $display("[DUT CPU] Ceasing feeds to allow countdown to expire...");
        repeat (80) @(posedge clk);

        $display("[DUT INTERFACE] wdt_reset_n observed = %0b", vif.wdt_reset_n);
    end

    // ------------------------------------------------------------------------
    // 4. Waveform Generation for Synopsys Verdi (FSDB) & VCD
    // ------------------------------------------------------------------------
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("sentinelsoc_uvm_dut_wdt.fsdb");
            $fsdbDumpvars(0, tb_top, "+all");
            $fsdbDumpMDA;
            $fsdbDumpSVA;
        `endif
        $dumpfile("sentinelsoc_uvm_dut_wdt.vcd");
        $dumpvars(0, tb_top);
    end

    // ------------------------------------------------------------------------
    // 5. Register Interface with uvm_config_db and Start UVM Phase
    // ------------------------------------------------------------------------
    initial begin
        uvm_config_db#(virtual wdt_dut_if)::set(null, "*", "vif", vif);
        $display("[TB_TOP] Successfully registered virtual interface in uvm_config_db using SET!");
        run_test("wdt_dut_test");
    end

endmodule
