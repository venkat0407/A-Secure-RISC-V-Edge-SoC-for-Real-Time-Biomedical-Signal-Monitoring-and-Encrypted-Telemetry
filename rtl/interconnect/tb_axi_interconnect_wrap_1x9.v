/*
 * Testbench: tb_axi_interconnect_wrap_1x9.v
 *
 * DUT  : axi_interconnect_wrap_1x9  (1 slave port -> 9 master ports)
 * Tests: Basic single-beat AXI4 WRITE and READ to every master port (m00-m08)
 *
 * Address map (M_ADDR_WIDTH = 24 bits, auto-calculated by calcBaseAddrs):
 *   M00 : 0x0000_0000 – 0x00FF_FFFF
 *   M01 : 0x0100_0000 – 0x01FF_FFFF
 *   M02 : 0x0200_0000 – 0x02FF_FFFF
 *   M03 : 0x0300_0000 – 0x03FF_FFFF
 *   M04 : 0x0400_0000 – 0x04FF_FFFF
 *   M05 : 0x0500_0000 – 0x05FF_FFFF
 *   M06 : 0x0600_0000 – 0x06FF_FFFF
 *   M07 : 0x0700_0000 – 0x07FF_FFFF
 *   M08 : 0x0800_0000 – 0x08FF_FFFF
 *
 * Each slave memory model is a simple 256-word (word = 32-bit) SRAM that
 * accepts one transaction at a time (no out-of-order).
 *
 * Simulation end condition: all 9 write + 9 read tests pass -> $finish
 */

