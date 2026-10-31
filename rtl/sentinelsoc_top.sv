// ============================================================================
// File: sentinelsoc_top.sv
// Project: SentinelSoC
// Description: Top-Level System-on-Chip Integration for SentinelSoC
//
// Features:
//   - RISC-V RV32 Core / Bus Master Subsystem
//   - Shared AXI4 Interconnect (3-master x 11-slave crossbar)
//   - On-chip 64 KB IMEM (0x0000_0000) & 64 KB DMEM (0x0001_0000)
//   - 9 Authoritative Peripherals:
//       M00: UART Controller             (0x1000_0000 - 0x1000_0FFF)
//       M01: Timer / Counter Subsystem   (0x1000_1000 - 0x1000_1FFF)
//       M02: GPIO Subsystem              (0x1000_2000 - 0x1000_2FFF)
//       M03: 12-bit SAR ADC Controller   (0x1000_3000 - 0x1000_3FFF)
//       M04: 16-tap FIR Filter Engine    (0x1000_4000 - 0x1000_4FFF)
//       M05: Pan-Tompkins QRS Engine     (0x1000_5000 - 0x1000_5FFF)
//       M06: AES-128 Encryption Engine   (0x1000_6000 - 0x1000_6FFF)
//       M07: Watchdog Timer (WDT)        (0x1000_7000 - 0x1000_7FFF)
//       M08: Interrupt Aggregator        (0x1000_8000 - 0x1000_8FFF)
//       M09: Instruction Memory (IMEM)   (0x0000_0000 - 0x0000_FFFF)
//       M10: Data Memory (DMEM)          (0x0001_0000 - 0x0001_FFFF)
//   - Biomedical Stream: ADC -> FIR -> QRS -> alert_led
//   - Telemetry Encryption & Watchdog Protection
// ============================================================================

