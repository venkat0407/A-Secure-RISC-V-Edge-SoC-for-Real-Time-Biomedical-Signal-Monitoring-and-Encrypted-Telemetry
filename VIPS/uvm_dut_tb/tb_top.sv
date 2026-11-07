`timescale 1ns/1ps

// ==============================================================================
// Module: tb_top
// Description: Top-Level UVM Testbench connecting SentinelSoC DUT with UVM VIP
//              - Uses uvm_config_db::set to register the physical interface
//              - Drives data from DUT interface to VIP and vice versa
//              - Dumps FSDB waveforms for Synopsys Verdi visualization
// ==============================================================================

module tb_top;

    import uvm_pkg::*;
    import uart_dut_pkg::*;

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
    // 1. Static VIP Interface Instantiation (alive all simulation time)
    // ------------------------------------------------------------------------
    uart_dut_if vif(clk, rst_n);

    // Other boundary wires
    wire [GPIO_BITS-1:0]  gpio_io;
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

        // UART Interface connected directly to UVM VIP Interface
        .uart_rx          (vif.uart_rx),  // Driven by VIP Driver -> into DUT
        .uart_tx          (vif.uart_tx),  // Driven by DUT Output -> into VIP

        // Other external boundary signals
        .gpio_io          (gpio_io),
        .adc_sample_data  (12'h800),
        .adc_sample_valid (1'b0),
        .alert_led        (alert_led),
        .wdt_reset_n      (wdt_reset_n),
        .core_irq_out     (core_irq_out)
    );

    // ------------------------------------------------------------------------
    // 3. DUT CPU Stimulus Thread: Driving Data from DUT Interface to VIP
    // ------------------------------------------------------------------------
    initial begin
        @(posedge rst_n);
        repeat (15) @(posedge clk);

        $display("\n================================================================");
        $display("[DUT CPU] Initializing SentinelSoC UART peripheral via AXI bus...");
        $display("================================================================");

        // Configure UART divisor for fast simulation baud rate (baud_div = 16)
        dut.u_cpu.cpu_write(32'h1000_0008, 32'h00000010, 4'hF);

        repeat (20) @(posedge clk);

        $display("[DUT CPU -> INTERFACE] Writing 'S' (0x53) to UART THR at 0x1000_0000...");
        dut.u_cpu.cpu_write(32'h1000_0000, 32'h00000053, 4'hF); // 'S'

        repeat (350) @(posedge clk);

        $display("[DUT CPU -> INTERFACE] Writing 'O' (0x4F) to UART THR at 0x1000_0000...");
        dut.u_cpu.cpu_write(32'h1000_0000, 32'h0000004F, 4'hF); // 'O'

        repeat (350) @(posedge clk);

        $display("[DUT CPU -> INTERFACE] Writing 'C' (0x43) to UART THR at 0x1000_0000...");
        dut.u_cpu.cpu_write(32'h1000_0000, 32'h00000043, 4'hF); // 'C'
    end

    // ------------------------------------------------------------------------
    // 4. Waveform Generation for Synopsys Verdi (FSDB) & VCD
    // ------------------------------------------------------------------------
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("sentinelsoc_uvm_dut.fsdb");
            $fsdbDumpvars(0, tb_top, "+all");
            $fsdbDumpMDA;
            $fsdbDumpSVA;
        `endif
        $dumpfile("sentinelsoc_uvm_dut.vcd");
        $dumpvars(0, tb_top);
    end

    // ------------------------------------------------------------------------
    // 5. Register Interface with uvm_config_db and Start UVM Phase
    // ------------------------------------------------------------------------
    initial begin
        // Cookbook Recipe: Register interface handle into config_db using SET
        uvm_config_db#(virtual uart_dut_if)::set(null, "*", "vif", vif);
        $display("[TB_TOP] Successfully registered virtual interface in uvm_config_db using SET!");

        // Run UVM Test
        run_test("uart_dut_test");
    end

endmodule
