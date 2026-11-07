interface irq_if(input logic clk, input logic rst_n);
  // Boundary Signals
  logic core_irq_out;

  // Modport for Driver / BFM
  modport drv_mp (
    input  clk, rst_n,
    input core_irq_out
  );

  // Modport for Monitor
  modport mon_mp (
    input clk, rst_n,
    input core_irq_out
  );
endinterface
