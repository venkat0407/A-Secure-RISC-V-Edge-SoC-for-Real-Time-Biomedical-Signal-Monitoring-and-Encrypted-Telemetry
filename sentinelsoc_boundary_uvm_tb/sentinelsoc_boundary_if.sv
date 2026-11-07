interface sentinelsoc_boundary_if(input logic clk, input logic rst_n);
  // Boundary Signals
  logic uart_rx;
  logic uart_tx;
  logic [7:0] gpio_io;
  logic [11:0] adc_sample_data;
  logic adc_sample_valid;
  logic alert_led;
  logic wdt_reset_n;
  logic core_irq_out;

  // Modport for Driver / BFM
  modport drv_mp (
    input  clk, rst_n,
    output uart_rx,
    input uart_tx,
    output gpio_io,
    output adc_sample_data,
    output adc_sample_valid,
    input alert_led,
    input wdt_reset_n,
    input core_irq_out
  );

  // Modport for Monitor
  modport mon_mp (
    input clk, rst_n,
    input uart_rx,
    input uart_tx,
    input gpio_io,
    input adc_sample_data,
    input adc_sample_valid,
    input alert_led,
    input wdt_reset_n,
    input core_irq_out
  );
endinterface
