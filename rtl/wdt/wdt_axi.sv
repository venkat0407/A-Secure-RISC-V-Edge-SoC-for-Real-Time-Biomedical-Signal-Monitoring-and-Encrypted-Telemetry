// ============================================================================
// File: wdt_axi.sv
// Project: SentinelSoC
// Description: Memory-mapped Watchdog Timer with AXI4-Lite Slave Interface,
//              Pre-timeout Interrupt, and System Reset Generation.
// Base Address: 0x1000_7000
// ============================================================================

`timescale 1ns/1ps

module wdt_axi #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 12
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

    // Hardware signals
    output logic                    wdt_irq,
    output logic                    wdt_reset_n
);

    // Register Offsets
    localparam [ADDR_WIDTH-1:0] REG_CTRL   = 12'h000;
    localparam [ADDR_WIDTH-1:0] REG_RELOAD = 12'h004;
    localparam [ADDR_WIDTH-1:0] REG_COUNT  = 12'h008;
    localparam [ADDR_WIDTH-1:0] REG_FEED   = 12'h00C;
    localparam [ADDR_WIDTH-1:0] REG_STATUS = 12'h010;

    // Registers
    logic [31:0] ctrl_reg;     // [0]=EN, [1]=IE, [2]=RESET_EN
    logic [31:0] reload_reg;   // Timeout reload value
    logic [31:0] count_reg;    // Live down-counter
    logic [31:0] status_reg;   // [0]=PRE_TIMEOUT, [1]=RESET_TRIGGERED

    logic reset_pulse_n;

    // AXI Handshakes
    logic aw_en;
    logic [ADDR_WIDTH-1:0] axi_awaddr;
    logic [ADDR_WIDTH-1:0] axi_araddr;

    assign s_axi_bresp = 2'b00; // OKAY
    assign s_axi_rresp = 2'b00; // OKAY

    // AXI Write Address & Data
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            s_axi_awready <= 1'b0;
            s_axi_wready  <= 1'b0;
            s_axi_bvalid  <= 1'b0;
            aw_en         <= 1'b1;
            axi_awaddr    <= '0;
            ctrl_reg      <= 32'h0;
            reload_reg    <= 32'h0000_FFFF;
            status_reg    <= 32'h0;
        end else begin
            // AWREADY handshake
            if (~s_axi_awready && s_axi_awvalid && s_axi_wvalid && aw_en) begin
                s_axi_awready <= 1'b1;
                s_axi_wready  <= 1'b1;
                axi_awaddr    <= s_axi_awaddr;
                aw_en         <= 1'b0;
            end else begin
                s_axi_awready <= 1'b0;
                s_axi_wready  <= 1'b0;
            end

            // Write register handling
            if (s_axi_awready && s_axi_awvalid && s_axi_wready && s_axi_wvalid) begin
                case (axi_awaddr[11:0])
                    REG_CTRL: begin
                        ctrl_reg <= s_axi_wdata;
                    end
                    REG_RELOAD: begin
                        reload_reg <= s_axi_wdata;
                    end
                    REG_FEED: begin
                        // Feed reloads counter - handled below
                    end
                    REG_STATUS: begin
                        // W1C for status bits
                        status_reg[0] <= status_reg[0] & ~s_axi_wdata[0];
                        status_reg[1] <= status_reg[1] & ~s_axi_wdata[1];
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

            // Counter status updates
            if (ctrl_reg[0]) begin
                // Pre-timeout: count reached 25% of reload
                if (count_reg == (reload_reg >> 2)) begin
                    status_reg[0] <= 1'b1;
                end
                // Timeout: count reached 0
                if (count_reg == 32'd0) begin
                    status_reg[1] <= 1'b1;
                end
            end
        end
    end

    // Watchdog Down-counter & Feed logic
    logic feed_strobe;
    assign feed_strobe = s_axi_awready && s_axi_awvalid && s_axi_wready && s_axi_wvalid && (axi_awaddr[11:0] == REG_FEED);

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            count_reg     <= 32'h0000_FFFF;
            reset_pulse_n <= 1'b1;
        end else begin
            if (feed_strobe || !ctrl_reg[0]) begin
                count_reg     <= reload_reg;
                reset_pulse_n <= 1'b1;
            end else if (ctrl_reg[0]) begin
                if (count_reg > 32'd0) begin
                    count_reg     <= count_reg - 1'b1;
                    reset_pulse_n <= 1'b1;
                end else begin
                    // Timeout hit
                    if (ctrl_reg[2]) begin // RESET_EN
                        reset_pulse_n <= 1'b0;
                    end
                    count_reg <= reload_reg; // Auto restart
                end
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
                    REG_CTRL:   s_axi_rdata <= ctrl_reg;
                    REG_RELOAD: s_axi_rdata <= reload_reg;
                    REG_COUNT:  s_axi_rdata <= count_reg;
                    REG_STATUS: s_axi_rdata <= status_reg;
                    default:    s_axi_rdata <= 32'h0;
                endcase
            end else if (s_axi_rready && s_axi_rvalid) begin
                s_axi_rvalid <= 1'b0;
            end
        end
    end

    // Interrupt and Reset outputs
    assign wdt_irq     = status_reg[0] & ctrl_reg[1];
    assign wdt_reset_n = reset_pulse_n;

endmodule