`timescale 1ns / 1ps

module tb_axi_interconnect_wrap_1x9;

// -----------------------------------------------------------------------
// Parameters
// -----------------------------------------------------------------------




parameter DATA_WIDTH  = 32;
parameter ADDR_WIDTH  = 32;
parameter STRB_WIDTH  = DATA_WIDTH / 8;   // 4
parameter ID_WIDTH    = 8;
parameter CLK_PERIOD  = 10;               // 10 ns  -> 100 MHz

// Address base for each master (matches calcBaseAddrs with 24-bit regions)
parameter [ADDR_WIDTH-1:0] BASE_M00 = 32'h0000_0000;
parameter [ADDR_WIDTH-1:0] BASE_M01 = 32'h0100_0000;
parameter [ADDR_WIDTH-1:0] BASE_M02 = 32'h0200_0000;
parameter [ADDR_WIDTH-1:0] BASE_M03 = 32'h0300_0000;
parameter [ADDR_WIDTH-1:0] BASE_M04 = 32'h0400_0000;
parameter [ADDR_WIDTH-1:0] BASE_M05 = 32'h0500_0000;
parameter [ADDR_WIDTH-1:0] BASE_M06 = 32'h0600_0000;
parameter [ADDR_WIDTH-1:0] BASE_M07 = 32'h0700_0000;
parameter [ADDR_WIDTH-1:0] BASE_M08 = 32'h0800_0000;

// -----------------------------------------------------------------------
// Clock / Reset
// -----------------------------------------------------------------------
reg clk = 0;
reg rst = 1;

always #(CLK_PERIOD/2) clk = ~clk;

// -----------------------------------------------------------------------
// AXI Slave (s00) driven by testbench
// -----------------------------------------------------------------------
// Write Address Channel
reg  [ID_WIDTH-1:0]   s00_axi_awid    = 0;
reg  [ADDR_WIDTH-1:0] s00_axi_awaddr  = 0;
reg  [7:0]            s00_axi_awlen   = 0;   // 0 = 1 beat
reg  [2:0]            s00_axi_awsize  = 3'd2; // 4 bytes
reg  [1:0]            s00_axi_awburst = 2'd1; // INCR
reg                   s00_axi_awlock  = 0;
reg  [3:0]            s00_axi_awcache = 0;
reg  [2:0]            s00_axi_awprot  = 0;
reg  [3:0]            s00_axi_awqos   = 0;
reg                   s00_axi_awvalid = 0;
wire                  s00_axi_awready;

// Write Data Channel
reg  [DATA_WIDTH-1:0] s00_axi_wdata  = 0;
reg  [STRB_WIDTH-1:0] s00_axi_wstrb  = 4'hF;
reg                   s00_axi_wlast  = 1;
reg                   s00_axi_wvalid = 0;
wire                  s00_axi_wready;

// Write Response Channel
wire [ID_WIDTH-1:0]   s00_axi_bid;
wire [1:0]            s00_axi_bresp;
wire                  s00_axi_bvalid;
reg                   s00_axi_bready = 0;

// Read Address Channel
reg  [ID_WIDTH-1:0]   s00_axi_arid    = 0;
reg  [ADDR_WIDTH-1:0] s00_axi_araddr  = 0;
reg  [7:0]            s00_axi_arlen   = 0;
reg  [2:0]            s00_axi_arsize  = 3'd2;
reg  [1:0]            s00_axi_arburst = 2'd1;
reg                   s00_axi_arlock  = 0;
reg  [3:0]            s00_axi_arcache = 0;
reg  [2:0]            s00_axi_arprot  = 0;
reg  [3:0]            s00_axi_arqos   = 0;
reg                   s00_axi_arvalid = 0;
wire                  s00_axi_arready;

// Read Data Channel
wire [ID_WIDTH-1:0]   s00_axi_rid;
wire [DATA_WIDTH-1:0] s00_axi_rdata;
wire [1:0]            s00_axi_rresp;
wire                  s00_axi_rlast;
wire                  s00_axi_rvalid;
reg                   s00_axi_rready = 0;

// Unused user signals (tied off)
wire [0:0]            s00_axi_awuser = 1'b0;
wire [0:0]            s00_axi_wuser  = 1'b0;
wire [0:0]            s00_axi_buser;
wire [0:0]            s00_axi_aruser = 1'b0;
wire [0:0]            s00_axi_ruser;

// -----------------------------------------------------------------------
// AXI Master wires (m00-m08) — connected to slave memory models
// -----------------------------------------------------------------------

// Helper macro-style: declare all master wires via generate would need
// per-port naming, so we declare them explicitly.

// --- m00 ---
wire [ID_WIDTH-1:0]   m00_axi_awid;
wire [ADDR_WIDTH-1:0] m00_axi_awaddr;
wire [7:0]            m00_axi_awlen;
wire [2:0]            m00_axi_awsize;
wire [1:0]            m00_axi_awburst;
wire                  m00_axi_awlock;
wire [3:0]            m00_axi_awcache;
wire [2:0]            m00_axi_awprot;
wire [3:0]            m00_axi_awqos;
wire [3:0]            m00_axi_awregion;
wire [0:0]            m00_axi_awuser;
wire                  m00_axi_awvalid;
wire                  m00_axi_awready;
wire [DATA_WIDTH-1:0] m00_axi_wdata;
wire [STRB_WIDTH-1:0] m00_axi_wstrb;
wire                  m00_axi_wlast;
wire [0:0]            m00_axi_wuser;
wire                  m00_axi_wvalid;
wire                  m00_axi_wready;
wire [ID_WIDTH-1:0]   m00_axi_bid;
wire [1:0]            m00_axi_bresp;
wire [0:0]            m00_axi_buser;
wire                  m00_axi_bvalid;
wire                  m00_axi_bready;
wire [ID_WIDTH-1:0]   m00_axi_arid;
wire [ADDR_WIDTH-1:0] m00_axi_araddr;
wire [7:0]            m00_axi_arlen;
wire [2:0]            m00_axi_arsize;
wire [1:0]            m00_axi_arburst;
wire                  m00_axi_arlock;
wire [3:0]            m00_axi_arcache;
wire [2:0]            m00_axi_arprot;
wire [3:0]            m00_axi_arqos;
wire [3:0]            m00_axi_arregion;
wire [0:0]            m00_axi_aruser;
wire                  m00_axi_arvalid;
wire                  m00_axi_arready;
wire [ID_WIDTH-1:0]   m00_axi_rid;
wire [DATA_WIDTH-1:0] m00_axi_rdata;
wire [1:0]            m00_axi_rresp;
wire                  m00_axi_rlast;
wire [0:0]            m00_axi_ruser;
wire                  m00_axi_rvalid;
wire                  m00_axi_rready;

// --- m01 ---
wire [ID_WIDTH-1:0]   m01_axi_awid;
wire [ADDR_WIDTH-1:0] m01_axi_awaddr;
wire [7:0]            m01_axi_awlen;
wire [2:0]            m01_axi_awsize;
wire [1:0]            m01_axi_awburst;
wire                  m01_axi_awlock;
wire [3:0]            m01_axi_awcache;
wire [2:0]            m01_axi_awprot;
wire [3:0]            m01_axi_awqos;
wire [3:0]            m01_axi_awregion;
wire [0:0]            m01_axi_awuser;
wire                  m01_axi_awvalid;
wire                  m01_axi_awready;
wire [DATA_WIDTH-1:0] m01_axi_wdata;
wire [STRB_WIDTH-1:0] m01_axi_wstrb;
wire                  m01_axi_wlast;
wire [0:0]            m01_axi_wuser;
wire                  m01_axi_wvalid;
wire                  m01_axi_wready;
wire [ID_WIDTH-1:0]   m01_axi_bid;
wire [1:0]            m01_axi_bresp;
wire [0:0]            m01_axi_buser;
wire                  m01_axi_bvalid;
wire                  m01_axi_bready;
wire [ID_WIDTH-1:0]   m01_axi_arid;
wire [ADDR_WIDTH-1:0] m01_axi_araddr;
wire [7:0]            m01_axi_arlen;
wire [2:0]            m01_axi_arsize;
wire [1:0]            m01_axi_arburst;
wire                  m01_axi_arlock;
wire [3:0]            m01_axi_arcache;
wire [2:0]            m01_axi_arprot;
wire [3:0]            m01_axi_arqos;
wire [3:0]            m01_axi_arregion;
wire [0:0]            m01_axi_aruser;
wire                  m01_axi_arvalid;
wire                  m01_axi_arready;
wire [ID_WIDTH-1:0]   m01_axi_rid;
wire [DATA_WIDTH-1:0] m01_axi_rdata;
wire [1:0]            m01_axi_rresp;
wire                  m01_axi_rlast;
wire [0:0]            m01_axi_ruser;
wire                  m01_axi_rvalid;
wire                  m01_axi_rready;

// --- m02 ---
wire [ID_WIDTH-1:0]   m02_axi_awid;
wire [ADDR_WIDTH-1:0] m02_axi_awaddr;
wire [7:0]            m02_axi_awlen;
wire [2:0]            m02_axi_awsize;
wire [1:0]            m02_axi_awburst;
wire                  m02_axi_awlock;
wire [3:0]            m02_axi_awcache;
wire [2:0]            m02_axi_awprot;
wire [3:0]            m02_axi_awqos;
wire [3:0]            m02_axi_awregion;
wire [0:0]            m02_axi_awuser;
wire                  m02_axi_awvalid;
wire                  m02_axi_awready;
wire [DATA_WIDTH-1:0] m02_axi_wdata;
wire [STRB_WIDTH-1:0] m02_axi_wstrb;
wire                  m02_axi_wlast;
wire [0:0]            m02_axi_wuser;
wire                  m02_axi_wvalid;
wire                  m02_axi_wready;
wire [ID_WIDTH-1:0]   m02_axi_bid;
wire [1:0]            m02_axi_bresp;
wire [0:0]            m02_axi_buser;
wire                  m02_axi_bvalid;
wire                  m02_axi_bready;
wire [ID_WIDTH-1:0]   m02_axi_arid;
wire [ADDR_WIDTH-1:0] m02_axi_araddr;
wire [7:0]            m02_axi_arlen;
wire [2:0]            m02_axi_arsize;
wire [1:0]            m02_axi_arburst;
wire                  m02_axi_arlock;
wire [3:0]            m02_axi_arcache;
wire [2:0]            m02_axi_arprot;
wire [3:0]            m02_axi_arqos;
wire [3:0]            m02_axi_arregion;
wire [0:0]            m02_axi_aruser;
wire                  m02_axi_arvalid;
wire                  m02_axi_arready;
wire [ID_WIDTH-1:0]   m02_axi_rid;
wire [DATA_WIDTH-1:0] m02_axi_rdata;
wire [1:0]            m02_axi_rresp;
wire                  m02_axi_rlast;
wire [0:0]            m02_axi_ruser;
wire                  m02_axi_rvalid;
wire                  m02_axi_rready;

// --- m03 ---
wire [ID_WIDTH-1:0]   m03_axi_awid;
wire [ADDR_WIDTH-1:0] m03_axi_awaddr;
wire [7:0]            m03_axi_awlen;
wire [2:0]            m03_axi_awsize;
wire [1:0]            m03_axi_awburst;
wire                  m03_axi_awlock;
wire [3:0]            m03_axi_awcache;
wire [2:0]            m03_axi_awprot;
wire [3:0]            m03_axi_awqos;
wire [3:0]            m03_axi_awregion;
wire [0:0]            m03_axi_awuser;
wire                  m03_axi_awvalid;
wire                  m03_axi_awready;
wire [DATA_WIDTH-1:0] m03_axi_wdata;
wire [STRB_WIDTH-1:0] m03_axi_wstrb;
wire                  m03_axi_wlast;
wire [0:0]            m03_axi_wuser;
wire                  m03_axi_wvalid;
wire                  m03_axi_wready;
wire [ID_WIDTH-1:0]   m03_axi_bid;
wire [1:0]            m03_axi_bresp;
wire [0:0]            m03_axi_buser;
wire                  m03_axi_bvalid;
wire                  m03_axi_bready;
wire [ID_WIDTH-1:0]   m03_axi_arid;
wire [ADDR_WIDTH-1:0] m03_axi_araddr;
wire [7:0]            m03_axi_arlen;
wire [2:0]            m03_axi_arsize;
wire [1:0]            m03_axi_arburst;
wire                  m03_axi_arlock;
wire [3:0]            m03_axi_arcache;
wire [2:0]            m03_axi_arprot;
wire [3:0]            m03_axi_arqos;
wire [3:0]            m03_axi_arregion;
wire [0:0]            m03_axi_aruser;
wire                  m03_axi_arvalid;
wire                  m03_axi_arready;
wire [ID_WIDTH-1:0]   m03_axi_rid;
wire [DATA_WIDTH-1:0] m03_axi_rdata;
wire [1:0]            m03_axi_rresp;
wire                  m03_axi_rlast;
wire [0:0]            m03_axi_ruser;
wire                  m03_axi_rvalid;
wire                  m03_axi_rready;

// --- m04 ---
wire [ID_WIDTH-1:0]   m04_axi_awid;
wire [ADDR_WIDTH-1:0] m04_axi_awaddr;
wire [7:0]            m04_axi_awlen;
wire [2:0]            m04_axi_awsize;
wire [1:0]            m04_axi_awburst;
wire                  m04_axi_awlock;
wire [3:0]            m04_axi_awcache;
wire [2:0]            m04_axi_awprot;
wire [3:0]            m04_axi_awqos;
wire [3:0]            m04_axi_awregion;
wire [0:0]            m04_axi_awuser;
wire                  m04_axi_awvalid;
wire                  m04_axi_awready;
wire [DATA_WIDTH-1:0] m04_axi_wdata;
wire [STRB_WIDTH-1:0] m04_axi_wstrb;
wire                  m04_axi_wlast;
wire [0:0]            m04_axi_wuser;
wire                  m04_axi_wvalid;
wire                  m04_axi_wready;
wire [ID_WIDTH-1:0]   m04_axi_bid;
wire [1:0]            m04_axi_bresp;
wire [0:0]            m04_axi_buser;
wire                  m04_axi_bvalid;
wire                  m04_axi_bready;
wire [ID_WIDTH-1:0]   m04_axi_arid;
wire [ADDR_WIDTH-1:0] m04_axi_araddr;
wire [7:0]            m04_axi_arlen;
wire [2:0]            m04_axi_arsize;
wire [1:0]            m04_axi_arburst;
wire                  m04_axi_arlock;
wire [3:0]            m04_axi_arcache;
wire [2:0]            m04_axi_arprot;
wire [3:0]            m04_axi_arqos;
wire [3:0]            m04_axi_arregion;
wire [0:0]            m04_axi_aruser;
wire                  m04_axi_arvalid;
wire                  m04_axi_arready;
wire [ID_WIDTH-1:0]   m04_axi_rid;
wire [DATA_WIDTH-1:0] m04_axi_rdata;
wire [1:0]            m04_axi_rresp;
wire                  m04_axi_rlast;
wire [0:0]            m04_axi_ruser;
wire                  m04_axi_rvalid;
wire                  m04_axi_rready;

// --- m05 ---
wire [ID_WIDTH-1:0]   m05_axi_awid;
wire [ADDR_WIDTH-1:0] m05_axi_awaddr;
wire [7:0]            m05_axi_awlen;
wire [2:0]            m05_axi_awsize;
wire [1:0]            m05_axi_awburst;
wire                  m05_axi_awlock;
wire [3:0]            m05_axi_awcache;
wire [2:0]            m05_axi_awprot;
wire [3:0]            m05_axi_awqos;
wire [3:0]            m05_axi_awregion;
wire [0:0]            m05_axi_awuser;
wire                  m05_axi_awvalid;
wire                  m05_axi_awready;
wire [DATA_WIDTH-1:0] m05_axi_wdata;
wire [STRB_WIDTH-1:0] m05_axi_wstrb;
wire                  m05_axi_wlast;
wire [0:0]            m05_axi_wuser;
wire                  m05_axi_wvalid;
wire                  m05_axi_wready;
wire [ID_WIDTH-1:0]   m05_axi_bid;
wire [1:0]            m05_axi_bresp;
wire [0:0]            m05_axi_buser;
wire                  m05_axi_bvalid;
wire                  m05_axi_bready;
wire [ID_WIDTH-1:0]   m05_axi_arid;
wire [ADDR_WIDTH-1:0] m05_axi_araddr;
wire [7:0]            m05_axi_arlen;
wire [2:0]            m05_axi_arsize;
wire [1:0]            m05_axi_arburst;
wire                  m05_axi_arlock;
wire [3:0]            m05_axi_arcache;
wire [2:0]            m05_axi_arprot;
wire [3:0]            m05_axi_arqos;
wire [3:0]            m05_axi_arregion;
wire [0:0]            m05_axi_aruser;
wire                  m05_axi_arvalid;
wire                  m05_axi_arready;
wire [ID_WIDTH-1:0]   m05_axi_rid;
wire [DATA_WIDTH-1:0] m05_axi_rdata;
wire [1:0]            m05_axi_rresp;
wire                  m05_axi_rlast;
wire [0:0]            m05_axi_ruser;
wire                  m05_axi_rvalid;
wire                  m05_axi_rready;

// --- m06 ---
wire [ID_WIDTH-1:0]   m06_axi_awid;
wire [ADDR_WIDTH-1:0] m06_axi_awaddr;
wire [7:0]            m06_axi_awlen;
wire [2:0]            m06_axi_awsize;
wire [1:0]            m06_axi_awburst;
wire                  m06_axi_awlock;
wire [3:0]            m06_axi_awcache;
wire [2:0]            m06_axi_awprot;
wire [3:0]            m06_axi_awqos;
wire [3:0]            m06_axi_awregion;
wire [0:0]            m06_axi_awuser;
wire                  m06_axi_awvalid;
wire                  m06_axi_awready;
wire [DATA_WIDTH-1:0] m06_axi_wdata;
wire [STRB_WIDTH-1:0] m06_axi_wstrb;
wire                  m06_axi_wlast;
wire [0:0]            m06_axi_wuser;
wire                  m06_axi_wvalid;
wire                  m06_axi_wready;
wire [ID_WIDTH-1:0]   m06_axi_bid;
wire [1:0]            m06_axi_bresp;
wire [0:0]            m06_axi_buser;
wire                  m06_axi_bvalid;
wire                  m06_axi_bready;
wire [ID_WIDTH-1:0]   m06_axi_arid;
wire [ADDR_WIDTH-1:0] m06_axi_araddr;
wire [7:0]            m06_axi_arlen;
wire [2:0]            m06_axi_arsize;
wire [1:0]            m06_axi_arburst;
wire                  m06_axi_arlock;
wire [3:0]            m06_axi_arcache;
wire [2:0]            m06_axi_arprot;
wire [3:0]            m06_axi_arqos;
wire [3:0]            m06_axi_arregion;
wire [0:0]            m06_axi_aruser;
wire                  m06_axi_arvalid;
wire                  m06_axi_arready;
wire [ID_WIDTH-1:0]   m06_axi_rid;
wire [DATA_WIDTH-1:0] m06_axi_rdata;
wire [1:0]            m06_axi_rresp;
wire                  m06_axi_rlast;
wire [0:0]            m06_axi_ruser;
wire                  m06_axi_rvalid;
wire                  m06_axi_rready;

// --- m07 ---
wire [ID_WIDTH-1:0]   m07_axi_awid;
wire [ADDR_WIDTH-1:0] m07_axi_awaddr;
wire [7:0]            m07_axi_awlen;
wire [2:0]            m07_axi_awsize;
wire [1:0]            m07_axi_awburst;
wire                  m07_axi_awlock;
wire [3:0]            m07_axi_awcache;
wire [2:0]            m07_axi_awprot;
wire [3:0]            m07_axi_awqos;
wire [3:0]            m07_axi_awregion;
wire [0:0]            m07_axi_awuser;
wire                  m07_axi_awvalid;
wire                  m07_axi_awready;
wire [DATA_WIDTH-1:0] m07_axi_wdata;
wire [STRB_WIDTH-1:0] m07_axi_wstrb;
wire                  m07_axi_wlast;
wire [0:0]            m07_axi_wuser;
wire                  m07_axi_wvalid;
wire                  m07_axi_wready;
wire [ID_WIDTH-1:0]   m07_axi_bid;
wire [1:0]            m07_axi_bresp;
wire [0:0]            m07_axi_buser;
wire                  m07_axi_bvalid;
wire                  m07_axi_bready;
wire [ID_WIDTH-1:0]   m07_axi_arid;
wire [ADDR_WIDTH-1:0] m07_axi_araddr;
wire [7:0]            m07_axi_arlen;
wire [2:0]            m07_axi_arsize;
wire [1:0]            m07_axi_arburst;
wire                  m07_axi_arlock;
wire [3:0]            m07_axi_arcache;
wire [2:0]            m07_axi_arprot;
wire [3:0]            m07_axi_arqos;
wire [3:0]            m07_axi_arregion;
wire [0:0]            m07_axi_aruser;
wire                  m07_axi_arvalid;
wire                  m07_axi_arready;
wire [ID_WIDTH-1:0]   m07_axi_rid;
wire [DATA_WIDTH-1:0] m07_axi_rdata;
wire [1:0]            m07_axi_rresp;
wire                  m07_axi_rlast;
wire [0:0]            m07_axi_ruser;
wire                  m07_axi_rvalid;
wire                  m07_axi_rready;

// --- m08 ---
wire [ID_WIDTH-1:0]   m08_axi_awid;
wire [ADDR_WIDTH-1:0] m08_axi_awaddr;
wire [7:0]            m08_axi_awlen;
wire [2:0]            m08_axi_awsize;
wire [1:0]            m08_axi_awburst;
wire                  m08_axi_awlock;
wire [3:0]            m08_axi_awcache;
wire [2:0]            m08_axi_awprot;
wire [3:0]            m08_axi_awqos;
wire [3:0]            m08_axi_awregion;
wire [0:0]            m08_axi_awuser;
wire                  m08_axi_awvalid;
wire                  m08_axi_awready;
wire [DATA_WIDTH-1:0] m08_axi_wdata;
wire [STRB_WIDTH-1:0] m08_axi_wstrb;
wire                  m08_axi_wlast;
wire [0:0]            m08_axi_wuser;
wire                  m08_axi_wvalid;
wire                  m08_axi_wready;
wire [ID_WIDTH-1:0]   m08_axi_bid;
wire [1:0]            m08_axi_bresp;
wire [0:0]            m08_axi_buser;
wire                  m08_axi_bvalid;
wire                  m08_axi_bready;
wire [ID_WIDTH-1:0]   m08_axi_arid;
wire [ADDR_WIDTH-1:0] m08_axi_araddr;
wire [7:0]            m08_axi_arlen;
wire [2:0]            m08_axi_arsize;
wire [1:0]            m08_axi_arburst;
wire                  m08_axi_arlock;
wire [3:0]            m08_axi_arcache;
wire [2:0]            m08_axi_arprot;
wire [3:0]            m08_axi_arqos;
wire [3:0]            m08_axi_arregion;
wire [0:0]            m08_axi_aruser;
wire                  m08_axi_arvalid;
wire                  m08_axi_arready;
wire [ID_WIDTH-1:0]   m08_axi_rid;
wire [DATA_WIDTH-1:0] m08_axi_rdata;
wire [1:0]            m08_axi_rresp;
wire                  m08_axi_rlast;
wire [0:0]            m08_axi_ruser;
wire                  m08_axi_rvalid;
wire                  m08_axi_rready;

// -----------------------------------------------------------------------
// DUT instantiation
// -----------------------------------------------------------------------
axi_interconnect_wrap_1x9 #(
    .DATA_WIDTH  (DATA_WIDTH),
    .ADDR_WIDTH  (ADDR_WIDTH),
    .STRB_WIDTH  (STRB_WIDTH),
    .ID_WIDTH    (ID_WIDTH),
    // M_BASE_ADDR = 0  -> use calcBaseAddrs (auto, 16MB per master)
    .M00_BASE_ADDR(32'd0),
    .M01_BASE_ADDR(32'd0),
    .M02_BASE_ADDR(32'd0),
    .M03_BASE_ADDR(32'd0),
    .M04_BASE_ADDR(32'd0),
    .M05_BASE_ADDR(32'd0),
    .M06_BASE_ADDR(32'd0),
    .M07_BASE_ADDR(32'd0),
    .M08_BASE_ADDR(32'd0)
) dut (
    .clk(clk),
    .rst(rst),

    // Slave port
    .s00_axi_awid   (s00_axi_awid),
    .s00_axi_awaddr (s00_axi_awaddr),
    .s00_axi_awlen  (s00_axi_awlen),
    .s00_axi_awsize (s00_axi_awsize),
    .s00_axi_awburst(s00_axi_awburst),
    .s00_axi_awlock (s00_axi_awlock),
    .s00_axi_awcache(s00_axi_awcache),
    .s00_axi_awprot (s00_axi_awprot),
    .s00_axi_awqos  (s00_axi_awqos),
    .s00_axi_awuser (s00_axi_awuser),
    .s00_axi_awvalid(s00_axi_awvalid),
    .s00_axi_awready(s00_axi_awready),
    .s00_axi_wdata  (s00_axi_wdata),
    .s00_axi_wstrb  (s00_axi_wstrb),
    .s00_axi_wlast  (s00_axi_wlast),
    .s00_axi_wuser  (s00_axi_wuser),
    .s00_axi_wvalid (s00_axi_wvalid),
    .s00_axi_wready (s00_axi_wready),
    .s00_axi_bid    (s00_axi_bid),
    .s00_axi_bresp  (s00_axi_bresp),
    .s00_axi_buser  (s00_axi_buser),
    .s00_axi_bvalid (s00_axi_bvalid),
    .s00_axi_bready (s00_axi_bready),
    .s00_axi_arid   (s00_axi_arid),
    .s00_axi_araddr (s00_axi_araddr),
    .s00_axi_arlen  (s00_axi_arlen),
    .s00_axi_arsize (s00_axi_arsize),
    .s00_axi_arburst(s00_axi_arburst),
    .s00_axi_arlock (s00_axi_arlock),
    .s00_axi_arcache(s00_axi_arcache),
    .s00_axi_arprot (s00_axi_arprot),
    .s00_axi_arqos  (s00_axi_arqos),
    .s00_axi_aruser (s00_axi_aruser),
    .s00_axi_arvalid(s00_axi_arvalid),
    .s00_axi_arready(s00_axi_arready),
    .s00_axi_rid    (s00_axi_rid),
    .s00_axi_rdata  (s00_axi_rdata),
    .s00_axi_rresp  (s00_axi_rresp),
    .s00_axi_rlast  (s00_axi_rlast),
    .s00_axi_ruser  (s00_axi_ruser),
    .s00_axi_rvalid (s00_axi_rvalid),
    .s00_axi_rready (s00_axi_rready),

    // Master ports
    .m00_axi_awid    (m00_axi_awid),    .m00_axi_awaddr (m00_axi_awaddr),
    .m00_axi_awlen   (m00_axi_awlen),   .m00_axi_awsize (m00_axi_awsize),
    .m00_axi_awburst (m00_axi_awburst), .m00_axi_awlock (m00_axi_awlock),
    .m00_axi_awcache (m00_axi_awcache), .m00_axi_awprot (m00_axi_awprot),
    .m00_axi_awqos   (m00_axi_awqos),   .m00_axi_awregion(m00_axi_awregion),
    .m00_axi_awuser  (m00_axi_awuser),  .m00_axi_awvalid(m00_axi_awvalid),
    .m00_axi_awready (m00_axi_awready), .m00_axi_wdata  (m00_axi_wdata),
    .m00_axi_wstrb   (m00_axi_wstrb),   .m00_axi_wlast  (m00_axi_wlast),
    .m00_axi_wuser   (m00_axi_wuser),   .m00_axi_wvalid (m00_axi_wvalid),
    .m00_axi_wready  (m00_axi_wready),  .m00_axi_bid    (m00_axi_bid),
    .m00_axi_bresp   (m00_axi_bresp),   .m00_axi_buser  (m00_axi_buser),
    .m00_axi_bvalid  (m00_axi_bvalid),  .m00_axi_bready (m00_axi_bready),
    .m00_axi_arid    (m00_axi_arid),    .m00_axi_araddr (m00_axi_araddr),
    .m00_axi_arlen   (m00_axi_arlen),   .m00_axi_arsize (m00_axi_arsize),
    .m00_axi_arburst (m00_axi_arburst), .m00_axi_arlock (m00_axi_arlock),
    .m00_axi_arcache (m00_axi_arcache), .m00_axi_arprot (m00_axi_arprot),
    .m00_axi_arqos   (m00_axi_arqos),   .m00_axi_arregion(m00_axi_arregion),
    .m00_axi_aruser  (m00_axi_aruser),  .m00_axi_arvalid(m00_axi_arvalid),
    .m00_axi_arready (m00_axi_arready), .m00_axi_rid    (m00_axi_rid),
    .m00_axi_rdata   (m00_axi_rdata),   .m00_axi_rresp  (m00_axi_rresp),
    .m00_axi_rlast   (m00_axi_rlast),   .m00_axi_ruser  (m00_axi_ruser),
    .m00_axi_rvalid  (m00_axi_rvalid),  .m00_axi_rready (m00_axi_rready),

    .m01_axi_awid    (m01_axi_awid),    .m01_axi_awaddr (m01_axi_awaddr),
    .m01_axi_awlen   (m01_axi_awlen),   .m01_axi_awsize (m01_axi_awsize),
    .m01_axi_awburst (m01_axi_awburst), .m01_axi_awlock (m01_axi_awlock),
    .m01_axi_awcache (m01_axi_awcache), .m01_axi_awprot (m01_axi_awprot),
    .m01_axi_awqos   (m01_axi_awqos),   .m01_axi_awregion(m01_axi_awregion),
    .m01_axi_awuser  (m01_axi_awuser),  .m01_axi_awvalid(m01_axi_awvalid),
    .m01_axi_awready (m01_axi_awready), .m01_axi_wdata  (m01_axi_wdata),
    .m01_axi_wstrb   (m01_axi_wstrb),   .m01_axi_wlast  (m01_axi_wlast),
    .m01_axi_wuser   (m01_axi_wuser),   .m01_axi_wvalid (m01_axi_wvalid),
    .m01_axi_wready  (m01_axi_wready),  .m01_axi_bid    (m01_axi_bid),
    .m01_axi_bresp   (m01_axi_bresp),   .m01_axi_buser  (m01_axi_buser),
    .m01_axi_bvalid  (m01_axi_bvalid),  .m01_axi_bready (m01_axi_bready),
    .m01_axi_arid    (m01_axi_arid),    .m01_axi_araddr (m01_axi_araddr),
    .m01_axi_arlen   (m01_axi_arlen),   .m01_axi_arsize (m01_axi_arsize),
    .m01_axi_arburst (m01_axi_arburst), .m01_axi_arlock (m01_axi_arlock),
    .m01_axi_arcache (m01_axi_arcache), .m01_axi_arprot (m01_axi_arprot),
    .m01_axi_arqos   (m01_axi_arqos),   .m01_axi_arregion(m01_axi_arregion),
    .m01_axi_aruser  (m01_axi_aruser),  .m01_axi_arvalid(m01_axi_arvalid),
    .m01_axi_arready (m01_axi_arready), .m01_axi_rid    (m01_axi_rid),
    .m01_axi_rdata   (m01_axi_rdata),   .m01_axi_rresp  (m01_axi_rresp),
    .m01_axi_rlast   (m01_axi_rlast),   .m01_axi_ruser  (m01_axi_ruser),
    .m01_axi_rvalid  (m01_axi_rvalid),  .m01_axi_rready (m01_axi_rready),

    .m02_axi_awid    (m02_axi_awid),    .m02_axi_awaddr (m02_axi_awaddr),
    .m02_axi_awlen   (m02_axi_awlen),   .m02_axi_awsize (m02_axi_awsize),
    .m02_axi_awburst (m02_axi_awburst), .m02_axi_awlock (m02_axi_awlock),
    .m02_axi_awcache (m02_axi_awcache), .m02_axi_awprot (m02_axi_awprot),
    .m02_axi_awqos   (m02_axi_awqos),   .m02_axi_awregion(m02_axi_awregion),
    .m02_axi_awuser  (m02_axi_awuser),  .m02_axi_awvalid(m02_axi_awvalid),
    .m02_axi_awready (m02_axi_awready), .m02_axi_wdata  (m02_axi_wdata),
    .m02_axi_wstrb   (m02_axi_wstrb),   .m02_axi_wlast  (m02_axi_wlast),
    .m02_axi_wuser   (m02_axi_wuser),   .m02_axi_wvalid (m02_axi_wvalid),
    .m02_axi_wready  (m02_axi_wready),  .m02_axi_bid    (m02_axi_bid),
    .m02_axi_bresp   (m02_axi_bresp),   .m02_axi_buser  (m02_axi_buser),
    .m02_axi_bvalid  (m02_axi_bvalid),  .m02_axi_bready (m02_axi_bready),
    .m02_axi_arid    (m02_axi_arid),    .m02_axi_araddr (m02_axi_araddr),
    .m02_axi_arlen   (m02_axi_arlen),   .m02_axi_arsize (m02_axi_arsize),
    .m02_axi_arburst (m02_axi_arburst), .m02_axi_arlock (m02_axi_arlock),
    .m02_axi_arcache (m02_axi_arcache), .m02_axi_arprot (m02_axi_arprot),
    .m02_axi_arqos   (m02_axi_arqos),   .m02_axi_arregion(m02_axi_arregion),
    .m02_axi_aruser  (m02_axi_aruser),  .m02_axi_arvalid(m02_axi_arvalid),
    .m02_axi_arready (m02_axi_arready), .m02_axi_rid    (m02_axi_rid),
    .m02_axi_rdata   (m02_axi_rdata),   .m02_axi_rresp  (m02_axi_rresp),
    .m02_axi_rlast   (m02_axi_rlast),   .m02_axi_ruser  (m02_axi_ruser),
    .m02_axi_rvalid  (m02_axi_rvalid),  .m02_axi_rready (m02_axi_rready),

    .m03_axi_awid    (m03_axi_awid),    .m03_axi_awaddr (m03_axi_awaddr),
    .m03_axi_awlen   (m03_axi_awlen),   .m03_axi_awsize (m03_axi_awsize),
    .m03_axi_awburst (m03_axi_awburst), .m03_axi_awlock (m03_axi_awlock),
    .m03_axi_awcache (m03_axi_awcache), .m03_axi_awprot (m03_axi_awprot),
    .m03_axi_awqos   (m03_axi_awqos),   .m03_axi_awregion(m03_axi_awregion),
    .m03_axi_awuser  (m03_axi_awuser),  .m03_axi_awvalid(m03_axi_awvalid),
    .m03_axi_awready (m03_axi_awready), .m03_axi_wdata  (m03_axi_wdata),
    .m03_axi_wstrb   (m03_axi_wstrb),   .m03_axi_wlast  (m03_axi_wlast),
    .m03_axi_wuser   (m03_axi_wuser),   .m03_axi_wvalid (m03_axi_wvalid),
    .m03_axi_wready  (m03_axi_wready),  .m03_axi_bid    (m03_axi_bid),
    .m03_axi_bresp   (m03_axi_bresp),   .m03_axi_buser  (m03_axi_buser),
    .m03_axi_bvalid  (m03_axi_bvalid),  .m03_axi_bready (m03_axi_bready),
    .m03_axi_arid    (m03_axi_arid),    .m03_axi_araddr (m03_axi_araddr),
    .m03_axi_arlen   (m03_axi_arlen),   .m03_axi_arsize (m03_axi_arsize),
    .m03_axi_arburst (m03_axi_arburst), .m03_axi_arlock (m03_axi_arlock),
    .m03_axi_arcache (m03_axi_arcache), .m03_axi_arprot (m03_axi_arprot),
    .m03_axi_arqos   (m03_axi_arqos),   .m03_axi_arregion(m03_axi_arregion),
    .m03_axi_aruser  (m03_axi_aruser),  .m03_axi_arvalid(m03_axi_arvalid),
    .m03_axi_arready (m03_axi_arready), .m03_axi_rid    (m03_axi_rid),
    .m03_axi_rdata   (m03_axi_rdata),   .m03_axi_rresp  (m03_axi_rresp),
    .m03_axi_rlast   (m03_axi_rlast),   .m03_axi_ruser  (m03_axi_ruser),
    .m03_axi_rvalid  (m03_axi_rvalid),  .m03_axi_rready (m03_axi_rready),

    .m04_axi_awid    (m04_axi_awid),    .m04_axi_awaddr (m04_axi_awaddr),
    .m04_axi_awlen   (m04_axi_awlen),   .m04_axi_awsize (m04_axi_awsize),
    .m04_axi_awburst (m04_axi_awburst), .m04_axi_awlock (m04_axi_awlock),
    .m04_axi_awcache (m04_axi_awcache), .m04_axi_awprot (m04_axi_awprot),
    .m04_axi_awqos   (m04_axi_awqos),   .m04_axi_awregion(m04_axi_awregion),
    .m04_axi_awuser  (m04_axi_awuser),  .m04_axi_awvalid(m04_axi_awvalid),
    .m04_axi_awready (m04_axi_awready), .m04_axi_wdata  (m04_axi_wdata),
    .m04_axi_wstrb   (m04_axi_wstrb),   .m04_axi_wlast  (m04_axi_wlast),
    .m04_axi_wuser   (m04_axi_wuser),   .m04_axi_wvalid (m04_axi_wvalid),
    .m04_axi_wready  (m04_axi_wready),  .m04_axi_bid    (m04_axi_bid),
    .m04_axi_bresp   (m04_axi_bresp),   .m04_axi_buser  (m04_axi_buser),
    .m04_axi_bvalid  (m04_axi_bvalid),  .m04_axi_bready (m04_axi_bready),
    .m04_axi_arid    (m04_axi_arid),    .m04_axi_araddr (m04_axi_araddr),
    .m04_axi_arlen   (m04_axi_arlen),   .m04_axi_arsize (m04_axi_arsize),
    .m04_axi_arburst (m04_axi_arburst), .m04_axi_arlock (m04_axi_arlock),
    .m04_axi_arcache (m04_axi_arcache), .m04_axi_arprot (m04_axi_arprot),
    .m04_axi_arqos   (m04_axi_arqos),   .m04_axi_arregion(m04_axi_arregion),
    .m04_axi_aruser  (m04_axi_aruser),  .m04_axi_arvalid(m04_axi_arvalid),
    .m04_axi_arready (m04_axi_arready), .m04_axi_rid    (m04_axi_rid),
    .m04_axi_rdata   (m04_axi_rdata),   .m04_axi_rresp  (m04_axi_rresp),
    .m04_axi_rlast   (m04_axi_rlast),   .m04_axi_ruser  (m04_axi_ruser),
    .m04_axi_rvalid  (m04_axi_rvalid),  .m04_axi_rready (m04_axi_rready),

    .m05_axi_awid    (m05_axi_awid),    .m05_axi_awaddr (m05_axi_awaddr),
    .m05_axi_awlen   (m05_axi_awlen),   .m05_axi_awsize (m05_axi_awsize),
    .m05_axi_awburst (m05_axi_awburst), .m05_axi_awlock (m05_axi_awlock),
    .m05_axi_awcache (m05_axi_awcache), .m05_axi_awprot (m05_axi_awprot),
    .m05_axi_awqos   (m05_axi_awqos),   .m05_axi_awregion(m05_axi_awregion),
    .m05_axi_awuser  (m05_axi_awuser),  .m05_axi_awvalid(m05_axi_awvalid),
    .m05_axi_awready (m05_axi_awready), .m05_axi_wdata  (m05_axi_wdata),
    .m05_axi_wstrb   (m05_axi_wstrb),   .m05_axi_wlast  (m05_axi_wlast),
    .m05_axi_wuser   (m05_axi_wuser),   .m05_axi_wvalid (m05_axi_wvalid),
    .m05_axi_wready  (m05_axi_wready),  .m05_axi_bid    (m05_axi_bid),
    .m05_axi_bresp   (m05_axi_bresp),   .m05_axi_buser  (m05_axi_buser),
    .m05_axi_bvalid  (m05_axi_bvalid),  .m05_axi_bready (m05_axi_bready),
    .m05_axi_arid    (m05_axi_arid),    .m05_axi_araddr (m05_axi_araddr),
    .m05_axi_arlen   (m05_axi_arlen),   .m05_axi_arsize (m05_axi_arsize),
    .m05_axi_arburst (m05_axi_arburst), .m05_axi_arlock (m05_axi_arlock),
    .m05_axi_arcache (m05_axi_arcache), .m05_axi_arprot (m05_axi_arprot),
    .m05_axi_arqos   (m05_axi_arqos),   .m05_axi_arregion(m05_axi_arregion),
    .m05_axi_aruser  (m05_axi_aruser),  .m05_axi_arvalid(m05_axi_arvalid),
    .m05_axi_arready (m05_axi_arready), .m05_axi_rid    (m05_axi_rid),
    .m05_axi_rdata   (m05_axi_rdata),   .m05_axi_rresp  (m05_axi_rresp),
    .m05_axi_rlast   (m05_axi_rlast),   .m05_axi_ruser  (m05_axi_ruser),
    .m05_axi_rvalid  (m05_axi_rvalid),  .m05_axi_rready (m05_axi_rready),

    .m06_axi_awid    (m06_axi_awid),    .m06_axi_awaddr (m06_axi_awaddr),
    .m06_axi_awlen   (m06_axi_awlen),   .m06_axi_awsize (m06_axi_awsize),
    .m06_axi_awburst (m06_axi_awburst), .m06_axi_awlock (m06_axi_awlock),
    .m06_axi_awcache (m06_axi_awcache), .m06_axi_awprot (m06_axi_awprot),
    .m06_axi_awqos   (m06_axi_awqos),   .m06_axi_awregion(m06_axi_awregion),
    .m06_axi_awuser  (m06_axi_awuser),  .m06_axi_awvalid(m06_axi_awvalid),
    .m06_axi_awready (m06_axi_awready), .m06_axi_wdata  (m06_axi_wdata),
    .m06_axi_wstrb   (m06_axi_wstrb),   .m06_axi_wlast  (m06_axi_wlast),
    .m06_axi_wuser   (m06_axi_wuser),   .m06_axi_wvalid (m06_axi_wvalid),
    .m06_axi_wready  (m06_axi_wready),  .m06_axi_bid    (m06_axi_bid),
    .m06_axi_bresp   (m06_axi_bresp),   .m06_axi_buser  (m06_axi_buser),
    .m06_axi_bvalid  (m06_axi_bvalid),  .m06_axi_bready (m06_axi_bready),
    .m06_axi_arid    (m06_axi_arid),    .m06_axi_araddr (m06_axi_araddr),
    .m06_axi_arlen   (m06_axi_arlen),   .m06_axi_arsize (m06_axi_arsize),
    .m06_axi_arburst (m06_axi_arburst), .m06_axi_arlock (m06_axi_arlock),
    .m06_axi_arcache (m06_axi_arcache), .m06_axi_arprot (m06_axi_arprot),
    .m06_axi_arqos   (m06_axi_arqos),   .m06_axi_arregion(m06_axi_arregion),
    .m06_axi_aruser  (m06_axi_aruser),  .m06_axi_arvalid(m06_axi_arvalid),
    .m06_axi_arready (m06_axi_arready), .m06_axi_rid    (m06_axi_rid),
    .m06_axi_rdata   (m06_axi_rdata),   .m06_axi_rresp  (m06_axi_rresp),
    .m06_axi_rlast   (m06_axi_rlast),   .m06_axi_ruser  (m06_axi_ruser),
    .m06_axi_rvalid  (m06_axi_rvalid),  .m06_axi_rready (m06_axi_rready),

    .m07_axi_awid    (m07_axi_awid),    .m07_axi_awaddr (m07_axi_awaddr),
    .m07_axi_awlen   (m07_axi_awlen),   .m07_axi_awsize (m07_axi_awsize),
    .m07_axi_awburst (m07_axi_awburst), .m07_axi_awlock (m07_axi_awlock),
    .m07_axi_awcache (m07_axi_awcache), .m07_axi_awprot (m07_axi_awprot),
    .m07_axi_awqos   (m07_axi_awqos),   .m07_axi_awregion(m07_axi_awregion),
    .m07_axi_awuser  (m07_axi_awuser),  .m07_axi_awvalid(m07_axi_awvalid),
    .m07_axi_awready (m07_axi_awready), .m07_axi_wdata  (m07_axi_wdata),
    .m07_axi_wstrb   (m07_axi_wstrb),   .m07_axi_wlast  (m07_axi_wlast),
    .m07_axi_wuser   (m07_axi_wuser),   .m07_axi_wvalid (m07_axi_wvalid),
    .m07_axi_wready  (m07_axi_wready),  .m07_axi_bid    (m07_axi_bid),
    .m07_axi_bresp   (m07_axi_bresp),   .m07_axi_buser  (m07_axi_buser),
    .m07_axi_bvalid  (m07_axi_bvalid),  .m07_axi_bready (m07_axi_bready),
    .m07_axi_arid    (m07_axi_arid),    .m07_axi_araddr (m07_axi_araddr),
    .m07_axi_arlen   (m07_axi_arlen),   .m07_axi_arsize (m07_axi_arsize),
    .m07_axi_arburst (m07_axi_arburst), .m07_axi_arlock (m07_axi_arlock),
    .m07_axi_arcache (m07_axi_arcache), .m07_axi_arprot (m07_axi_arprot),
    .m07_axi_arqos   (m07_axi_arqos),   .m07_axi_arregion(m07_axi_arregion),
    .m07_axi_aruser  (m07_axi_aruser),  .m07_axi_arvalid(m07_axi_arvalid),
    .m07_axi_arready (m07_axi_arready), .m07_axi_rid    (m07_axi_rid),
    .m07_axi_rdata   (m07_axi_rdata),   .m07_axi_rresp  (m07_axi_rresp),
    .m07_axi_rlast   (m07_axi_rlast),   .m07_axi_ruser  (m07_axi_ruser),
    .m07_axi_rvalid  (m07_axi_rvalid),  .m07_axi_rready (m07_axi_rready),

    .m08_axi_awid    (m08_axi_awid),    .m08_axi_awaddr (m08_axi_awaddr),
    .m08_axi_awlen   (m08_axi_awlen),   .m08_axi_awsize (m08_axi_awsize),
    .m08_axi_awburst (m08_axi_awburst), .m08_axi_awlock (m08_axi_awlock),
    .m08_axi_awcache (m08_axi_awcache), .m08_axi_awprot (m08_axi_awprot),
    .m08_axi_awqos   (m08_axi_awqos),   .m08_axi_awregion(m08_axi_awregion),
    .m08_axi_awuser  (m08_axi_awuser),  .m08_axi_awvalid(m08_axi_awvalid),
    .m08_axi_awready (m08_axi_awready), .m08_axi_wdata  (m08_axi_wdata),
    .m08_axi_wstrb   (m08_axi_wstrb),   .m08_axi_wlast  (m08_axi_wlast),
    .m08_axi_wuser   (m08_axi_wuser),   .m08_axi_wvalid (m08_axi_wvalid),
    .m08_axi_wready  (m08_axi_wready),  .m08_axi_bid    (m08_axi_bid),
    .m08_axi_bresp   (m08_axi_bresp),   .m08_axi_buser  (m08_axi_buser),
    .m08_axi_bvalid  (m08_axi_bvalid),  .m08_axi_bready (m08_axi_bready),
    .m08_axi_arid    (m08_axi_arid),    .m08_axi_araddr (m08_axi_araddr),
    .m08_axi_arlen   (m08_axi_arlen),   .m08_axi_arsize (m08_axi_arsize),
    .m08_axi_arburst (m08_axi_arburst), .m08_axi_arlock (m08_axi_arlock),
    .m08_axi_arcache (m08_axi_arcache), .m08_axi_arprot (m08_axi_arprot),
    .m08_axi_arqos   (m08_axi_arqos),   .m08_axi_arregion(m08_axi_arregion),
    .m08_axi_aruser  (m08_axi_aruser),  .m08_axi_arvalid(m08_axi_arvalid),
    .m08_axi_arready (m08_axi_arready), .m08_axi_rid    (m08_axi_rid),
    .m08_axi_rdata   (m08_axi_rdata),   .m08_axi_rresp  (m08_axi_rresp),
    .m08_axi_rlast   (m08_axi_rlast),   .m08_axi_ruser  (m08_axi_ruser),
    .m08_axi_rvalid  (m08_axi_rvalid),  .m08_axi_rready (m08_axi_rready)
);

// -----------------------------------------------------------------------
// Slave Memory Models  (one per master port, 256 x 32-bit words each)
// -----------------------------------------------------------------------
axi_slave_mem #(.ID_WIDTH(ID_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH), .STRB_WIDTH(STRB_WIDTH),
                .MEM_DEPTH(256)) u_mem00 (
    .clk(clk), .rst(rst),
    .s_axi_awid(m00_axi_awid), .s_axi_awaddr(m00_axi_awaddr),
    .s_axi_awlen(m00_axi_awlen), .s_axi_awsize(m00_axi_awsize),
    .s_axi_awburst(m00_axi_awburst), .s_axi_awvalid(m00_axi_awvalid),
    .s_axi_awready(m00_axi_awready),
    .s_axi_wdata(m00_axi_wdata), .s_axi_wstrb(m00_axi_wstrb),
    .s_axi_wlast(m00_axi_wlast), .s_axi_wvalid(m00_axi_wvalid),
    .s_axi_wready(m00_axi_wready),
    .s_axi_bid(m00_axi_bid), .s_axi_bresp(m00_axi_bresp),
    .s_axi_bvalid(m00_axi_bvalid), .s_axi_bready(m00_axi_bready),
    .s_axi_arid(m00_axi_arid), .s_axi_araddr(m00_axi_araddr),
    .s_axi_arlen(m00_axi_arlen), .s_axi_arsize(m00_axi_arsize),
    .s_axi_arburst(m00_axi_arburst), .s_axi_arvalid(m00_axi_arvalid),
    .s_axi_arready(m00_axi_arready),
    .s_axi_rid(m00_axi_rid), .s_axi_rdata(m00_axi_rdata),
    .s_axi_rresp(m00_axi_rresp), .s_axi_rlast(m00_axi_rlast),
    .s_axi_rvalid(m00_axi_rvalid), .s_axi_rready(m00_axi_rready)
);

axi_slave_mem #(.ID_WIDTH(ID_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH), .STRB_WIDTH(STRB_WIDTH),
                .MEM_DEPTH(256)) u_mem01 (
    .clk(clk), .rst(rst),
    .s_axi_awid(m01_axi_awid), .s_axi_awaddr(m01_axi_awaddr),
    .s_axi_awlen(m01_axi_awlen), .s_axi_awsize(m01_axi_awsize),
    .s_axi_awburst(m01_axi_awburst), .s_axi_awvalid(m01_axi_awvalid),
    .s_axi_awready(m01_axi_awready),
    .s_axi_wdata(m01_axi_wdata), .s_axi_wstrb(m01_axi_wstrb),
    .s_axi_wlast(m01_axi_wlast), .s_axi_wvalid(m01_axi_wvalid),
    .s_axi_wready(m01_axi_wready),
    .s_axi_bid(m01_axi_bid), .s_axi_bresp(m01_axi_bresp),
    .s_axi_bvalid(m01_axi_bvalid), .s_axi_bready(m01_axi_bready),
    .s_axi_arid(m01_axi_arid), .s_axi_araddr(m01_axi_araddr),
    .s_axi_arlen(m01_axi_arlen), .s_axi_arsize(m01_axi_arsize),
    .s_axi_arburst(m01_axi_arburst), .s_axi_arvalid(m01_axi_arvalid),
    .s_axi_arready(m01_axi_arready),
    .s_axi_rid(m01_axi_rid), .s_axi_rdata(m01_axi_rdata),
    .s_axi_rresp(m01_axi_rresp), .s_axi_rlast(m01_axi_rlast),
    .s_axi_rvalid(m01_axi_rvalid), .s_axi_rready(m01_axi_rready)
);

axi_slave_mem #(.ID_WIDTH(ID_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH), .STRB_WIDTH(STRB_WIDTH),
                .MEM_DEPTH(256)) u_mem02 (
    .clk(clk), .rst(rst),
    .s_axi_awid(m02_axi_awid), .s_axi_awaddr(m02_axi_awaddr),
    .s_axi_awlen(m02_axi_awlen), .s_axi_awsize(m02_axi_awsize),
    .s_axi_awburst(m02_axi_awburst), .s_axi_awvalid(m02_axi_awvalid),
    .s_axi_awready(m02_axi_awready),
    .s_axi_wdata(m02_axi_wdata), .s_axi_wstrb(m02_axi_wstrb),
    .s_axi_wlast(m02_axi_wlast), .s_axi_wvalid(m02_axi_wvalid),
    .s_axi_wready(m02_axi_wready),
    .s_axi_bid(m02_axi_bid), .s_axi_bresp(m02_axi_bresp),
    .s_axi_bvalid(m02_axi_bvalid), .s_axi_bready(m02_axi_bready),
    .s_axi_arid(m02_axi_arid), .s_axi_araddr(m02_axi_araddr),
    .s_axi_arlen(m02_axi_arlen), .s_axi_arsize(m02_axi_arsize),
    .s_axi_arburst(m02_axi_arburst), .s_axi_arvalid(m02_axi_arvalid),
    .s_axi_arready(m02_axi_arready),
    .s_axi_rid(m02_axi_rid), .s_axi_rdata(m02_axi_rdata),
    .s_axi_rresp(m02_axi_rresp), .s_axi_rlast(m02_axi_rlast),
    .s_axi_rvalid(m02_axi_rvalid), .s_axi_rready(m02_axi_rready)
);

axi_slave_mem #(.ID_WIDTH(ID_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH), .STRB_WIDTH(STRB_WIDTH),
                .MEM_DEPTH(256)) u_mem03 (
    .clk(clk), .rst(rst),
    .s_axi_awid(m03_axi_awid), .s_axi_awaddr(m03_axi_awaddr),
    .s_axi_awlen(m03_axi_awlen), .s_axi_awsize(m03_axi_awsize),
    .s_axi_awburst(m03_axi_awburst), .s_axi_awvalid(m03_axi_awvalid),
    .s_axi_awready(m03_axi_awready),
    .s_axi_wdata(m03_axi_wdata), .s_axi_wstrb(m03_axi_wstrb),
    .s_axi_wlast(m03_axi_wlast), .s_axi_wvalid(m03_axi_wvalid),
    .s_axi_wready(m03_axi_wready),
    .s_axi_bid(m03_axi_bid), .s_axi_bresp(m03_axi_bresp),
    .s_axi_bvalid(m03_axi_bvalid), .s_axi_bready(m03_axi_bready),
    .s_axi_arid(m03_axi_arid), .s_axi_araddr(m03_axi_araddr),
    .s_axi_arlen(m03_axi_arlen), .s_axi_arsize(m03_axi_arsize),
    .s_axi_arburst(m03_axi_arburst), .s_axi_arvalid(m03_axi_arvalid),
    .s_axi_arready(m03_axi_arready),
    .s_axi_rid(m03_axi_rid), .s_axi_rdata(m03_axi_rdata),
    .s_axi_rresp(m03_axi_rresp), .s_axi_rlast(m03_axi_rlast),
    .s_axi_rvalid(m03_axi_rvalid), .s_axi_rready(m03_axi_rready)
);

axi_slave_mem #(.ID_WIDTH(ID_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH), .STRB_WIDTH(STRB_WIDTH),
                .MEM_DEPTH(256)) u_mem04 (
    .clk(clk), .rst(rst),
    .s_axi_awid(m04_axi_awid), .s_axi_awaddr(m04_axi_awaddr),
    .s_axi_awlen(m04_axi_awlen), .s_axi_awsize(m04_axi_awsize),
    .s_axi_awburst(m04_axi_awburst), .s_axi_awvalid(m04_axi_awvalid),
    .s_axi_awready(m04_axi_awready),
    .s_axi_wdata(m04_axi_wdata), .s_axi_wstrb(m04_axi_wstrb),
    .s_axi_wlast(m04_axi_wlast), .s_axi_wvalid(m04_axi_wvalid),
    .s_axi_wready(m04_axi_wready),
    .s_axi_bid(m04_axi_bid), .s_axi_bresp(m04_axi_bresp),
    .s_axi_bvalid(m04_axi_bvalid), .s_axi_bready(m04_axi_bready),
    .s_axi_arid(m04_axi_arid), .s_axi_araddr(m04_axi_araddr),
    .s_axi_arlen(m04_axi_arlen), .s_axi_arsize(m04_axi_arsize),
    .s_axi_arburst(m04_axi_arburst), .s_axi_arvalid(m04_axi_arvalid),
    .s_axi_arready(m04_axi_arready),
    .s_axi_rid(m04_axi_rid), .s_axi_rdata(m04_axi_rdata),
    .s_axi_rresp(m04_axi_rresp), .s_axi_rlast(m04_axi_rlast),
    .s_axi_rvalid(m04_axi_rvalid), .s_axi_rready(m04_axi_rready)
);

axi_slave_mem #(.ID_WIDTH(ID_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH), .STRB_WIDTH(STRB_WIDTH),
                .MEM_DEPTH(256)) u_mem05 (
    .clk(clk), .rst(rst),
    .s_axi_awid(m05_axi_awid), .s_axi_awaddr(m05_axi_awaddr),
    .s_axi_awlen(m05_axi_awlen), .s_axi_awsize(m05_axi_awsize),
    .s_axi_awburst(m05_axi_awburst), .s_axi_awvalid(m05_axi_awvalid),
    .s_axi_awready(m05_axi_awready),
    .s_axi_wdata(m05_axi_wdata), .s_axi_wstrb(m05_axi_wstrb),
    .s_axi_wlast(m05_axi_wlast), .s_axi_wvalid(m05_axi_wvalid),
    .s_axi_wready(m05_axi_wready),
    .s_axi_bid(m05_axi_bid), .s_axi_bresp(m05_axi_bresp),
    .s_axi_bvalid(m05_axi_bvalid), .s_axi_bready(m05_axi_bready),
    .s_axi_arid(m05_axi_arid), .s_axi_araddr(m05_axi_araddr),
    .s_axi_arlen(m05_axi_arlen), .s_axi_arsize(m05_axi_arsize),
    .s_axi_arburst(m05_axi_arburst), .s_axi_arvalid(m05_axi_arvalid),
    .s_axi_arready(m05_axi_arready),
    .s_axi_rid(m05_axi_rid), .s_axi_rdata(m05_axi_rdata),
    .s_axi_rresp(m05_axi_rresp), .s_axi_rlast(m05_axi_rlast),
    .s_axi_rvalid(m05_axi_rvalid), .s_axi_rready(m05_axi_rready)
);

axi_slave_mem #(.ID_WIDTH(ID_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH), .STRB_WIDTH(STRB_WIDTH),
                .MEM_DEPTH(256)) u_mem06 (
    .clk(clk), .rst(rst),
    .s_axi_awid(m06_axi_awid), .s_axi_awaddr(m06_axi_awaddr),
    .s_axi_awlen(m06_axi_awlen), .s_axi_awsize(m06_axi_awsize),
    .s_axi_awburst(m06_axi_awburst), .s_axi_awvalid(m06_axi_awvalid),
    .s_axi_awready(m06_axi_awready),
    .s_axi_wdata(m06_axi_wdata), .s_axi_wstrb(m06_axi_wstrb),
    .s_axi_wlast(m06_axi_wlast), .s_axi_wvalid(m06_axi_wvalid),
    .s_axi_wready(m06_axi_wready),
    .s_axi_bid(m06_axi_bid), .s_axi_bresp(m06_axi_bresp),
    .s_axi_bvalid(m06_axi_bvalid), .s_axi_bready(m06_axi_bready),
    .s_axi_arid(m06_axi_arid), .s_axi_araddr(m06_axi_araddr),
    .s_axi_arlen(m06_axi_arlen), .s_axi_arsize(m06_axi_arsize),
    .s_axi_arburst(m06_axi_arburst), .s_axi_arvalid(m06_axi_arvalid),
    .s_axi_arready(m06_axi_arready),
    .s_axi_rid(m06_axi_rid), .s_axi_rdata(m06_axi_rdata),
    .s_axi_rresp(m06_axi_rresp), .s_axi_rlast(m06_axi_rlast),
    .s_axi_rvalid(m06_axi_rvalid), .s_axi_rready(m06_axi_rready)
);

axi_slave_mem #(.ID_WIDTH(ID_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH), .STRB_WIDTH(STRB_WIDTH),
                .MEM_DEPTH(256)) u_mem07 (
    .clk(clk), .rst(rst),
    .s_axi_awid(m07_axi_awid), .s_axi_awaddr(m07_axi_awaddr),
    .s_axi_awlen(m07_axi_awlen), .s_axi_awsize(m07_axi_awsize),
    .s_axi_awburst(m07_axi_awburst), .s_axi_awvalid(m07_axi_awvalid),
    .s_axi_awready(m07_axi_awready),
    .s_axi_wdata(m07_axi_wdata), .s_axi_wstrb(m07_axi_wstrb),
    .s_axi_wlast(m07_axi_wlast), .s_axi_wvalid(m07_axi_wvalid),
    .s_axi_wready(m07_axi_wready),
    .s_axi_bid(m07_axi_bid), .s_axi_bresp(m07_axi_bresp),
    .s_axi_bvalid(m07_axi_bvalid), .s_axi_bready(m07_axi_bready),
    .s_axi_arid(m07_axi_arid), .s_axi_araddr(m07_axi_araddr),
    .s_axi_arlen(m07_axi_arlen), .s_axi_arsize(m07_axi_arsize),
    .s_axi_arburst(m07_axi_arburst), .s_axi_arvalid(m07_axi_arvalid),
    .s_axi_arready(m07_axi_arready),
    .s_axi_rid(m07_axi_rid), .s_axi_rdata(m07_axi_rdata),
    .s_axi_rresp(m07_axi_rresp), .s_axi_rlast(m07_axi_rlast),
    .s_axi_rvalid(m07_axi_rvalid), .s_axi_rready(m07_axi_rready)
);

axi_slave_mem #(.ID_WIDTH(ID_WIDTH), .DATA_WIDTH(DATA_WIDTH),
                .ADDR_WIDTH(ADDR_WIDTH), .STRB_WIDTH(STRB_WIDTH),
                .MEM_DEPTH(256)) u_mem08 (
    .clk(clk), .rst(rst),
    .s_axi_awid(m08_axi_awid), .s_axi_awaddr(m08_axi_awaddr),
    .s_axi_awlen(m08_axi_awlen), .s_axi_awsize(m08_axi_awsize),
    .s_axi_awburst(m08_axi_awburst), .s_axi_awvalid(m08_axi_awvalid),
    .s_axi_awready(m08_axi_awready),
    .s_axi_wdata(m08_axi_wdata), .s_axi_wstrb(m08_axi_wstrb),
    .s_axi_wlast(m08_axi_wlast), .s_axi_wvalid(m08_axi_wvalid),
    .s_axi_wready(m08_axi_wready),
    .s_axi_bid(m08_axi_bid), .s_axi_bresp(m08_axi_bresp),
    .s_axi_bvalid(m08_axi_bvalid), .s_axi_bready(m08_axi_bready),
    .s_axi_arid(m08_axi_arid), .s_axi_araddr(m08_axi_araddr),
    .s_axi_arlen(m08_axi_arlen), .s_axi_arsize(m08_axi_arsize),
    .s_axi_arburst(m08_axi_arburst), .s_axi_arvalid(m08_axi_arvalid),
    .s_axi_arready(m08_axi_arready),
    .s_axi_rid(m08_axi_rid), .s_axi_rdata(m08_axi_rdata),
    .s_axi_rresp(m08_axi_rresp), .s_axi_rlast(m08_axi_rlast),
    .s_axi_rvalid(m08_axi_rvalid), .s_axi_rready(m08_axi_rready)
);

// -----------------------------------------------------------------------
// Scoreboard / counters
// -----------------------------------------------------------------------
integer pass_cnt = 0;
integer fail_cnt = 0;

// -----------------------------------------------------------------------
// Tasks
// -----------------------------------------------------------------------

// --- AXI Write (single beat) ---
// addr  : full 32-bit byte address
// data  : 32-bit write data
// id    : transaction ID
task axi_write;
    input [ADDR_WIDTH-1:0] addr;
    input [DATA_WIDTH-1:0] data;
    input [ID_WIDTH-1:0]   id;
    integer timeout;
    begin
        // Drive AW channel
        @(posedge clk);
        s00_axi_awid    <= id;
        s00_axi_awaddr  <= addr;
        s00_axi_awlen   <= 8'd0;     // 1 beat
        s00_axi_awsize  <= 3'd2;     // 4 bytes
        s00_axi_awburst <= 2'd1;     // INCR
        s00_axi_awvalid <= 1'b1;
        s00_axi_wdata   <= data;
        s00_axi_wstrb   <= 4'hF;
        s00_axi_wlast   <= 1'b1;
        s00_axi_wvalid  <= 1'b1;

        // Wait for AW handshake
        timeout = 0;
        while (!s00_axi_awready) begin
            @(posedge clk);
            timeout = timeout + 1;
            if (timeout > 200) begin
                $display("TIMEOUT: AW handshake addr=%0h", addr);
                disable axi_write;
            end
        end
        @(posedge clk);
        s00_axi_awvalid <= 1'b0;

        // Wait for W handshake
        timeout = 0;
        while (!s00_axi_wready) begin
            @(posedge clk);
            timeout = timeout + 1;
            if (timeout > 200) begin
                $display("TIMEOUT: W handshake addr=%0h", addr);
                disable axi_write;
            end
        end
        @(posedge clk);
        s00_axi_wvalid <= 1'b0;

        // Accept B response
        s00_axi_bready <= 1'b1;
        timeout = 0;
        while (!s00_axi_bvalid) begin
            @(posedge clk);
            timeout = timeout + 1;
            if (timeout > 200) begin
                $display("TIMEOUT: B response addr=%0h", addr);
                disable axi_write;
            end
        end
        @(posedge clk);
        s00_axi_bready <= 1'b0;
    end
endtask

// --- AXI Read (single beat) + data check ---
// addr     : full 32-bit byte address
// expected : expected read data
// id       : transaction ID
task axi_read_check;
    input [ADDR_WIDTH-1:0] addr;
    input [DATA_WIDTH-1:0] expected;
    input [ID_WIDTH-1:0]   id;
    reg   [DATA_WIDTH-1:0] rdata_got;
    integer timeout;
    begin
        @(posedge clk);
        s00_axi_arid    <= id;
        s00_axi_araddr  <= addr;
        s00_axi_arlen   <= 8'd0;
        s00_axi_arsize  <= 3'd2;
        s00_axi_arburst <= 2'd1;
        s00_axi_arvalid <= 1'b1;
        s00_axi_rready  <= 1'b1;

        // Wait for AR handshake
        timeout = 0;
        while (!s00_axi_arready) begin
            @(posedge clk);
            timeout = timeout + 1;
            if (timeout > 200) begin
                $display("TIMEOUT: AR handshake addr=%0h", addr);
                disable axi_read_check;
            end
        end
        @(posedge clk);
        s00_axi_arvalid <= 1'b0;

        // Wait for R data
        timeout = 0;
        while (!s00_axi_rvalid) begin
            @(posedge clk);
            timeout = timeout + 1;
            if (timeout > 200) begin
                $display("TIMEOUT: R data addr=%0h", addr);
                disable axi_read_check;
            end
        end
        rdata_got = s00_axi_rdata;
        @(posedge clk);
        s00_axi_rready <= 1'b0;

        // Check
        if (rdata_got === expected) begin
            $display("PASS: addr=0x%08h  exp=0x%08h  got=0x%08h",
                      addr, expected, rdata_got);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("FAIL: addr=0x%08h  exp=0x%08h  got=0x%08h",
                      addr, expected, rdata_got);
            fail_cnt = fail_cnt + 1;
        end
    end
endtask

// -----------------------------------------------------------------------
// Stimulus
// -----------------------------------------------------------------------
// Offset within each slave used for all tests (word 4 = byte offset 0x10)
localparam [23:0] OFFSET = 24'h000010;

// Write data pattern: unique per master
reg [31:0] wdata [0:8];

integer i;

initial begin
    // Initialise write data patterns
    wdata[0] = 32'hDEAD_0000;
    wdata[1] = 32'hBEEF_0001;
    wdata[2] = 32'hCAFE_0002;
    wdata[3] = 32'hF00D_0003;
    wdata[4] = 32'hA5A5_0004;
    wdata[5] = 32'h5A5A_0005;
    wdata[6] = 32'h1234_0006;
    wdata[7] = 32'hABCD_0007;
    wdata[8] = 32'h9876_0008;

    // ----------------------------------------------------------------
    // FSDB waveform dump for Verdi
    // ----------------------------------------------------------------
    $fsdbDumpfile("tb_axi_interconnect_wrap_1x9.fsdb");

    // Dump all signals in the full hierarchy (depth 0 = unlimited)
    $fsdbDumpvars(0, tb_axi_interconnect_wrap_1x9);

    // Capture MDA (memories, arrays) and SVA assertion results
    $fsdbDumpMDA(0, tb_axi_interconnect_wrap_1x9);
    $fsdbDumpSVA(0, tb_axi_interconnect_wrap_1x9);

    // Reset sequence
    rst = 1;
    repeat(5) @(posedge clk);
    rst = 0;
    repeat(5) @(posedge clk);

    $display("============================================================");
    $display(" AXI Interconnect 1x9 Testbench");
    $display(" Testing WRITE then READ to all 9 master ports");
    $display("============================================================");

    // ------------------------------------------------------------------
    // WRITE to all 9 master ports
    // ------------------------------------------------------------------
    $display("\n--- WRITE PHASE ---");

    axi_write(BASE_M00 | OFFSET, wdata[0], 8'h00);
    repeat(4) @(posedge clk);
    axi_write(BASE_M01 | OFFSET, wdata[1], 8'h01);
    repeat(4) @(posedge clk);
    axi_write(BASE_M02 | OFFSET, wdata[2], 8'h02);
    repeat(4) @(posedge clk);
    axi_write(BASE_M03 | OFFSET, wdata[3], 8'h03);
    repeat(4) @(posedge clk);
    axi_write(BASE_M04 | OFFSET, wdata[4], 8'h04);
    repeat(4) @(posedge clk);
    axi_write(BASE_M05 | OFFSET, wdata[5], 8'h05);
    repeat(4) @(posedge clk);
    axi_write(BASE_M06 | OFFSET, wdata[6], 8'h06);
    repeat(4) @(posedge clk);
    axi_write(BASE_M07 | OFFSET, wdata[7], 8'h07);
    repeat(4) @(posedge clk);
    axi_write(BASE_M08 | OFFSET, wdata[8], 8'h08);
    repeat(4) @(posedge clk);

    // ------------------------------------------------------------------
    // READ back from all 9 master ports and verify
    // ------------------------------------------------------------------
    $display("\n--- READ & VERIFY PHASE ---");

    axi_read_check(BASE_M00 | OFFSET, wdata[0], 8'h10);
    repeat(4) @(posedge clk);
    axi_read_check(BASE_M01 | OFFSET, wdata[1], 8'h11);
    repeat(4) @(posedge clk);
    axi_read_check(BASE_M02 | OFFSET, wdata[2], 8'h12);
    repeat(4) @(posedge clk);
    axi_read_check(BASE_M03 | OFFSET, wdata[3], 8'h13);
    repeat(4) @(posedge clk);
    axi_read_check(BASE_M04 | OFFSET, wdata[4], 8'h14);
    repeat(4) @(posedge clk);
    axi_read_check(BASE_M05 | OFFSET, wdata[5], 8'h15);
    repeat(4) @(posedge clk);
    axi_read_check(BASE_M06 | OFFSET, wdata[6], 8'h16);
    repeat(4) @(posedge clk);
    axi_read_check(BASE_M07 | OFFSET, wdata[7], 8'h17);
    repeat(4) @(posedge clk);
    axi_read_check(BASE_M08 | OFFSET, wdata[8], 8'h18);
    repeat(4) @(posedge clk);

    // ------------------------------------------------------------------
    // Summary
    // ------------------------------------------------------------------
    $display("\n============================================================");
    $display(" Test Summary: PASS=%0d  FAIL=%0d  (Total=%0d)",
             pass_cnt, fail_cnt, pass_cnt+fail_cnt);
    $display("============================================================");

    if (fail_cnt == 0)
        $display(" ALL TESTS PASSED");
    else
        $display(" *** SOME TESTS FAILED ***");

    repeat(10) @(posedge clk);
    $finish;
end

// Timeout watchdog
initial begin
    #500000; // 500 us absolute limit
    $display("WATCHDOG: simulation timeout!");
    $finish;
end

endmodule

// =======================================================================
//  Simple AXI4 Slave Memory Model
//  - Single-beat and burst (INCR) capable
//  - Uses word index from low ADDR bits, ignores high address bits
//  - Returns OKAY (2'b00) always
// =======================================================================
module axi_slave_mem #(
    parameter ID_WIDTH   = 8,
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter STRB_WIDTH = DATA_WIDTH/8,
    parameter MEM_DEPTH  = 256
)(
    input  wire                   clk,
    input  wire                   rst,

    // Write address
    input  wire [ID_WIDTH-1:0]    s_axi_awid,
    input  wire [ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  wire [7:0]             s_axi_awlen,
    input  wire [2:0]             s_axi_awsize,
    input  wire [1:0]             s_axi_awburst,
    input  wire                   s_axi_awvalid,
    output reg                    s_axi_awready,

    // Write data
    input  wire [DATA_WIDTH-1:0]  s_axi_wdata,
    input  wire [STRB_WIDTH-1:0]  s_axi_wstrb,
    input  wire                   s_axi_wlast,
    input  wire                   s_axi_wvalid,
    output reg                    s_axi_wready,

    // Write response
    output reg  [ID_WIDTH-1:0]    s_axi_bid,
    output reg  [1:0]             s_axi_bresp,
    output reg                    s_axi_bvalid,
    input  wire                   s_axi_bready,

    // Read address
    input  wire [ID_WIDTH-1:0]    s_axi_arid,
    input  wire [ADDR_WIDTH-1:0]  s_axi_araddr,
    input  wire [7:0]             s_axi_arlen,
    input  wire [2:0]             s_axi_arsize,
    input  wire [1:0]             s_axi_arburst,
    input  wire                   s_axi_arvalid,
    output reg                    s_axi_arready,

    // Read data
    output reg  [ID_WIDTH-1:0]    s_axi_rid,
    output reg  [DATA_WIDTH-1:0]  s_axi_rdata,
    output reg  [1:0]             s_axi_rresp,
    output reg                    s_axi_rlast,
    output reg                    s_axi_rvalid,
    input  wire                   s_axi_rready
);

// Internal memory array
reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];

// Word index from byte address (mask to MEM_DEPTH)
`define WIDX(ba) (((ba) >> 2) & (MEM_DEPTH-1))

