`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
  import gpio_pkg::*;

  logic clk;
  logic rst_n;

  // Clock Generation (50 MHz)
  initial begin
    clk = 0;
    forever #10 clk = ~clk;
  end

  // Reset Generation
  initial begin
    rst_n = 0;
    #40 rst_n = 1;
  end

  // Persistent VIP Interface (alive throughout simulation)
  gpio_if vif(clk, rst_n);

  initial begin
    // Register interface in UVM config_db using standard Cookbook pattern
    uvm_config_db#(virtual gpio_if)::set(null, "*", "vif", vif);

    // Run test
    run_test("gpio_test");
  end
endmodule
