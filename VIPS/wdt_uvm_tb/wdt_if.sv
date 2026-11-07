interface wdt_if(input logic clk, input logic rst_n);
  // Boundary Signals
  logic wdt_reset_n;

  // Modport for Driver / BFM
  modport drv_mp (
    input  clk, rst_n,
    input wdt_reset_n
  );

  // Modport for Monitor
  modport mon_mp (
    input clk, rst_n,
    input wdt_reset_n
  );
endinterface
