interface gpio_if(input logic clk, input logic rst_n);
  // Boundary Signals
  logic [7:0] gpio_io;

  // Modport for Driver / BFM
  modport drv_mp (
    input  clk, rst_n,
    output gpio_io
  );

  // Modport for Monitor
  modport mon_mp (
    input clk, rst_n,
    input gpio_io
  );
endinterface