`timescale 1ns/1ps

module sentinelsoc_top #(
    parameter GPIO_BITS  = 8,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter ID_WIDTH   = 8
)(
    input  logic                    clk,
    input  logic                    rst_n,

    // UART External Pins
    input  logic                    uart_rx,
    output logic                    uart_tx,

    // GPIO External Pins
    inout  wire  [GPIO_BITS-1:0]    gpio_io,

    // ADC External Interface
    input  logic [11:0]             adc_sample_data,
    input  logic                    adc_sample_valid,

    // Hardware Alert & Safety Pins
    output logic                    alert_led,
    output logic                    wdt_reset_n,

    // Diagnostic / Verification Interrupt Out
    output logic                    core_irq_out
);

    wire rst = ~rst_n;
    wire aresetn = rst_n;

    // ------------------------------------------------------------------------
    // Master Port S00 (LSU / CPU Bus Functional Master)
    // ------------------------------------------------------------------------
    wire [ID_WIDTH-1:0]    s00_axi_awid;
    wire [ADDR_WIDTH-1:0]  s00_axi_awaddr;
    wire [7:0]             s00_axi_awlen;
    wire [2:0]             s00_axi_awsize;
    wire [1:0]             s00_axi_awburst;
    wire                   s00_axi_awlock;
    wire [3:0]             s00_axi_awcache;
    wire [2:0]             s00_axi_awprot;
    wire [3:0]             s00_axi_awqos;
    wire [3:0]             s00_axi_awregion;
    wire                   s00_axi_awvalid;
    wire                   s00_axi_awready;

    wire [DATA_WIDTH-1:0]  s00_axi_wdata;
    wire [(DATA_WIDTH/8)-1:0] s00_axi_wstrb;
    wire                   s00_axi_wlast;
    wire                   s00_axi_wvalid;
    wire                   s00_axi_wready;

    wire [ID_WIDTH-1:0]    s00_axi_bid;
    wire [1:0]             s00_axi_bresp;
    wire                   s00_axi_bvalid;
    wire                   s00_axi_bready;

    wire [ID_WIDTH-1:0]    s00_axi_arid;
    wire [ADDR_WIDTH-1:0]  s00_axi_araddr;
    wire [7:0]             s00_axi_arlen;
    wire [2:0]             s00_axi_arsize;
    wire [1:0]             s00_axi_arburst;
    wire                   s00_axi_arlock;
    wire [3:0]             s00_axi_arcache;
    wire [2:0]             s00_axi_arprot;
    wire [3:0]             s00_axi_arqos;
    wire [3:0]             s00_axi_arregion;
    wire                   s00_axi_arvalid;
    wire                   s00_axi_arready;

    wire [ID_WIDTH-1:0]    s00_axi_rid;
    wire [DATA_WIDTH-1:0]  s00_axi_rdata;
    wire [1:0]             s00_axi_rresp;
    wire                   s00_axi_rlast;
    wire                   s00_axi_rvalid;
    wire                   s00_axi_rready;

    // Instantiate CPU Core / Bus Master wrapper
    el2_veer_wrapper #(
        .ID_WIDTH   (ID_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) u_cpu (
        .clk              (clk),
        .rst_l            (aresetn),
        .dbg_rst_l        (aresetn),
        .rst_vec          (31'h0000_0000),
        .nmi_int          (1'b0),
        .nmi_vec          (31'h0000_0000),
        .jtag_id          (31'h0),

        .lsu_axi_awvalid  (s00_axi_awvalid),
        .lsu_axi_awready  (s00_axi_awready),
        .lsu_axi_awid     (s00_axi_awid),
        .lsu_axi_awaddr   (s00_axi_awaddr),
        .lsu_axi_awlen    (s00_axi_awlen),
        .lsu_axi_awsize   (s00_axi_awsize),
        .lsu_axi_awburst  (s00_axi_awburst),
        .lsu_axi_awlock   (s00_axi_awlock),
        .lsu_axi_awcache  (s00_axi_awcache),
        .lsu_axi_awprot   (s00_axi_awprot),

        .lsu_axi_wvalid   (s00_axi_wvalid),
        .lsu_axi_wready   (s00_axi_wready),
        .lsu_axi_wdata    (s00_axi_wdata),
        .lsu_axi_wstrb    (s00_axi_wstrb),
        .lsu_axi_wlast    (s00_axi_wlast),

        .lsu_axi_bvalid   (s00_axi_bvalid),
        .lsu_axi_bready   (s00_axi_bready),
        .lsu_axi_bresp    (s00_axi_bresp),
        .lsu_axi_bid      (s00_axi_bid),

        .lsu_axi_arvalid  (s00_axi_arvalid),
        .lsu_axi_arready  (s00_axi_arready),
        .lsu_axi_arid     (s00_axi_arid),
        .lsu_axi_araddr   (s00_axi_araddr),
        .lsu_axi_arlen    (s00_axi_arlen),
        .lsu_axi_arsize   (s00_axi_arsize),
        .lsu_axi_arburst  (s00_axi_arburst),
        .lsu_axi_arlock   (s00_axi_arlock),
        .lsu_axi_arcache  (s00_axi_arcache),
        .lsu_axi_arprot   (s00_axi_arprot),

        .lsu_axi_rvalid   (s00_axi_rvalid),
        .lsu_axi_rready   (s00_axi_rready),
        .lsu_axi_rid      (s00_axi_rid),
        .lsu_axi_rdata    (s00_axi_rdata),
        .lsu_axi_rresp    (s00_axi_rresp),
        .lsu_axi_rlast    (s00_axi_rlast),

        .ifu_axi_awready  (1'b0),
        .ifu_axi_wready   (1'b0),
        .ifu_axi_bvalid   (1'b0),
        .ifu_axi_arready  (1'b0),
        .ifu_axi_rvalid   (1'b0),

        .sb_axi_awready   (1'b0),
        .sb_axi_wready    (1'b0),
        .sb_axi_bvalid    (1'b0),
        .sb_axi_arready   (1'b0),
        .sb_axi_rvalid    (1'b0),

        .dma_axi_awvalid  (1'b0),
        .dma_axi_wvalid   (1'b0),
        .dma_axi_arvalid  (1'b0),
        .dma_axi_bready   (1'b0),
        .dma_axi_rready   (1'b0),

        .lsu_bus_clk_en   (1'b1),
        .ifu_bus_clk_en   (1'b1),
        .dbg_bus_clk_en   (1'b1),
        .dma_bus_clk_en   (1'b1),
        .timer_int        (1'b0),
        .soft_int         (1'b0),
        .extintsrc_req    (core_irq_out)
    );

    assign s00_axi_awqos    = 4'h0;
    assign s00_axi_awregion = 4'h0;
    assign s00_axi_arqos    = 4'h0;
    assign s00_axi_arregion = 4'h0;

    // ------------------------------------------------------------------------
    // Interconnect Master-Side Buses (M00 to M10)
    // ------------------------------------------------------------------------
    `define DECL_AXI_BUS(name) \
        wire [ID_WIDTH-1:0]   name``_awid; \
        wire [ADDR_WIDTH-1:0] name``_awaddr; \
        wire [7:0]            name``_awlen; \
        wire [2:0]            name``_awsize; \
        wire [1:0]            name``_awburst; \
        wire                  name``_awlock; \
        wire [3:0]            name``_awcache; \
        wire [2:0]            name``_awprot; \
        wire [3:0]            name``_awqos; \
        wire [3:0]            name``_awregion; \
        wire                  name``_awvalid; \
        wire                  name``_awready; \
        wire [DATA_WIDTH-1:0] name``_wdata; \
        wire [(DATA_WIDTH/8)-1:0] name``_wstrb; \
        wire                  name``_wlast; \
        wire                  name``_wvalid; \
        wire                  name``_wready; \
        wire [ID_WIDTH-1:0]   name``_bid; \
        wire [1:0]            name``_bresp; \
        wire                  name``_bvalid; \
        wire                  name``_bready; \
        wire [ID_WIDTH-1:0]   name``_arid; \
        wire [ADDR_WIDTH-1:0] name``_araddr; \
        wire [7:0]            name``_arlen; \
        wire [2:0]            name``_arsize; \
        wire [1:0]            name``_arburst; \
        wire                  name``_arlock; \
        wire [3:0]            name``_arcache; \
        wire [2:0]            name``_arprot; \
        wire [3:0]            name``_arqos; \
        wire [3:0]            name``_arregion; \
        wire                  name``_arvalid; \
        wire                  name``_arready; \
        wire [ID_WIDTH-1:0]   name``_rid; \
        wire [DATA_WIDTH-1:0] name``_rdata; \
        wire [1:0]            name``_rresp; \
        wire                  name``_rlast; \
        wire                  name``_rvalid; \
        wire                  name``_rready;

    `DECL_AXI_BUS(m00_axi)
    `DECL_AXI_BUS(m01_axi)
    `DECL_AXI_BUS(m02_axi)
    `DECL_AXI_BUS(m03_axi)
    `DECL_AXI_BUS(m04_axi)
    `DECL_AXI_BUS(m05_axi)
    `DECL_AXI_BUS(m06_axi)
    `DECL_AXI_BUS(m07_axi)
    `DECL_AXI_BUS(m08_axi)
    `DECL_AXI_BUS(m09_axi)
    `DECL_AXI_BUS(m10_axi)

    // Instantiate 3x11 Crossbar Interconnect
    sentinelsoc_axi_interconnect_3x11 #(
        .DATA_WIDTH         (DATA_WIDTH),
        .ADDR_WIDTH         (ADDR_WIDTH),
        .ID_WIDTH           (ID_WIDTH),

        // M00: UART (0x1000_0000, 4 KB)
        .M00_BASE_ADDR      (32'h1000_0000),
        .M00_ADDR_WIDTH     (12),
        // M01: Timer (0x1000_1000, 4 KB)
        .M01_BASE_ADDR      (32'h1000_1000),
        .M01_ADDR_WIDTH     (12),
        // M02: GPIO (0x1000_2000, 4 KB)
        .M02_BASE_ADDR      (32'h1000_2000),
        .M02_ADDR_WIDTH     (12),
        // M03: ADC (0x1000_3000, 4 KB)
        .M03_BASE_ADDR      (32'h1000_3000),
        .M03_ADDR_WIDTH     (12),
        // M04: FIR (0x1000_4000, 4 KB)
        .M04_BASE_ADDR      (32'h1000_4000),
        .M04_ADDR_WIDTH     (12),
        // M05: QRS (0x1000_5000, 4 KB)
        .M05_BASE_ADDR      (32'h1000_5000),
        .M05_ADDR_WIDTH     (12),
        // M06: AES (0x1000_6000, 4 KB)
        .M06_BASE_ADDR      (32'h1000_6000),
        .M06_ADDR_WIDTH     (12),
        // M07: WDT (0x1000_7000, 4 KB)
        .M07_BASE_ADDR      (32'h1000_7000),
        .M07_ADDR_WIDTH     (12),
        // M08: INT AGGR (0x1000_8000, 4 KB)
        .M08_BASE_ADDR      (32'h1000_8000),
        .M08_ADDR_WIDTH     (12),
        // M09: IMEM (0x0000_0000, 64 KB)
        .M09_BASE_ADDR      (32'h0000_0000),
        .M09_ADDR_WIDTH     (16),
        // M10: DMEM (0x0001_0000, 64 KB)
        .M10_BASE_ADDR      (32'h0001_0000),
        .M10_ADDR_WIDTH     (16)
    ) u_interconnect (
        .clk                (clk),
        .rst                (rst),

        // S00: LSU
        .s00_axi_awid       (s00_axi_awid),
        .s00_axi_awaddr     (s00_axi_awaddr),
        .s00_axi_awlen      (s00_axi_awlen),
        .s00_axi_awsize     (s00_axi_awsize),
        .s00_axi_awburst    (s00_axi_awburst),
        .s00_axi_awlock     (s00_axi_awlock),
        .s00_axi_awcache    (s00_axi_awcache),
        .s00_axi_awprot     (s00_axi_awprot),
        .s00_axi_awqos      (s00_axi_awqos),
        .s00_axi_awuser     (1'b0),
        .s00_axi_awvalid    (s00_axi_awvalid),
        .s00_axi_awready    (s00_axi_awready),
        .s00_axi_wdata      (s00_axi_wdata),
        .s00_axi_wstrb      (s00_axi_wstrb),
        .s00_axi_wlast      (s00_axi_wlast),
        .s00_axi_wuser      (1'b0),
        .s00_axi_wvalid     (s00_axi_wvalid),
        .s00_axi_wready     (s00_axi_wready),
        .s00_axi_bid        (s00_axi_bid),
        .s00_axi_bresp      (s00_axi_bresp),
        .s00_axi_buser      (),
        .s00_axi_bvalid     (s00_axi_bvalid),
        .s00_axi_bready     (s00_axi_bready),
        .s00_axi_arid       (s00_axi_arid),
        .s00_axi_araddr     (s00_axi_araddr),
        .s00_axi_arlen      (s00_axi_arlen),
        .s00_axi_arsize     (s00_axi_arsize),
        .s00_axi_arburst    (s00_axi_arburst),
        .s00_axi_arlock     (s00_axi_arlock),
        .s00_axi_arcache    (s00_axi_arcache),
        .s00_axi_arprot     (s00_axi_arprot),
        .s00_axi_arqos      (s00_axi_arqos),
        .s00_axi_aruser     (1'b0),
        .s00_axi_arvalid    (s00_axi_arvalid),
        .s00_axi_arready    (s00_axi_arready),
        .s00_axi_rid        (s00_axi_rid),
        .s00_axi_rdata      (s00_axi_rdata),
        .s00_axi_rresp      (s00_axi_rresp),
        .s00_axi_rlast      (s00_axi_rlast),
        .s00_axi_ruser      (),
        .s00_axi_rvalid     (s00_axi_rvalid),
        .s00_axi_rready     (s00_axi_rready),

        // S01: Tied off
        .s01_axi_awid       ('0), .s01_axi_awaddr('0), .s01_axi_awlen('0), .s01_axi_awsize('0),
        .s01_axi_awburst    ('0), .s01_axi_awlock(1'b0), .s01_axi_awcache('0), .s01_axi_awprot('0),
        .s01_axi_awqos      ('0), .s01_axi_awuser(1'b0), .s01_axi_awvalid(1'b0), .s01_axi_awready(),
        .s01_axi_wdata      ('0), .s01_axi_wstrb('0), .s01_axi_wlast(1'b0), .s01_axi_wuser(1'b0),
        .s01_axi_wvalid     (1'b0), .s01_axi_wready(), .s01_axi_bid(), .s01_axi_bresp(),
        .s01_axi_buser      (), .s01_axi_bvalid(), .s01_axi_bready(1'b0), .s01_axi_arid('0),
        .s01_axi_araddr     ('0), .s01_axi_arlen('0), .s01_axi_arsize('0), .s01_axi_arburst('0),
        .s01_axi_arlock     (1'b0), .s01_axi_arcache('0), .s01_axi_arprot('0), .s01_axi_arqos('0),
        .s01_axi_aruser     (1'b0), .s01_axi_arvalid(1'b0), .s01_axi_arready(), .s01_axi_rid(),
        .s01_axi_rdata      (), .s01_axi_rresp(), .s01_axi_rlast(), .s01_axi_ruser(),
        .s01_axi_rvalid     (), .s01_axi_rready(1'b0),

        // S02: Tied off
        .s02_axi_awid       ('0), .s02_axi_awaddr('0), .s02_axi_awlen('0), .s02_axi_awsize('0),
        .s02_axi_awburst    ('0), .s02_axi_awlock(1'b0), .s02_axi_awcache('0), .s02_axi_awprot('0),
        .s02_axi_awqos      ('0), .s02_axi_awuser(1'b0), .s02_axi_awvalid(1'b0), .s02_axi_awready(),
        .s02_axi_wdata      ('0), .s02_axi_wstrb('0), .s02_axi_wlast(1'b0), .s02_axi_wuser(1'b0),
        .s02_axi_wvalid     (1'b0), .s02_axi_wready(), .s02_axi_bid(), .s02_axi_bresp(),
        .s02_axi_buser      (), .s02_axi_bvalid(), .s02_axi_bready(1'b0), .s02_axi_arid('0),
        .s02_axi_araddr     ('0), .s02_axi_arlen('0), .s02_axi_arsize('0), .s02_axi_arburst('0),
        .s02_axi_arlock     (1'b0), .s02_axi_arcache('0), .s02_axi_arprot('0), .s02_axi_arqos('0),
        .s02_axi_aruser     (1'b0), .s02_axi_arvalid(1'b0), .s02_axi_arready(), .s02_axi_rid(),
        .s02_axi_rdata      (), .s02_axi_rresp(), .s02_axi_rlast(), .s02_axi_ruser(),
        .s02_axi_rvalid     (), .s02_axi_rready(1'b0),

        // M00: UART
        .m00_axi_awid       (m00_axi_awid), .m00_axi_awaddr(m00_axi_awaddr), .m00_axi_awlen(m00_axi_awlen),
        .m00_axi_awsize     (m00_axi_awsize), .m00_axi_awburst(m00_axi_awburst), .m00_axi_awlock(m00_axi_awlock),
        .m00_axi_awcache    (m00_axi_awcache), .m00_axi_awprot(m00_axi_awprot), .m00_axi_awqos(m00_axi_awqos),
        .m00_axi_awregion   (m00_axi_awregion), .m00_axi_awuser(), .m00_axi_awvalid(m00_axi_awvalid),
        .m00_axi_awready    (m00_axi_awready), .m00_axi_wdata(m00_axi_wdata), .m00_axi_wstrb(m00_axi_wstrb),
        .m00_axi_wlast      (m00_axi_wlast), .m00_axi_wuser(), .m00_axi_wvalid(m00_axi_wvalid),
        .m00_axi_wready     (m00_axi_wready), .m00_axi_bid(m00_axi_bid), .m00_axi_bresp(m00_axi_bresp),
        .m00_axi_buser      (1'b0), .m00_axi_bvalid(m00_axi_bvalid), .m00_axi_bready(m00_axi_bready),
        .m00_axi_arid       (m00_axi_arid), .m00_axi_araddr(m00_axi_araddr), .m00_axi_arlen(m00_axi_arlen),
        .m00_axi_arsize     (m00_axi_arsize), .m00_axi_arburst(m00_axi_arburst), .m00_axi_arlock(m00_axi_arlock),
        .m00_axi_arcache    (m00_axi_arcache), .m00_axi_arprot(m00_axi_arprot), .m00_axi_arqos(m00_axi_arqos),
        .m00_axi_arregion   (m00_axi_arregion), .m00_axi_aruser(), .m00_axi_arvalid(m00_axi_arvalid),
        .m00_axi_arready    (m00_axi_arready), .m00_axi_rid(m00_axi_rid), .m00_axi_rdata(m00_axi_rdata),
        .m00_axi_rresp      (m00_axi_rresp), .m00_axi_rlast(m00_axi_rlast), .m00_axi_ruser(1'b0),
        .m00_axi_rvalid     (m00_axi_rvalid), .m00_axi_rready(m00_axi_rready),

        // M01: Timer
        .m01_axi_awid       (m01_axi_awid), .m01_axi_awaddr(m01_axi_awaddr), .m01_axi_awlen(m01_axi_awlen),
        .m01_axi_awsize     (m01_axi_awsize), .m01_axi_awburst(m01_axi_awburst), .m01_axi_awlock(m01_axi_awlock),
        .m01_axi_awcache    (m01_axi_awcache), .m01_axi_awprot(m01_axi_awprot), .m01_axi_awqos(m01_axi_awqos),
        .m01_axi_awregion   (m01_axi_awregion), .m01_axi_awuser(), .m01_axi_awvalid(m01_axi_awvalid),
        .m01_axi_awready    (m01_axi_awready), .m01_axi_wdata(m01_axi_wdata), .m01_axi_wstrb(m01_axi_wstrb),
        .m01_axi_wlast      (m01_axi_wlast), .m01_axi_wuser(), .m01_axi_wvalid(m01_axi_wvalid),
        .m01_axi_wready     (m01_axi_wready), .m01_axi_bid(m01_axi_bid), .m01_axi_bresp(m01_axi_bresp),
        .m01_axi_buser      (1'b0), .m01_axi_bvalid(m01_axi_bvalid), .m01_axi_bready(m01_axi_bready),
        .m01_axi_arid       (m01_axi_arid), .m01_axi_araddr(m01_axi_araddr), .m01_axi_arlen(m01_axi_arlen),
        .m01_axi_arsize     (m01_axi_arsize), .m01_axi_arburst(m01_axi_arburst), .m01_axi_arlock(m01_axi_arlock),
        .m01_axi_arcache    (m01_axi_arcache), .m01_axi_arprot(m01_axi_arprot), .m01_axi_arqos(m01_axi_arqos),
        .m01_axi_arregion   (m01_axi_arregion), .m01_axi_aruser(), .m01_axi_arvalid(m01_axi_arvalid),
        .m01_axi_arready    (m01_axi_arready), .m01_axi_rid(m01_axi_rid), .m01_axi_rdata(m01_axi_rdata),
        .m01_axi_rresp      (m01_axi_rresp), .m01_axi_rlast(m01_axi_rlast), .m01_axi_ruser(1'b0),
        .m01_axi_rvalid     (m01_axi_rvalid), .m01_axi_rready(m01_axi_rready),

        // M02: GPIO
        .m02_axi_awid       (m02_axi_awid), .m02_axi_awaddr(m02_axi_awaddr), .m02_axi_awlen(m02_axi_awlen),
        .m02_axi_awsize     (m02_axi_awsize), .m02_axi_awburst(m02_axi_awburst), .m02_axi_awlock(m02_axi_awlock),
        .m02_axi_awcache    (m02_axi_awcache), .m02_axi_awprot(m02_axi_awprot), .m02_axi_awqos(m02_axi_awqos),
        .m02_axi_awregion   (m02_axi_awregion), .m02_axi_awuser(), .m02_axi_awvalid(m02_axi_awvalid),
        .m02_axi_awready    (m02_axi_awready), .m02_axi_wdata(m02_axi_wdata), .m02_axi_wstrb(m02_axi_wstrb),
        .m02_axi_wlast      (m02_axi_wlast), .m02_axi_wuser(), .m02_axi_wvalid(m02_axi_wvalid),
        .m02_axi_wready     (m02_axi_wready), .m02_axi_bid(m02_axi_bid), .m02_axi_bresp(m02_axi_bresp),
        .m02_axi_buser      (1'b0), .m02_axi_bvalid(m02_axi_bvalid), .m02_axi_bready(m02_axi_bready),
        .m02_axi_arid       (m02_axi_arid), .m02_axi_araddr(m02_axi_araddr), .m02_axi_arlen(m02_axi_arlen),
        .m02_axi_arsize     (m02_axi_arsize), .m02_axi_arburst(m02_axi_arburst), .m02_axi_arlock(m02_axi_arlock),
        .m02_axi_arcache    (m02_axi_arcache), .m02_axi_arprot(m02_axi_arprot), .m02_axi_arqos(m02_axi_arqos),
        .m02_axi_arregion   (m02_axi_arregion), .m02_axi_aruser(), .m02_axi_arvalid(m02_axi_arvalid),
        .m02_axi_arready    (m02_axi_arready), .m02_axi_rid(m02_axi_rid), .m02_axi_rdata(m02_axi_rdata),
        .m02_axi_rresp      (m02_axi_rresp), .m02_axi_rlast(m02_axi_rlast), .m02_axi_ruser(1'b0),
        .m02_axi_rvalid     (m02_axi_rvalid), .m02_axi_rready(m02_axi_rready),

        // M03: ADC
        .m03_axi_awid       (m03_axi_awid), .m03_axi_awaddr(m03_axi_awaddr), .m03_axi_awlen(m03_axi_awlen),
        .m03_axi_awsize     (m03_axi_awsize), .m03_axi_awburst(m03_axi_awburst), .m03_axi_awlock(m03_axi_awlock),
        .m03_axi_awcache    (m03_axi_awcache), .m03_axi_awprot(m03_axi_awprot), .m03_axi_awqos(m03_axi_awqos),
        .m03_axi_awregion   (m03_axi_awregion), .m03_axi_awuser(), .m03_axi_awvalid(m03_axi_awvalid),
        .m03_axi_awready    (m03_axi_awready), .m03_axi_wdata(m03_axi_wdata), .m03_axi_wstrb(m03_axi_wstrb),
        .m03_axi_wlast      (m03_axi_wlast), .m03_axi_wuser(), .m03_axi_wvalid(m03_axi_wvalid),
        .m03_axi_wready     (m03_axi_wready), .m03_axi_bid(m03_axi_bid), .m03_axi_bresp(m03_axi_bresp),
        .m03_axi_buser      (1'b0), .m03_axi_bvalid(m03_axi_bvalid), .m03_axi_bready(m03_axi_bready),
        .m03_axi_arid       (m03_axi_arid), .m03_axi_araddr(m03_axi_araddr), .m03_axi_arlen(m03_axi_arlen),
        .m03_axi_arsize     (m03_axi_arsize), .m03_axi_arburst(m03_axi_arburst), .m03_axi_arlock(m03_axi_arlock),
        .m03_axi_arcache    (m03_axi_arcache), .m03_axi_arprot(m03_axi_arprot), .m03_axi_arqos(m03_axi_arqos),
        .m03_axi_arregion   (m03_axi_arregion), .m03_axi_aruser(), .m03_axi_arvalid(m03_axi_arvalid),
        .m03_axi_arready    (m03_axi_arready), .m03_axi_rid(m03_axi_rid), .m03_axi_rdata(m03_axi_rdata),
        .m03_axi_rresp      (m03_axi_rresp), .m03_axi_rlast(m03_axi_rlast), .m03_axi_ruser(1'b0),
        .m03_axi_rvalid     (m03_axi_rvalid), .m03_axi_rready(m03_axi_rready),

        // M04: FIR
        .m04_axi_awid       (m04_axi_awid), .m04_axi_awaddr(m04_axi_awaddr), .m04_axi_awlen(m04_axi_awlen),
        .m04_axi_awsize     (m04_axi_awsize), .m04_axi_awburst(m04_axi_awburst), .m04_axi_awlock(m04_axi_awlock),
        .m04_axi_awcache    (m04_axi_awcache), .m04_axi_awprot(m04_axi_awprot), .m04_axi_awqos(m04_axi_awqos),
        .m04_axi_awregion   (m04_axi_awregion), .m04_axi_awuser(), .m04_axi_awvalid(m04_axi_awvalid),
        .m04_axi_awready    (m04_axi_awready), .m04_axi_wdata(m04_axi_wdata), .m04_axi_wstrb(m04_axi_wstrb),
        .m04_axi_wlast      (m04_axi_wlast), .m04_axi_wuser(), .m04_axi_wvalid(m04_axi_wvalid),
        .m04_axi_wready     (m04_axi_wready), .m04_axi_bid(m04_axi_bid), .m04_axi_bresp(m04_axi_bresp),
        .m04_axi_buser      (1'b0), .m04_axi_bvalid(m04_axi_bvalid), .m04_axi_bready(m04_axi_bready),
        .m04_axi_arid       (m04_axi_arid), .m04_axi_araddr(m04_axi_araddr), .m04_axi_arlen(m04_axi_arlen),
        .m04_axi_arsize     (m04_axi_arsize), .m04_axi_arburst(m04_axi_arburst), .m04_axi_arlock(m04_axi_arlock),
        .m04_axi_arcache    (m04_axi_arcache), .m04_axi_arprot(m04_axi_arprot), .m04_axi_arqos(m04_axi_arqos),
        .m04_axi_arregion   (m04_axi_arregion), .m04_axi_aruser(), .m04_axi_arvalid(m04_axi_arvalid),
        .m04_axi_arready    (m04_axi_arready), .m04_axi_rid(m04_axi_rid), .m04_axi_rdata(m04_axi_rdata),
        .m04_axi_rresp      (m04_axi_rresp), .m04_axi_rlast(m04_axi_rlast), .m04_axi_ruser(1'b0),
        .m04_axi_rvalid     (m04_axi_rvalid), .m04_axi_rready(m04_axi_rready),

        // M05: QRS
        .m05_axi_awid       (m05_axi_awid), .m05_axi_awaddr(m05_axi_awaddr), .m05_axi_awlen(m05_axi_awlen),
        .m05_axi_awsize     (m05_axi_awsize), .m05_axi_awburst(m05_axi_awburst), .m05_axi_awlock(m05_axi_awlock),
        .m05_axi_awcache    (m05_axi_awcache), .m05_axi_awprot(m05_axi_awprot), .m05_axi_awqos(m05_axi_awqos),
        .m05_axi_awregion   (m05_axi_awregion), .m05_axi_awuser(), .m05_axi_awvalid(m05_axi_awvalid),
        .m05_axi_awready    (m05_axi_awready), .m05_axi_wdata(m05_axi_wdata), .m05_axi_wstrb(m05_axi_wstrb),
        .m05_axi_wlast      (m05_axi_wlast), .m05_axi_wuser(), .m05_axi_wvalid(m05_axi_wvalid),
        .m05_axi_wready     (m05_axi_wready), .m05_axi_bid(m05_axi_bid), .m05_axi_bresp(m05_axi_bresp),
        .m05_axi_buser      (1'b0), .m05_axi_bvalid(m05_axi_bvalid), .m05_axi_bready(m05_axi_bready),
        .m05_axi_arid       (m05_axi_arid), .m05_axi_araddr(m05_axi_araddr), .m05_axi_arlen(m05_axi_arlen),
        .m05_axi_arsize     (m05_axi_arsize), .m05_axi_arburst(m05_axi_arburst), .m05_axi_arlock(m05_axi_arlock),
        .m05_axi_arcache    (m05_axi_arcache), .m05_axi_arprot(m05_axi_arprot), .m05_axi_arqos(m05_axi_arqos),
        .m05_axi_arregion   (m05_axi_arregion), .m05_axi_aruser(), .m05_axi_arvalid(m05_axi_arvalid),
        .m05_axi_arready    (m05_axi_arready), .m05_axi_rid(m05_axi_rid), .m05_axi_rdata(m05_axi_rdata),
        .m05_axi_rresp      (m05_axi_rresp), .m05_axi_rlast(m05_axi_rlast), .m05_axi_ruser(1'b0),
        .m05_axi_rvalid     (m05_axi_rvalid), .m05_axi_rready(m05_axi_rready),

        // M06: AES
        .m06_axi_awid       (m06_axi_awid), .m06_axi_awaddr(m06_axi_awaddr), .m06_axi_awlen(m06_axi_awlen),
        .m06_axi_awsize     (m06_axi_awsize), .m06_axi_awburst(m06_axi_awburst), .m06_axi_awlock(m06_axi_awlock),
        .m06_axi_awcache    (m06_axi_awcache), .m06_axi_awprot(m06_axi_awprot), .m06_axi_awqos(m06_axi_awqos),
        .m06_axi_awregion   (m06_axi_awregion), .m06_axi_awuser(), .m06_axi_awvalid(m06_axi_awvalid),
        .m06_axi_awready    (m06_axi_awready), .m06_axi_wdata(m06_axi_wdata), .m06_axi_wstrb(m06_axi_wstrb),
        .m06_axi_wlast      (m06_axi_wlast), .m06_axi_wuser(), .m06_axi_wvalid(m06_axi_wvalid),
        .m06_axi_wready     (m06_axi_wready), .m06_axi_bid(m06_axi_bid), .m06_axi_bresp(m06_axi_bresp),
        .m06_axi_buser      (1'b0), .m06_axi_bvalid(m06_axi_bvalid), .m06_axi_bready(m06_axi_bready),
        .m06_axi_arid       (m06_axi_arid), .m06_axi_araddr(m06_axi_araddr), .m06_axi_arlen(m06_axi_arlen),
        .m06_axi_arsize     (m06_axi_arsize), .m06_axi_arburst(m06_axi_arburst), .m06_axi_arlock(m06_axi_arlock),
        .m06_axi_arcache    (m06_axi_arcache), .m06_axi_arprot(m06_axi_arprot), .m06_axi_arqos(m06_axi_arqos),
        .m06_axi_arregion   (m06_axi_arregion), .m06_axi_aruser(), .m06_axi_arvalid(m06_axi_arvalid),
        .m06_axi_arready    (m06_axi_arready), .m06_axi_rid(m06_axi_rid), .m06_axi_rdata(m06_axi_rdata),
        .m06_axi_rresp      (m06_axi_rresp), .m06_axi_rlast(m06_axi_rlast), .m06_axi_ruser(1'b0),
        .m06_axi_rvalid     (m06_axi_rvalid), .m06_axi_rready(m06_axi_rready),

        // M07: WDT
        .m07_axi_awid       (m07_axi_awid), .m07_axi_awaddr(m07_axi_awaddr), .m07_axi_awlen(m07_axi_awlen),
        .m07_axi_awsize     (m07_axi_awsize), .m07_axi_awburst(m07_axi_awburst), .m07_axi_awlock(m07_axi_awlock),
        .m07_axi_awcache    (m07_axi_awcache), .m07_axi_awprot(m07_axi_awprot), .m07_axi_awqos(m07_axi_awqos),
        .m07_axi_awregion   (m07_axi_awregion), .m07_axi_awuser(), .m07_axi_awvalid(m07_axi_awvalid),
        .m07_axi_awready    (m07_axi_awready), .m07_axi_wdata(m07_axi_wdata), .m07_axi_wstrb(m07_axi_wstrb),
        .m07_axi_wlast      (m07_axi_wlast), .m07_axi_wuser(), .m07_axi_wvalid(m07_axi_wvalid),
        .m07_axi_wready     (m07_axi_wready), .m07_axi_bid(m07_axi_bid), .m07_axi_bresp(m07_axi_bresp),
        .m07_axi_buser      (1'b0), .m07_axi_bvalid(m07_axi_bvalid), .m07_axi_bready(m07_axi_bready),
        .m07_axi_arid       (m07_axi_arid), .m07_axi_araddr(m07_axi_araddr), .m07_axi_arlen(m07_axi_arlen),
        .m07_axi_arsize     (m07_axi_arsize), .m07_axi_arburst(m07_axi_arburst), .m07_axi_arlock(m07_axi_arlock),
        .m07_axi_arcache    (m07_axi_arcache), .m07_axi_arprot(m07_axi_arprot), .m07_axi_arqos(m07_axi_arqos),
        .m07_axi_arregion   (m07_axi_arregion), .m07_axi_aruser(), .m07_axi_arvalid(m07_axi_arvalid),
        .m07_axi_arready    (m07_axi_arready), .m07_axi_rid(m07_axi_rid), .m07_axi_rdata(m07_axi_rdata),
        .m07_axi_rresp      (m07_axi_rresp), .m07_axi_rlast(m07_axi_rlast), .m07_axi_ruser(1'b0),
        .m07_axi_rvalid     (m07_axi_rvalid), .m07_axi_rready(m07_axi_rready),

        // M08: INT AGGR
        .m08_axi_awid       (m08_axi_awid), .m08_axi_awaddr(m08_axi_awaddr), .m08_axi_awlen(m08_axi_awlen),
        .m08_axi_awsize     (m08_axi_awsize), .m08_axi_awburst(m08_axi_awburst), .m08_axi_awlock(m08_axi_awlock),
        .m08_axi_awcache    (m08_axi_awcache), .m08_axi_awprot(m08_axi_awprot), .m08_axi_awqos(m08_axi_awqos),
        .m08_axi_awregion   (m08_axi_awregion), .m08_axi_awuser(), .m08_axi_awvalid(m08_axi_awvalid),
        .m08_axi_awready    (m08_axi_awready), .m08_axi_wdata(m08_axi_wdata), .m08_axi_wstrb(m08_axi_wstrb),
        .m08_axi_wlast      (m08_axi_wlast), .m08_axi_wuser(), .m08_axi_wvalid(m08_axi_wvalid),
        .m08_axi_wready     (m08_axi_wready), .m08_axi_bid(m08_axi_bid), .m08_axi_bresp(m08_axi_bresp),
        .m08_axi_buser      (1'b0), .m08_axi_bvalid(m08_axi_bvalid), .m08_axi_bready(m08_axi_bready),
        .m08_axi_arid       (m08_axi_arid), .m08_axi_araddr(m08_axi_araddr), .m08_axi_arlen(m08_axi_arlen),
        .m08_axi_arsize     (m08_axi_arsize), .m08_axi_arburst(m08_axi_arburst), .m08_axi_arlock(m08_axi_arlock),
        .m08_axi_arcache    (m08_axi_arcache), .m08_axi_arprot(m08_axi_arprot), .m08_axi_arqos(m08_axi_arqos),
        .m08_axi_arregion   (m08_axi_arregion), .m08_axi_aruser(), .m08_axi_arvalid(m08_axi_arvalid),
        .m08_axi_arready    (m08_axi_arready), .m08_axi_rid(m08_axi_rid), .m08_axi_rdata(m08_axi_rdata),
        .m08_axi_rresp      (m08_axi_rresp), .m08_axi_rlast(m08_axi_rlast), .m08_axi_ruser(1'b0),
        .m08_axi_rvalid     (m08_axi_rvalid), .m08_axi_rready(m08_axi_rready),

        // M09: IMEM
        .m09_axi_awid       (m09_axi_awid), .m09_axi_awaddr(m09_axi_awaddr), .m09_axi_awlen(m09_axi_awlen),
        .m09_axi_awsize     (m09_axi_awsize), .m09_axi_awburst(m09_axi_awburst), .m09_axi_awlock(m09_axi_awlock),
        .m09_axi_awcache    (m09_axi_awcache), .m09_axi_awprot(m09_axi_awprot), .m09_axi_awqos(m09_axi_awqos),
        .m09_axi_awregion   (m09_axi_awregion), .m09_axi_awuser(), .m09_axi_awvalid(m09_axi_awvalid),
        .m09_axi_awready    (m09_axi_awready), .m09_axi_wdata(m09_axi_wdata), .m09_axi_wstrb(m09_axi_wstrb),
        .m09_axi_wlast      (m09_axi_wlast), .m09_axi_wuser(), .m09_axi_wvalid(m09_axi_wvalid),
        .m09_axi_wready     (m09_axi_wready), .m09_axi_bid(m09_axi_bid), .m09_axi_bresp(m09_axi_bresp),
        .m09_axi_buser      (1'b0), .m09_axi_bvalid(m09_axi_bvalid), .m09_axi_bready(m09_axi_bready),
        .m09_axi_arid       (m09_axi_arid), .m09_axi_araddr(m09_axi_araddr), .m09_axi_arlen(m09_axi_arlen),
        .m09_axi_arsize     (m09_axi_arsize), .m09_axi_arburst(m09_axi_arburst), .m09_axi_arlock(m09_axi_arlock),
        .m09_axi_arcache    (m09_axi_arcache), .m09_axi_arprot(m09_axi_arprot), .m09_axi_arqos(m09_axi_arqos),
        .m09_axi_arregion   (m09_axi_arregion), .m09_axi_aruser(), .m09_axi_arvalid(m09_axi_arvalid),
        .m09_axi_arready    (m09_axi_arready), .m09_axi_rid(m09_axi_rid), .m09_axi_rdata(m09_axi_rdata),
        .m09_axi_rresp      (m09_axi_rresp), .m09_axi_rlast(m09_axi_rlast), .m09_axi_ruser(1'b0),
        .m09_axi_rvalid     (m09_axi_rvalid), .m09_axi_rready(m09_axi_rready),

        // M10: DMEM
        .m10_axi_awid       (m10_axi_awid), .m10_axi_awaddr(m10_axi_awaddr), .m10_axi_awlen(m10_axi_awlen),
        .m10_axi_awsize     (m10_axi_awsize), .m10_axi_awburst(m10_axi_awburst), .m10_axi_awlock(m10_axi_awlock),
        .m10_axi_awcache    (m10_axi_awcache), .m10_axi_awprot(m10_axi_awprot), .m10_axi_awqos(m10_axi_awqos),
        .m10_axi_awregion   (m10_axi_awregion), .m10_axi_awuser(), .m10_axi_awvalid(m10_axi_awvalid),
        .m10_axi_awready    (m10_axi_awready), .m10_axi_wdata(m10_axi_wdata), .m10_axi_wstrb(m10_axi_wstrb),
        .m10_axi_wlast      (m10_axi_wlast), .m10_axi_wuser(), .m10_axi_wvalid(m10_axi_wvalid),
        .m10_axi_wready     (m10_axi_wready), .m10_axi_bid(m10_axi_bid), .m10_axi_bresp(m10_axi_bresp),
        .m10_axi_buser      (1'b0), .m10_axi_bvalid(m10_axi_bvalid), .m10_axi_bready(m10_axi_bready),
        .m10_axi_arid       (m10_axi_arid), .m10_axi_araddr(m10_axi_araddr), .m10_axi_arlen(m10_axi_arlen),
        .m10_axi_arsize     (m10_axi_arsize), .m10_axi_arburst(m10_axi_arburst), .m10_axi_arlock(m10_axi_arlock),
        .m10_axi_arcache    (m10_axi_arcache), .m10_axi_arprot(m10_axi_arprot), .m10_axi_arqos(m10_axi_arqos),
        .m10_axi_arregion   (m10_axi_arregion), .m10_axi_aruser(), .m10_axi_arvalid(m10_axi_arvalid),
        .m10_axi_arready    (m10_axi_arready), .m10_axi_rid(m10_axi_rid), .m10_axi_rdata(m10_axi_rdata),
        .m10_axi_rresp      (m10_axi_rresp), .m10_axi_rlast(m10_axi_rlast), .m10_axi_ruser(1'b0),
        .m10_axi_rvalid     (m10_axi_rvalid), .m10_axi_rready(m10_axi_rready)
    );

    // ------------------------------------------------------------------------
    // M00: UART Controller (0x1000_0000)
    // ------------------------------------------------------------------------
    wire uart_irq;
    axi_uart_top u_uart (
        .fixed_clk_i      (clk),
        .axi_aclk_i       (clk),
        .axi_aresetn_i    (aresetn),

        .axi_awid_i       (m00_axi_awid),
        .axi_awaddr_i     (m00_axi_awaddr[4:0]),
        .axi_awvalid_i    (m00_axi_awvalid),
        .axi_awready_o    (m00_axi_awready),

        .axi_wdata_i      (m00_axi_wdata),
        .axi_wstrb_i      (m00_axi_wstrb),
        .axi_wvalid_i     (m00_axi_wvalid),
        .axi_wready_o     (m00_axi_wready),

        .axi_bid_o        (m00_axi_bid),
        .axi_bresp_o      (m00_axi_bresp),
        .axi_bvalid_o     (m00_axi_bvalid),
        .axi_bready_i     (m00_axi_bready),

        .axi_arid_i       (m00_axi_arid),
        .axi_araddr_i     (m00_axi_araddr[4:0]),
        .axi_arvalid_i    (m00_axi_arvalid),
        .axi_arready_o    (m00_axi_arready),

        .axi_rid_o        (m00_axi_rid),
        .axi_rdata_o      (m00_axi_rdata),
        .axi_rresp_o      (m00_axi_rresp),
        .axi_rvalid_o     (m00_axi_rvalid),
        .axi_rready_i     (m00_axi_rready),

        .uart_rx_i        (uart_rx),
        .uart_tx_o        (uart_tx),
        .read_interrupt_o (uart_irq)
    );
    assign m00_axi_rlast = 1'b1;

    // ------------------------------------------------------------------------
    // M01: Timer Controller (0x1000_1000)
    // ------------------------------------------------------------------------
    wire timer_irq;
    wire [ADDR_WIDTH-1:0] timer_lite_awaddr, timer_lite_araddr;
    wire [2:0] timer_lite_awprot, timer_lite_arprot;
    wire timer_lite_awvalid, timer_lite_awready, timer_lite_wvalid, timer_lite_wready;
    wire [DATA_WIDTH-1:0] timer_lite_wdata, timer_lite_rdata;
    wire [(DATA_WIDTH/8)-1:0] timer_lite_wstrb;
    wire [1:0] timer_lite_bresp, timer_lite_rresp;
    wire timer_lite_bvalid, timer_lite_bready, timer_lite_arvalid, timer_lite_arready, timer_lite_rvalid, timer_lite_rready;

    axi4_to_axi4lite_bridge #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .ID_WIDTH   (ID_WIDTH)
    ) u_bridge_timer (
        .aclk       (clk),
        .aresetn    (aresetn),

        .s_awid     (m01_axi_awid),
        .s_awaddr   (m01_axi_awaddr),
        .s_awlen    (m01_axi_awlen),
        .s_awsize   (m01_axi_awsize),
        .s_awburst  (m01_axi_awburst),
        .s_awlock   (m01_axi_awlock),
        .s_awcache  (m01_axi_awcache),
        .s_awprot   (m01_axi_awprot),
        .s_awqos    (m01_axi_awqos),
        .s_awregion (m01_axi_awregion),
        .s_awuser   (1'b0),
        .s_awvalid  (m01_axi_awvalid),
        .s_awready  (m01_axi_awready),

        .s_wdata    (m01_axi_wdata),
        .s_wstrb    (m01_axi_wstrb),
        .s_wlast    (m01_axi_wlast),
        .s_wuser    (1'b0),
        .s_wvalid   (m01_axi_wvalid),
        .s_wready   (m01_axi_wready),

        .s_bid      (m01_axi_bid),
        .s_bresp    (m01_axi_bresp),
        .s_buser    (),
        .s_bvalid   (m01_axi_bvalid),
        .s_bready   (m01_axi_bready),

        .s_arid     (m01_axi_arid),
        .s_araddr   (m01_axi_araddr),
        .s_arlen    (m01_axi_arlen),
        .s_arsize   (m01_axi_arsize),
        .s_arburst  (m01_axi_arburst),
        .s_arlock   (m01_axi_arlock),
        .s_arcache  (m01_axi_arcache),
        .s_arprot   (m01_axi_arprot),
        .s_arqos    (m01_axi_arqos),
        .s_arregion (m01_axi_arregion),
        .s_aruser   (1'b0),
        .s_arvalid  (m01_axi_arvalid),
        .s_arready  (m01_axi_arready),

        .s_rid      (m01_axi_rid),
        .s_rdata    (m01_axi_rdata),
        .s_rresp    (m01_axi_rresp),
        .s_rlast    (m01_axi_rlast),
        .s_ruser    (),
        .s_rvalid   (m01_axi_rvalid),
        .s_rready   (m01_axi_rready),

        .m_awaddr   (timer_lite_awaddr),
        .m_awprot   (timer_lite_awprot),
        .m_awvalid  (timer_lite_awvalid),
        .m_awready  (timer_lite_awready),
        .m_wdata    (timer_lite_wdata),
        .m_wstrb    (timer_lite_wstrb),
        .m_wvalid   (timer_lite_wvalid),
        .m_wready   (timer_lite_wready),
        .m_bresp    (timer_lite_bresp),
        .m_bvalid   (timer_lite_bvalid),
        .m_bready   (timer_lite_bready),
        .m_araddr   (timer_lite_araddr),
        .m_arprot   (timer_lite_arprot),
        .m_arvalid  (timer_lite_arvalid),
        .m_arready  (timer_lite_arready),
        .m_rdata    (timer_lite_rdata),
        .m_rresp    (timer_lite_rresp),
        .m_rvalid   (timer_lite_rvalid),
        .m_rready   (timer_lite_rready)
    );

    timer_axi u_timer (
        .aclk         (clk),
        .aresetn      (aresetn),

        .awaddr       (timer_lite_awaddr),
        .awprot       (timer_lite_awprot),
        .awvalid      (timer_lite_awvalid),
        .awready      (timer_lite_awready),
        .wdata        (timer_lite_wdata),
        .wstrb        (timer_lite_wstrb),
        .wvalid       (timer_lite_wvalid),
        .wready       (timer_lite_wready),
        .bresp        (timer_lite_bresp),
        .bvalid       (timer_lite_bvalid),
        .bready       (timer_lite_bready),
        .araddr       (timer_lite_araddr),
        .arprot       (timer_lite_arprot),
        .arvalid      (timer_lite_arvalid),
        .arready      (timer_lite_arready),
        .rdata        (timer_lite_rdata),
        .rresp        (timer_lite_rresp),
        .rvalid       (timer_lite_rvalid),
        .rready       (timer_lite_rready),

        .ext_meas_i   (1'b0),
        .capture_i    (1'b0),
        .pwm_o        (),
        .trigger_o    (),
        .irq            (timer_irq)
    );

    // ------------------------------------------------------------------------
    // M02: GPIO Controller (0x1000_2000)
    // ------------------------------------------------------------------------
    wire gpio_irq;
    wire [ADDR_WIDTH-1:0] gpio_lite_awaddr, gpio_lite_araddr;
    wire [2:0] gpio_lite_awprot, gpio_lite_arprot;
    wire gpio_lite_awvalid, gpio_lite_awready, gpio_lite_wvalid, gpio_lite_wready;
    wire [DATA_WIDTH-1:0] gpio_lite_wdata, gpio_lite_rdata;
    wire [(DATA_WIDTH/8)-1:0] gpio_lite_wstrb;
    wire [1:0] gpio_lite_bresp, gpio_lite_rresp;
    wire gpio_lite_bvalid, gpio_lite_bready, gpio_lite_arvalid, gpio_lite_arready, gpio_lite_rvalid, gpio_lite_rready;

    axi4_to_axi4lite_bridge #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .ID_WIDTH   (ID_WIDTH)
    ) u_bridge_gpio (
        .aclk       (clk),
        .aresetn    (aresetn),

        .s_awid     (m02_axi_awid),
        .s_awaddr   (m02_axi_awaddr),
        .s_awlen    (m02_axi_awlen),
        .s_awsize   (m02_axi_awsize),
        .s_awburst  (m02_axi_awburst),
        .s_awlock   (m02_axi_awlock),
        .s_awcache  (m02_axi_awcache),
        .s_awprot   (m02_axi_awprot),
        .s_awqos    (m02_axi_awqos),
        .s_awregion (m02_axi_awregion),
        .s_awuser   (1'b0),
        .s_awvalid  (m02_axi_awvalid),
        .s_awready  (m02_axi_awready),

        .s_wdata    (m02_axi_wdata),
        .s_wstrb    (m02_axi_wstrb),
        .s_wlast    (m02_axi_wlast),
        .s_wuser    (1'b0),
        .s_wvalid   (m02_axi_wvalid),
        .s_wready   (m02_axi_wready),

        .s_bid      (m02_axi_bid),
        .s_bresp    (m02_axi_bresp),
        .s_buser    (),
        .s_bvalid   (m02_axi_bvalid),
        .s_bready   (m02_axi_bready),

        .s_arid     (m02_axi_arid),
        .s_araddr   (m02_axi_araddr),
        .s_arlen    (m02_axi_arlen),
        .s_arsize   (m02_axi_arsize),
        .s_arburst  (m02_axi_arburst),
        .s_arlock   (m02_axi_arlock),
        .s_arcache  (m02_axi_arcache),
        .s_arprot   (m02_axi_arprot),
        .s_arqos    (m02_axi_arqos),
        .s_arregion (m02_axi_arregion),
        .s_aruser   (1'b0),
        .s_arvalid  (m02_axi_arvalid),
        .s_arready  (m02_axi_arready),

        .s_rid      (m02_axi_rid),
        .s_rdata    (m02_axi_rdata),
        .s_rresp    (m02_axi_rresp),
        .s_rlast    (m02_axi_rlast),
        .s_ruser    (),
        .s_rvalid   (m02_axi_rvalid),
        .s_rready   (m02_axi_rready),

        .m_awaddr   (gpio_lite_awaddr),
        .m_awprot   (gpio_lite_awprot),
        .m_awvalid  (gpio_lite_awvalid),
        .m_awready  (gpio_lite_awready),
        .m_wdata    (gpio_lite_wdata),
        .m_wstrb    (gpio_lite_wstrb),
        .m_wvalid   (gpio_lite_wvalid),
        .m_wready   (gpio_lite_wready),
        .m_bresp    (gpio_lite_bresp),
        .m_bvalid   (gpio_lite_bvalid),
        .m_bready   (gpio_lite_bready),
        .m_araddr   (gpio_lite_araddr),
        .m_arprot   (gpio_lite_arprot),
        .m_arvalid  (gpio_lite_arvalid),
        .m_arready  (gpio_lite_arready),
        .m_rdata    (gpio_lite_rdata),
        .m_rresp    (gpio_lite_rresp),
        .m_rvalid   (gpio_lite_rvalid),
        .m_rready   (gpio_lite_rready)
    );

    gpio_axi #(
        .NUM_BITS     (GPIO_BITS)
    ) u_gpio (
        .s_axi_aclk    (clk),
        .s_axi_aresetn (aresetn),

        .s_axi_awaddr  (gpio_lite_awaddr),
        .s_axi_awprot  (gpio_lite_awprot),
        .s_axi_awvalid (gpio_lite_awvalid),
        .s_axi_awready (gpio_lite_awready),
        .s_axi_wdata   (gpio_lite_wdata),
        .s_axi_wstrb   (gpio_lite_wstrb),
        .s_axi_wvalid  (gpio_lite_wvalid),
        .s_axi_wready  (gpio_lite_wready),
        .s_axi_bresp   (gpio_lite_bresp),
        .s_axi_bvalid  (gpio_lite_bvalid),
        .s_axi_bready  (gpio_lite_bready),
        .s_axi_araddr  (gpio_lite_araddr),
        .s_axi_arprot  (gpio_lite_arprot),
        .s_axi_arvalid (gpio_lite_arvalid),
        .s_axi_arready (gpio_lite_arready),
        .s_axi_rdata   (gpio_lite_rdata),
        .s_axi_rresp   (gpio_lite_rresp),
        .s_axi_rvalid  (gpio_lite_rvalid),
        .s_axi_rready  (gpio_lite_rready),

        .io            (gpio_io),
        .intr          (gpio_irq)
    );

    // ------------------------------------------------------------------------
    // M03: ADC Controller (0x1000_3000)
    // ------------------------------------------------------------------------
    wire adc_irq_sample;
    wire adc_irq_overrun;
    adc_controller #(
        .ADC_RESOLUTION    (12),
        .NUM_CHANNELS      (1),
        .FIFO_DEPTH        (32),
        .CLK_FREQ_HZ       (50_000_000),
        .SAMPLE_RATE_HZ    (250),
        .BASE_ADDR         (32'h1000_3000),
        .ENABLE_FIFO       (1),
        .ENABLE_INTERRUPTS (1)
    ) u_adc (
        .aclk            (clk),
        .aresetn         (aresetn),

        .sample_in       (adc_sample_data),
        .sample_valid    (adc_sample_valid),

        .irq_sample      (adc_irq_sample),
        .irq_overrun     (adc_irq_overrun),

        .s_axi_awaddr    (m03_axi_awaddr),
        .s_axi_awvalid   (m03_axi_awvalid),
        .s_axi_awready   (m03_axi_awready),

        .s_axi_wdata     (m03_axi_wdata),
        .s_axi_wstrb     (m03_axi_wstrb),
        .s_axi_wvalid    (m03_axi_wvalid),
        .s_axi_wready    (m03_axi_wready),

        .s_axi_bresp     (m03_axi_bresp),
        .s_axi_bvalid    (m03_axi_bvalid),
        .s_axi_bready    (m03_axi_bready),

        .s_axi_araddr    (m03_axi_araddr),
        .s_axi_arvalid   (m03_axi_arvalid),
        .s_axi_arready   (m03_axi_arready),

        .s_axi_rdata     (m03_axi_rdata),
        .s_axi_rresp     (m03_axi_rresp),
        .s_axi_rvalid    (m03_axi_rvalid),
        .s_axi_rready    (m03_axi_rready)
    );

    // ------------------------------------------------------------------------
    // M04: FIR Filter Engine (0x1000_4000)
    // ------------------------------------------------------------------------
    wire [15:0] fir_m_axis_tdata;
    wire        fir_m_axis_tvalid;
    wire        fir_m_axis_tready = 1'b1;

    localparam [31:0] FIR_BASE_ADDR = 32'h1000_4000;
    wire [31:0] fir_axi_awaddr = m04_axi_awaddr - FIR_BASE_ADDR;
    wire [31:0] fir_axi_araddr = m04_axi_araddr - FIR_BASE_ADDR;

    fir_top #(
        .DATA_WIDTH (16),
        .COEFF_WIDTH(16),
        .ACC_WIDTH  (40),
        .NUM_TAPS   (16),
        .FIFO_DEPTH (8)
    ) u_fir (
        .clk                (clk),
        .rst_n              (aresetn),

        // Connect ADC sample directly to FIR streaming input
        .s_axis_tvalid     (adc_sample_valid),
        .s_axis_tready     (),
        .s_axis_tdata      ({{4{adc_sample_data[11]}}, adc_sample_data}),

        .m_axis_tvalid     (fir_m_axis_tvalid),
        .m_axis_tready     (fir_m_axis_tready),
        .m_axis_tdata      (fir_m_axis_tdata),

        .s_axi_awaddr      (fir_axi_awaddr),
        .s_axi_awvalid     (m04_axi_awvalid),
        .s_axi_awready     (m04_axi_awready),

        .s_axi_wdata       (m04_axi_wdata),
        .s_axi_wstrb       (m04_axi_wstrb),
        .s_axi_wvalid      (m04_axi_wvalid),
        .s_axi_wready      (m04_axi_wready),

        .s_axi_bvalid      (m04_axi_bvalid),
        .s_axi_bresp       (m04_axi_bresp),
        .s_axi_bready      (m04_axi_bready),

        .s_axi_araddr      (fir_axi_araddr),
        .s_axi_arvalid     (m04_axi_arvalid),
        .s_axi_arready     (m04_axi_arready),

        .s_axi_rdata       (m04_axi_rdata),
        .s_axi_rvalid      (m04_axi_rvalid),
        .s_axi_rresp       (m04_axi_rresp),
        .s_axi_rready      (m04_axi_rready),

        .input_fifo_full   (),
        .input_fifo_empty  (),
        .output_fifo_empty ()
    );

    // ------------------------------------------------------------------------
    // M05: QRS Accelerator (0x1000_5000)
    // ------------------------------------------------------------------------
    wire qrs_peak_irq;
    qrs_axi4_wrapper #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .ID_WIDTH   (ID_WIDTH),
        .BASE_ADDR  (32'h1000_5000)
    ) u_qrs (
        .clk          (clk),
        .rst          (rst),

        .s_axi_awid   (m05_axi_awid),
        .s_axi_awaddr (m05_axi_awaddr),
        .s_axi_awlen  (m05_axi_awlen),
        .s_axi_awsize (m05_axi_awsize),
        .s_axi_awburst(m05_axi_awburst),
        .s_axi_awlock (m05_axi_awlock),
        .s_axi_awcache(m05_axi_awcache),
        .s_axi_awprot (m05_axi_awprot),
        .s_axi_awqos  (m05_axi_awqos),
        .s_axi_awvalid(m05_axi_awvalid),
        .s_axi_awready(m05_axi_awready),

        .s_axi_wdata  (m05_axi_wdata),
        .s_axi_wstrb  (m05_axi_wstrb),
        .s_axi_wlast  (m05_axi_wlast),
        .s_axi_wvalid (m05_axi_wvalid),
        .s_axi_wready (m05_axi_wready),

        .s_axi_bid    (m05_axi_bid),
        .s_axi_bresp  (m05_axi_bresp),
        .s_axi_bvalid (m05_axi_bvalid),
        .s_axi_bready (m05_axi_bready),

        .s_axi_arid   (m05_axi_arid),
        .s_axi_araddr (m05_axi_araddr),
        .s_axi_arlen  (m05_axi_arlen),
        .s_axi_arsize (m05_axi_arsize),
        .s_axi_arburst(m05_axi_arburst),
        .s_axi_arlock (m05_axi_arlock),
        .s_axi_arcache(m05_axi_arcache),
        .s_axi_arprot (m05_axi_arprot),
        .s_axi_arqos  (m05_axi_arqos),
        .s_axi_arvalid(m05_axi_arvalid),
        .s_axi_arready(m05_axi_arready),

        .s_axi_rid    (m05_axi_rid),
        .s_axi_rdata  (m05_axi_rdata),
        .s_axi_rresp  (m05_axi_rresp),
        .s_axi_rlast  (m05_axi_rlast),
        .s_axi_rvalid (m05_axi_rvalid),
        .s_axi_rready (m05_axi_rready)
    );

    // Dedicated hardware alert LED directly from QRS alert
    assign alert_led = (u_qrs.u_wtsee.rhythm_class != 2'b00) | u_qrs.u_wtsee.r_peak;
    assign qrs_peak_irq = u_qrs.u_wtsee.r_peak;

    // ------------------------------------------------------------------------
    // M06: AES-128 Encryption Engine (0x1000_6000)
    // ------------------------------------------------------------------------
    wire aes_done_irq;
    wire [ADDR_WIDTH-1:0] aes_lite_awaddr, aes_lite_araddr;
    wire [2:0] aes_lite_awprot, aes_lite_arprot;
    wire aes_lite_awvalid, aes_lite_awready, aes_lite_wvalid, aes_lite_wready;
    wire [DATA_WIDTH-1:0] aes_lite_wdata, aes_lite_rdata;
    wire [(DATA_WIDTH/8)-1:0] aes_lite_wstrb;
    wire [1:0] aes_lite_bresp, aes_lite_rresp;
    wire aes_lite_bvalid, aes_lite_bready, aes_lite_arvalid, aes_lite_arready, aes_lite_rvalid, aes_lite_rready;

    axi4_to_axi4lite_bridge #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .ID_WIDTH   (ID_WIDTH)
    ) u_bridge_aes (
        .aclk       (clk),
        .aresetn    (aresetn),

        .s_awid     (m06_axi_awid),
        .s_awaddr   (m06_axi_awaddr),
        .s_awlen    (m06_axi_awlen),
        .s_awsize   (m06_axi_awsize),
        .s_awburst  (m06_axi_awburst),
        .s_awlock   (m06_axi_awlock),
        .s_awcache  (m06_axi_awcache),
        .s_awprot   (m06_axi_awprot),
        .s_awqos    (m06_axi_awqos),
        .s_awregion (m06_axi_awregion),
        .s_awuser   (1'b0),
        .s_awvalid  (m06_axi_awvalid),
        .s_awready  (m06_axi_awready),

        .s_wdata    (m06_axi_wdata),
        .s_wstrb    (m06_axi_wstrb),
        .s_wlast    (m06_axi_wlast),
        .s_wuser    (1'b0),
        .s_wvalid   (m06_axi_wvalid),
        .s_wready   (m06_axi_wready),

        .s_bid      (m06_axi_bid),
        .s_bresp    (m06_axi_bresp),
        .s_buser    (),
        .s_bvalid   (m06_axi_bvalid),
        .s_bready   (m06_axi_bready),

        .s_arid     (m06_axi_arid),
        .s_araddr   (m06_axi_araddr),
        .s_arlen    (m06_axi_arlen),
        .s_arsize   (m06_axi_arsize),
        .s_arburst  (m06_axi_arburst),
        .s_arlock   (m06_axi_arlock),
        .s_arcache  (m06_axi_arcache),
        .s_arprot   (m06_axi_arprot),
        .s_arqos    (m06_axi_arqos),
        .s_arregion (m06_axi_arregion),
        .s_aruser   (1'b0),
        .s_arvalid  (m06_axi_arvalid),
        .s_arready  (m06_axi_arready),

        .s_rid      (m06_axi_rid),
        .s_rdata    (m06_axi_rdata),
        .s_rresp    (m06_axi_rresp),
        .s_rlast    (m06_axi_rlast),
        .s_ruser    (),
        .s_rvalid   (m06_axi_rvalid),
        .s_rready   (m06_axi_rready),

        .m_awaddr   (aes_lite_awaddr),
        .m_awprot   (aes_lite_awprot),
        .m_awvalid  (aes_lite_awvalid),
        .m_awready  (aes_lite_awready),
        .m_wdata    (aes_lite_wdata),
        .m_wstrb    (aes_lite_wstrb),
        .m_wvalid   (aes_lite_wvalid),
        .m_wready   (aes_lite_wready),
        .m_bresp    (aes_lite_bresp),
        .m_bvalid   (aes_lite_bvalid),
        .m_bready   (aes_lite_bready),
        .m_araddr   (aes_lite_araddr),
        .m_arprot   (aes_lite_arprot),
        .m_arvalid  (aes_lite_arvalid),
        .m_arready  (aes_lite_arready),
        .m_rdata    (aes_lite_rdata),
        .m_rresp    (aes_lite_rresp),
        .m_rvalid   (aes_lite_rvalid),
        .m_rready   (aes_lite_rready)
    );

    axi_aes_cipher_slave #(
        .C_S_AXI_DATA_WIDTH (DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH (6)
    ) u_aes (
        .s_axi_aclk    (clk),
        .s_axi_aresetn (aresetn),

        .s_axi_awaddr  (aes_lite_awaddr[5:0]),
        .s_axi_awvalid (aes_lite_awvalid),
        .s_axi_awready (aes_lite_awready),

        .s_axi_wdata   (aes_lite_wdata),
        .s_axi_wstrb   (aes_lite_wstrb),
        .s_axi_wvalid  (aes_lite_wvalid),
        .s_axi_wready  (aes_lite_wready),

        .s_axi_bresp   (aes_lite_bresp),
        .s_axi_bvalid  (aes_lite_bvalid),
        .s_axi_bready  (aes_lite_bready),

        .s_axi_araddr  (aes_lite_araddr[5:0]),
        .s_axi_arvalid (aes_lite_arvalid),
        .s_axi_arready (aes_lite_arready),

        .s_axi_rdata   (aes_lite_rdata),
        .s_axi_rresp   (aes_lite_rresp),
        .s_axi_rvalid  (aes_lite_rvalid),
        .s_axi_rready  (aes_lite_rready),

        .aes_done_irq  (aes_done_irq)
    );

    // ------------------------------------------------------------------------
    // M07: Watchdog Timer (0x1000_7000)
    // ------------------------------------------------------------------------
    wire wdt_irq;
    wire [ADDR_WIDTH-1:0] wdt_lite_awaddr, wdt_lite_araddr;
    wire [2:0] wdt_lite_awprot, wdt_lite_arprot;
    wire wdt_lite_awvalid, wdt_lite_awready, wdt_lite_wvalid, wdt_lite_wready;
    wire [DATA_WIDTH-1:0] wdt_lite_wdata, wdt_lite_rdata;
    wire [(DATA_WIDTH/8)-1:0] wdt_lite_wstrb;
    wire [1:0] wdt_lite_bresp, wdt_lite_rresp;
    wire wdt_lite_bvalid, wdt_lite_bready, wdt_lite_arvalid, wdt_lite_arready, wdt_lite_rvalid, wdt_lite_rready;

    axi4_to_axi4lite_bridge #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .ID_WIDTH   (ID_WIDTH)
    ) u_bridge_wdt (
        .aclk       (clk),
        .aresetn    (aresetn),

        .s_awid     (m07_axi_awid),
        .s_awaddr   (m07_axi_awaddr),
        .s_awlen    (m07_axi_awlen),
        .s_awsize   (m07_axi_awsize),
        .s_awburst  (m07_axi_awburst),
        .s_awlock   (m07_axi_awlock),
        .s_awcache  (m07_axi_awcache),
        .s_awprot   (m07_axi_awprot),
        .s_awqos    (m07_axi_awqos),
        .s_awregion (m07_axi_awregion),
        .s_awuser   (1'b0),
        .s_awvalid  (m07_axi_awvalid),
        .s_awready  (m07_axi_awready),

        .s_wdata    (m07_axi_wdata),
        .s_wstrb    (m07_axi_wstrb),
        .s_wlast    (m07_axi_wlast),
        .s_wuser    (1'b0),
        .s_wvalid   (m07_axi_wvalid),
        .s_wready   (m07_axi_wready),

        .s_bid      (m07_axi_bid),
        .s_bresp    (m07_axi_bresp),
        .s_buser    (),
        .s_bvalid   (m07_axi_bvalid),
        .s_bready   (m07_axi_bready),

        .s_arid     (m07_axi_arid),
        .s_araddr   (m07_axi_araddr),
        .s_arlen    (m07_axi_arlen),
        .s_arsize   (m07_axi_arsize),
        .s_arburst  (m07_axi_arburst),
        .s_arlock   (m07_axi_arlock),
        .s_arcache  (m07_axi_arcache),
        .s_arprot   (m07_axi_arprot),
        .s_arqos    (m07_axi_arqos),
        .s_arregion (m07_axi_arregion),
        .s_aruser   (1'b0),
        .s_arvalid  (m07_axi_arvalid),
        .s_arready  (m07_axi_arready),

        .s_rid      (m07_axi_rid),
        .s_rdata    (m07_axi_rdata),
        .s_rresp    (m07_axi_rresp),
        .s_rlast    (m07_axi_rlast),
        .s_ruser    (),
        .s_rvalid   (m07_axi_rvalid),
        .s_rready   (m07_axi_rready),

        .m_awaddr   (wdt_lite_awaddr),
        .m_awprot   (wdt_lite_awprot),
        .m_awvalid  (wdt_lite_awvalid),
        .m_awready  (wdt_lite_awready),
        .m_wdata    (wdt_lite_wdata),
        .m_wstrb    (wdt_lite_wstrb),
        .m_wvalid   (wdt_lite_wvalid),
        .m_wready   (wdt_lite_wready),
        .m_bresp    (wdt_lite_bresp),
        .m_bvalid   (wdt_lite_bvalid),
        .m_bready   (wdt_lite_bready),
        .m_araddr   (wdt_lite_araddr),
        .m_arprot   (wdt_lite_arprot),
        .m_arvalid  (wdt_lite_arvalid),
        .m_arready  (wdt_lite_arready),
        .m_rdata    (wdt_lite_rdata),
        .m_rresp    (wdt_lite_rresp),
        .m_rvalid   (wdt_lite_rvalid),
        .m_rready   (wdt_lite_rready)
    );

    wdt_axi #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (12)
    ) u_wdt (
        .aclk        (clk),
        .aresetn     (aresetn),

        .s_axi_awaddr  (wdt_lite_awaddr[11:0]),
        .s_axi_awvalid (wdt_lite_awvalid),
        .s_axi_awready (wdt_lite_awready),

        .s_axi_wdata   (wdt_lite_wdata),
        .s_axi_wstrb   (wdt_lite_wstrb),
        .s_axi_wvalid  (wdt_lite_wvalid),
        .s_axi_wready  (wdt_lite_wready),

        .s_axi_bresp   (wdt_lite_bresp),
        .s_axi_bvalid  (wdt_lite_bvalid),
        .s_axi_bready  (wdt_lite_bready),

        .s_axi_araddr  (wdt_lite_araddr[11:0]),
        .s_axi_arvalid (wdt_lite_arvalid),
        .s_axi_arready (wdt_lite_arready),

        .s_axi_rdata   (wdt_lite_rdata),
        .s_axi_rresp   (wdt_lite_rresp),
        .s_axi_rvalid  (wdt_lite_rvalid),
        .s_axi_rready  (wdt_lite_rready),

        .wdt_irq     (wdt_irq),
        .wdt_reset_n (wdt_reset_n)
    );

    // ------------------------------------------------------------------------
    // M08: Interrupt Aggregator (0x1000_8000)
    // ------------------------------------------------------------------------
    wire [ADDR_WIDTH-1:0] intc_lite_awaddr, intc_lite_araddr;
    wire [2:0] intc_lite_awprot, intc_lite_arprot;
    wire intc_lite_awvalid, intc_lite_awready, intc_lite_wvalid, intc_lite_wready;
    wire [DATA_WIDTH-1:0] intc_lite_wdata, intc_lite_rdata;
    wire [(DATA_WIDTH/8)-1:0] intc_lite_wstrb;
    wire [1:0] intc_lite_bresp, intc_lite_rresp;
    wire intc_lite_bvalid, intc_lite_bready, intc_lite_arvalid, intc_lite_arready, intc_lite_rvalid, intc_lite_rready;

    axi4_to_axi4lite_bridge #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .ID_WIDTH   (ID_WIDTH)
    ) u_bridge_intc (
        .aclk       (clk),
        .aresetn    (aresetn),

        .s_awid     (m08_axi_awid),
        .s_awaddr   (m08_axi_awaddr),
        .s_awlen    (m08_axi_awlen),
        .s_awsize   (m08_axi_awsize),
        .s_awburst  (m08_axi_awburst),
        .s_awlock   (m08_axi_awlock),
        .s_awcache  (m08_axi_awcache),
        .s_awprot   (m08_axi_awprot),
        .s_awqos    (m08_axi_awqos),
        .s_awregion (m08_axi_awregion),
        .s_awuser   (1'b0),
        .s_awvalid  (m08_axi_awvalid),
        .s_awready  (m08_axi_awready),

        .s_wdata    (m08_axi_wdata),
        .s_wstrb    (m08_axi_wstrb),
        .s_wlast    (m08_axi_wlast),
        .s_wuser    (1'b0),
        .s_wvalid   (m08_axi_wvalid),
        .s_wready   (m08_axi_wready),

        .s_bid      (m08_axi_bid),
        .s_bresp    (m08_axi_bresp),
        .s_buser    (),
        .s_bvalid   (m08_axi_bvalid),
        .s_bready   (m08_axi_bready),

        .s_arid     (m08_axi_arid),
        .s_araddr   (m08_axi_araddr),
        .s_arlen    (m08_axi_arlen),
        .s_arsize   (m08_axi_arsize),
        .s_arburst  (m08_axi_arburst),
        .s_arlock   (m08_axi_arlock),
        .s_arcache  (m08_axi_arcache),
        .s_arprot   (m08_axi_arprot),
        .s_arqos    (m08_axi_arqos),
        .s_arregion (m08_axi_arregion),
        .s_aruser   (1'b0),
        .s_arvalid  (m08_axi_arvalid),
        .s_arready  (m08_axi_arready),

        .s_rid      (m08_axi_rid),
        .s_rdata    (m08_axi_rdata),
        .s_rresp    (m08_axi_rresp),
        .s_rlast    (m08_axi_rlast),
        .s_ruser    (),
        .s_rvalid   (m08_axi_rvalid),
        .s_rready   (m08_axi_rready),

        .m_awaddr   (intc_lite_awaddr),
        .m_awprot   (intc_lite_awprot),
        .m_awvalid  (intc_lite_awvalid),
        .m_awready  (intc_lite_awready),
        .m_wdata    (intc_lite_wdata),
        .m_wstrb    (intc_lite_wstrb),
        .m_wvalid   (intc_lite_wvalid),
        .m_wready   (intc_lite_wready),
        .m_bresp    (intc_lite_bresp),
        .m_bvalid   (intc_lite_bvalid),
        .m_bready   (intc_lite_bready),
        .m_araddr   (intc_lite_araddr),
        .m_arprot   (intc_lite_arprot),
        .m_arvalid  (intc_lite_arvalid),
        .m_arready  (intc_lite_arready),
        .m_rdata    (intc_lite_rdata),
        .m_rresp    (intc_lite_rresp),
        .m_rvalid   (intc_lite_rvalid),
        .m_rready   (intc_lite_rready)
    );

    wire [6:0] raw_periph_irqs = {
        wdt_irq,         // bit 6
        aes_done_irq,    // bit 5
        qrs_peak_irq,    // bit 4
        adc_irq_sample,  // bit 3
        gpio_irq,        // bit 2
        timer_irq,       // bit 1
        uart_irq         // bit 0
    };

    interrupt_aggregator #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (12),
        .NUM_IRQS   (7)
    ) u_intc (
        .aclk        (clk),
        .aresetn     (aresetn),

        .s_axi_awaddr  (intc_lite_awaddr[11:0]),
        .s_axi_awvalid (intc_lite_awvalid),
        .s_axi_awready (intc_lite_awready),

        .s_axi_wdata   (intc_lite_wdata),
        .s_axi_wstrb   (intc_lite_wstrb),
        .s_axi_wvalid  (intc_lite_wvalid),
        .s_axi_wready  (intc_lite_wready),

        .s_axi_bresp   (intc_lite_bresp),
        .s_axi_bvalid  (intc_lite_bvalid),
        .s_axi_bready  (intc_lite_bready),

        .s_axi_araddr  (intc_lite_araddr[11:0]),
        .s_axi_arvalid (intc_lite_arvalid),
        .s_axi_arready (intc_lite_arready),

        .s_axi_rdata   (intc_lite_rdata),
        .s_axi_rresp   (intc_lite_rresp),
        .s_axi_rvalid  (intc_lite_rvalid),
        .s_axi_rready  (intc_lite_rready),

        .raw_irqs    (raw_periph_irqs),
        .core_irq    (core_irq_out)
    );

    // ------------------------------------------------------------------------
    // M09: Instruction Memory (IMEM) (0x0000_0000)
    // ------------------------------------------------------------------------
    axi_imem_slave #(
        .AXI_ID_WIDTH   (ID_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH),
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .MEM_SIZE_BYTES (65536),
        .BASE_ADDR      (32'h0000_0000)
    ) u_imem (
        .aclk        (clk),
        .aresetn     (aresetn),

        .s_awid      (m09_axi_awid),
        .s_awaddr    (m09_axi_awaddr),
        .s_awlen     (m09_axi_awlen),
        .s_awsize    (m09_axi_awsize),
        .s_awburst   (m09_axi_awburst),
        .s_awlock    (m09_axi_awlock),
        .s_awcache   (m09_axi_awcache),
        .s_awprot    (m09_axi_awprot),
        .s_awvalid   (m09_axi_awvalid),
        .s_awready   (m09_axi_awready),

        .s_wdata     (m09_axi_wdata),
        .s_wstrb     (m09_axi_wstrb),
        .s_wlast     (m09_axi_wlast),
        .s_wvalid    (m09_axi_wvalid),
        .s_wready    (m09_axi_wready),

        .s_bid       (m09_axi_bid),
        .s_bresp     (m09_axi_bresp),
        .s_bvalid    (m09_axi_bvalid),
        .s_bready    (m09_axi_bready),

        .s_arid      (m09_axi_arid),
        .s_araddr    (m09_axi_araddr),
        .s_arlen     (m09_axi_arlen),
        .s_arsize    (m09_axi_arsize),
        .s_arburst   (m09_axi_arburst),
        .s_arlock    (m09_axi_arlock),
        .s_arcache   (m09_axi_arcache),
        .s_arprot    (m09_axi_arprot),
        .s_arvalid   (m09_axi_arvalid),
        .s_arready   (m09_axi_arready),

        .s_rid       (m09_axi_rid),
        .s_rdata     (m09_axi_rdata),
        .s_rresp     (m09_axi_rresp),
        .s_rlast     (m09_axi_rlast),
        .s_rvalid    (m09_axi_rvalid),
        .s_rready    (m09_axi_rready)
    );

    // ------------------------------------------------------------------------
    // M10: Data Memory (DMEM) (0x0001_0000)
    // ------------------------------------------------------------------------
    axi_dmem_slave #(
        .AXI_ID_WIDTH   (ID_WIDTH),
        .AXI_DATA_WIDTH (DATA_WIDTH),
        .AXI_ADDR_WIDTH (ADDR_WIDTH),
        .MEM_SIZE_BYTES (65536),
        .BASE_ADDR      (32'h0001_0000)
    ) u_dmem (
        .aclk        (clk),
        .aresetn     (aresetn),

        .s_awid      (m10_axi_awid),
        .s_awaddr    (m10_axi_awaddr),
        .s_awlen     (m10_axi_awlen),
        .s_awsize    (m10_axi_awsize),
        .s_awburst   (m10_axi_awburst),
        .s_awlock    (m10_axi_awlock),
        .s_awcache   (m10_axi_awcache),
        .s_awprot    (m10_axi_awprot),
        .s_awvalid   (m10_axi_awvalid),
        .s_awready   (m10_axi_awready),

        .s_wdata     (m10_axi_wdata),
        .s_wstrb     (m10_axi_wstrb),
        .s_wlast     (m10_axi_wlast),
        .s_wvalid    (m10_axi_wvalid),
        .s_wready    (m10_axi_wready),

        .s_bid       (m10_axi_bid),
        .s_bresp     (m10_axi_bresp),
        .s_bvalid    (m10_axi_bvalid),
        .s_bready    (m10_axi_bready),

        .s_arid      (m10_axi_arid),
        .s_araddr    (m10_axi_araddr),
        .s_arlen     (m10_axi_arlen),
        .s_arsize    (m10_axi_arsize),
        .s_arburst   (m10_axi_arburst),
        .s_arlock    (m10_axi_arlock),
        .s_arcache   (m10_axi_arcache),
        .s_arprot    (m10_axi_arprot),
        .s_arvalid   (m10_axi_arvalid),
        .s_arready   (m10_axi_arready),

        .s_rid       (m10_axi_rid),
        .s_rdata     (m10_axi_rdata),
        .s_rresp     (m10_axi_rresp),
        .s_rlast     (m10_axi_rlast),
        .s_rvalid    (m10_axi_rvalid),
        .s_rready    (m10_axi_rready)
    );

endmodule
