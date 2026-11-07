interface adc_if(input logic clk, input logic rst_n);
  // Boundary Signals
  logic [11:0] adc_sample_data;
  logic adc_sample_valid;

  // Modport for Driver / BFM
  modport drv_mp (
    input  clk, rst_n,
    output adc_sample_data,
    output adc_sample_valid
  );

  // Modport for Monitor
  modport mon_mp (
    input clk, rst_n,
    input adc_sample_data,
    input adc_sample_valid
  );
endinterface
