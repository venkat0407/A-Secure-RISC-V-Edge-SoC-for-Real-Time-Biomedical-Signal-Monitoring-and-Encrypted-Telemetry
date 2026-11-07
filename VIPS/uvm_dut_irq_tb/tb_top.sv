`timescale 1ns/1ps

// ==============================================================================
// Module: tb_top (IRQ DUT + UVM VIP)
// Description: Top-Level UVM Testbench connecting SentinelSoC DUT with IRQ UVM VIP
//              - Uses uvm_config_db::set to register the physical interface
//              - Verifies interrupt generation, aggregation, and W1C clear cycle
//              - Dumps FSDB waveforms for Synopsys Verdi visualization
// ==============================================================================

module tb_top;

    import uvm_pkg::*;
    import irq_dut_pkg::*;

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
    irq_dut_if vif(clk, rst_n);

    // Other boundary wires
    wire [GPIO_BITS-1:0]  gpio_io;
    wire                  uart_tx;
    wire                  alert_led;
    wire                  wdt_reset_n;

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

        // Alert LED & WDT
        .alert_led        (alert_led),
        .wdt_reset_n      (wdt_reset_n),

        // Core IRQ connected directly to VIP Interface
        .core_irq_out     (vif.core_irq_out)
    );

    // ------------------------------------------------------------------------
    // 3. DUT CPU Stimulus Thread: Unmasking IRQs, Triggering Timer, Clearing W1C
    // ------------------------------------------------------------------------
    initial begin
        logic [31:0] rdata;
        @(posedge rst_n);
        repeat (15) @(posedge clk);

        $display("\n================================================================");
        $display("[DUT CPU] Initializing SentinelSoC Interrupt Aggregator via AXI...");
        $display("================================================================");

        // Unmask all 7 interrupt sources at 0x1000_8004
        $display("[DUT CPU] Unmasking all 7 interrupt sources...");
        dut.u_cpu.cpu_write(32'h1000_8004, 32'h0000007F, 4'hF);

        repeat (5) @(posedge clk);

        // Configure hardware timer to generate compare interrupt
        $display("[DUT CPU] Configuring Timer compare value = 48...");
        dut.u_cpu.cpu_write(32'h1000_1000, 32'h00000000, 4'hF); // stop
        dut.u_cpu.cpu_write(32'h1000_1008, 32'h00000030, 4'hF); // compare = 48
        dut.u_cpu.cpu_write(32'h1000_1000, 32'h00000001, 4'hF); // start

        // Wait for timer to count up and fire interrupt
        repeat (60) @(posedge clk);

        // Read cause register at 0x1000_8000
        dut.u_cpu.cpu_read(32'h1000_8000, rdata);
        $display("[DUT CPU] Interrupt CAUSE register read = 0x%02h", rdata[6:0]);

        // Write W1C to clear Timer IRQ (bit 1)
        $display("[DUT CPU] Clearing Timer IRQ via W1C write...");
        dut.u_cpu.cpu_write(32'h1000_8000, 32'h00000002, 4'hF);
        dut.u_cpu.cpu_write(32'h1000_1010, 32'h00000001, 4'hF); // Clear timer status

        repeat (20) @(posedge clk);
        $display("[DUT INTERFACE] core_irq_out observed = %0b", vif.core_irq_out);
    end

    // ------------------------------------------------------------------------
    // 4. Waveform Generation for Synopsys Verdi (FSDB) & VCD
    // ------------------------------------------------------------------------
    initial begin
        `ifdef FSDB
            $fsdbDumpfile("sentinelsoc_uvm_dut_irq.fsdb");
            $fsdbDumpvars(0, tb_top, "+all");
            $fsdbDumpMDA;
            $fsdbDumpSVA;
        `endif
        $dumpfile("sentinelsoc_uvm_dut_irq.vcd");
        $dumpvars(0, tb_top);
    end

    // ------------------------------------------------------------------------
    // 5. Register Interface with uvm_config_db and Start UVM Phase
    // ------------------------------------------------------------------------
    initial begin
        uvm_config_db#(virtual irq_dut_if)::set(null, "*", "vif", vif);
        $display("[TB_TOP] Successfully registered virtual interface in uvm_config_db using SET!");
        run_test("irq_dut_test");
    end

endmodule