// Write state machine
localparam WR_IDLE = 2'd0,
           WR_DATA = 2'd1,
           WR_RESP = 2'd2;

reg [1:0]            wr_state = WR_IDLE;
reg [ID_WIDTH-1:0]   wr_id;
reg [ADDR_WIDTH-1:0] wr_addr;
reg [7:0]            wr_len;
reg [7:0]            wr_beat;

// Read state machine
localparam RD_IDLE = 1'd0,
           RD_DATA = 1'd1;

reg                  rd_state = RD_IDLE;
reg [ID_WIDTH-1:0]   rd_id;
reg [ADDR_WIDTH-1:0] rd_addr;
reg [7:0]            rd_len;
reg [7:0]            rd_beat;

integer k;
initial begin
    for (k = 0; k < MEM_DEPTH; k = k + 1)
        mem[k] = 32'h0;
end

// ---- Write FSM --------------------------------------------------------
always @(posedge clk) begin
    if (rst) begin
        wr_state     <= WR_IDLE;
        s_axi_awready <= 1'b0;
        s_axi_wready  <= 1'b0;
        s_axi_bvalid  <= 1'b0;
    end else begin
        case (wr_state)
            WR_IDLE: begin
                s_axi_awready <= 1'b1;
                s_axi_wready  <= 1'b0;
                if (s_axi_awvalid && s_axi_awready) begin
                    wr_id        <= s_axi_awid;
                    wr_addr      <= s_axi_awaddr;
                    wr_len       <= s_axi_awlen;
                    wr_beat      <= 8'd0;
                    s_axi_awready <= 1'b0;
                    s_axi_wready  <= 1'b1;
                    wr_state     <= WR_DATA;
                end
            end
            WR_DATA: begin
                if (s_axi_wvalid && s_axi_wready) begin
                    // Byte-enable write
                    if (s_axi_wstrb[0]) mem[`WIDX(wr_addr)][7:0]   <= s_axi_wdata[7:0];
                    if (s_axi_wstrb[1]) mem[`WIDX(wr_addr)][15:8]  <= s_axi_wdata[15:8];
                    if (s_axi_wstrb[2]) mem[`WIDX(wr_addr)][23:16] <= s_axi_wdata[23:16];
                    if (s_axi_wstrb[3]) mem[`WIDX(wr_addr)][31:24] <= s_axi_wdata[31:24];

                    if (s_axi_wlast) begin
                        s_axi_wready <= 1'b0;
                        s_axi_bvalid <= 1'b1;
                        s_axi_bid    <= wr_id;
                        s_axi_bresp  <= 2'b00;
                        wr_state     <= WR_RESP;
                    end else begin
                        wr_addr  <= wr_addr + 4;
                        wr_beat  <= wr_beat + 1;
                    end
                end
            end
            WR_RESP: begin
                if (s_axi_bready && s_axi_bvalid) begin
                    s_axi_bvalid <= 1'b0;
                    wr_state     <= WR_IDLE;
                end
            end
            default: wr_state <= WR_IDLE;
        endcase
    end
