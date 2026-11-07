interface uart_if(input logic clk, input logic rst_n);
  // Boundary Signals
  logic uart_rx;
  logic uart_tx;

  // Modport for Driver / BFM
  modport drv_mp (
    input  clk, rst_n,
    output uart_rx,
    input uart_tx
  );

  // Modport for Monitor
  modport mon_mp (
    input clk, rst_n,
    input uart_rx,
    input uart_tx
  );
endinterface
