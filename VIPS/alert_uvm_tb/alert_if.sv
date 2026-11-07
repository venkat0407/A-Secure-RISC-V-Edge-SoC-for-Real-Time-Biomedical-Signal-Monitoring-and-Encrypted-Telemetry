interface alert_if(input logic clk, input logic rst_n);
  // Boundary Signals
  logic alert_led;

  // Modport for Driver / BFM
  modport drv_mp (
    input  clk, rst_n,
    input alert_led
  );

  // Modport for Monitor
  modport mon_mp (
    input clk, rst_n,
    input alert_led
  );
endinterface