end

// ---- Read FSM ---------------------------------------------------------
always @(posedge clk) begin
    if (rst) begin
        rd_state     <= RD_IDLE;
        s_axi_arready <= 1'b0;
        s_axi_rvalid  <= 1'b0;
    end else begin
        case (rd_state)
            RD_IDLE: begin
                s_axi_arready <= 1'b1;
                s_axi_rvalid  <= 1'b0;
                if (s_axi_arvalid && s_axi_arready) begin
                    rd_id         <= s_axi_arid;
                    rd_addr       <= s_axi_araddr;
                    rd_len        <= s_axi_arlen;
                    rd_beat       <= 8'd0;
                    s_axi_arready <= 1'b0;
                    s_axi_rvalid  <= 1'b1;
                    s_axi_rid     <= s_axi_arid;
                    s_axi_rdata   <= mem[`WIDX(s_axi_araddr)];
                    s_axi_rresp   <= 2'b00;
                    s_axi_rlast   <= (s_axi_arlen == 8'd0);
                    rd_state      <= RD_DATA;
                end
            end
            RD_DATA: begin
                if (s_axi_rready && s_axi_rvalid) begin
                    if (s_axi_rlast) begin
                        s_axi_rvalid <= 1'b0;
                        rd_state     <= RD_IDLE;
                    end else begin
                        rd_addr     <= rd_addr + 4;
                        rd_beat     <= rd_beat + 1;
                        s_axi_rdata <= mem[`WIDX(rd_addr + 4)];
                        s_axi_rid   <= rd_id;
                        s_axi_rresp <= 2'b00;
                        s_axi_rlast <= (rd_beat + 1 == rd_len);
                    end
                end
            end
            default: rd_state <= RD_IDLE;
        endcase
    end
end

`undef WIDX

// Note: waveform dumping is controlled from the top-level testbench only.

endmodule
