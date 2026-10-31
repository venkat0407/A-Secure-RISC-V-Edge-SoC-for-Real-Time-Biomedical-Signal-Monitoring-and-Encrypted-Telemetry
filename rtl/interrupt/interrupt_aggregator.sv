// ============================================================================
// File: interrupt_aggregator.sv
// Project: SentinelSoC
// Description: Peripheral Interrupt Aggregator with CAUSE and MASK Registers
// Base Address: 0x1000_8000
// ============================================================================

`timescale 1ns/1ps

module interrupt_aggregator #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 12,
    parameter NUM_IRQS   = 7
)(
    input  logic                    aclk,
    input  logic                    aresetn,

    // AXI4-Lite Slave Interface
    input  logic [ADDR_WIDTH-1:0]   s_axi_awaddr,
    input  logic                    s_axi_awvalid,
    output logic                    s_axi_awready,

    input  logic [DATA_WIDTH-1:0]   s_axi_wdata,
    input  logic [(DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  logic                    s_axi_wvalid,
    output logic                    s_axi_wready,

    output logic [1:0]              s_axi_bresp,
    output logic                    s_axi_bvalid,
    input  logic                    s_axi_bready,

    input  logic [ADDR_WIDTH-1:0]   s_axi_araddr,
    input  logic                    s_axi_arvalid,
    output logic                    s_axi_arready,

    output logic [DATA_WIDTH-1:0]   s_axi_rdata,
    output logic [1:0]              s_axi_rresp,
    output logic                    s_axi_rvalid,
    input  logic                    s_axi_rready,

    // Raw interrupt lines from IPs
    input  logic [NUM_IRQS-1:0]     raw_irqs,
    // [0] = uart_irq
    // [1] = timer_irq
    // [2] = gpio_irq
    // [3] = adc_fir_irq
    // [4] = qrs_peak_irq
    // [5] = aes_done_irq
    // [6] = wdt_irq

    // Aggregated core interrupt line
    output logic                    core_irq
);

    localparam [ADDR_WIDTH-1:0] REG_CAUSE = 12'h000;
    localparam [ADDR_WIDTH-1:0] REG_MASK  = 12'h004;

    logic [NUM_IRQS-1:0] cause_reg;
    logic [NUM_IRQS-1:0] mask_reg;

    logic [NUM_IRQS-1:0] prev_raw_irqs;
    logic [NUM_IRQS-1:0] raw_edges;

    // Edge detect to latch interrupts into CAUSE
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            prev_raw_irqs <= '0;
        end else begin
            prev_raw_irqs <= raw_irqs;
        end
    end
    assign raw_edges = raw_irqs & ~prev_raw_irqs;

    logic aw_en;
    logic [ADDR_WIDTH-1:0] axi_awaddr;
    logic [ADDR_WIDTH-1:0] axi_araddr;

    assign s_axi_bresp = 2'b00;
    assign s_axi_rresp = 2'b00;

    // AXI Write Address & Data
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_awready <= 1'b0;
            s_axi_wready  <= 1'b0;
            s_axi_bvalid  <= 1'b0;
            aw_en         <= 1'b1;
            axi_awaddr    <= '0;
            cause_reg     <= '0;
            mask_reg      <= {NUM_IRQS{1'b1}}; // Unmask all by default
        end else begin
            // Latch pending interrupts (OR with edge detects)
            cause_reg <= cause_reg | raw_edges | raw_irqs;

            // AW handshake
            if (~s_axi_awready && s_axi_awvalid && s_axi_wvalid && aw_en) begin
                s_axi_awready <= 1'b1;
                s_axi_wready  <= 1'b1;
                axi_awaddr    <= s_axi_awaddr;
                aw_en         <= 1'b0;
            end else begin
                s_axi_awready <= 1'b0;
                s_axi_wready  <= 1'b0;
            end

            // Register write
            if (s_axi_awready && s_axi_awvalid && s_axi_wready && s_axi_wvalid) begin
                case (axi_awaddr[11:0])
                    REG_CAUSE: begin
                        // W1C
                        cause_reg <= (cause_reg | raw_edges) & ~s_axi_wdata[NUM_IRQS-1:0];
                    end
                    REG_MASK: begin
                        mask_reg <= s_axi_wdata[NUM_IRQS-1:0];
                    end
                    default: ;
                endcase
            end

            // BVALID handshake
            if (s_axi_awready && s_axi_wready && ~s_axi_bvalid) begin
                s_axi_bvalid <= 1'b1;
            end else if (s_axi_bready && s_axi_bvalid) begin
                s_axi_bvalid <= 1'b0;
                aw_en        <= 1'b1;
            end
        end
    end

    // AXI Read Address & Data
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_arready <= 1'b0;
            s_axi_rvalid  <= 1'b0;
            s_axi_rdata   <= '0;
            axi_araddr    <= '0;
        end else begin
            if (~s_axi_arready && s_axi_arvalid) begin
                s_axi_arready <= 1'b1;
                axi_araddr    <= s_axi_araddr;
            end else begin
                s_axi_arready <= 1'b0;
            end

            if (s_axi_arready && s_axi_arvalid && ~s_axi_rvalid) begin
                s_axi_rvalid <= 1'b1;
                case (axi_araddr[11:0])
                    REG_CAUSE: s_axi_rdata <= {{(32-NUM_IRQS){1'b0}}, cause_reg};
                    REG_MASK:  s_axi_rdata <= {{(32-NUM_IRQS){1'b0}}, mask_reg};
                    default:   s_axi_rdata <= 32'h0;
                endcase
            end else if (s_axi_rready && s_axi_rvalid) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

    // Aggregated Interrupt
    assign core_irq = |(cause_reg & mask_reg);

endmodule
