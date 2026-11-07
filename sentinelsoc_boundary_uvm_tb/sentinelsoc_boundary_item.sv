class sentinelsoc_boundary_item extends uvm_sequence_item;

  rand bit uart_rx;
  bit uart_tx;
  rand bit [7:0] gpio_io;
  rand bit [11:0] adc_sample_data;
  rand bit adc_sample_valid;
  bit alert_led;
  bit wdt_reset_n;
  bit core_irq_out;

  `uvm_object_utils_begin(sentinelsoc_boundary_item)
    `uvm_field_int(uart_rx, UVM_ALL_ON)
    `uvm_field_int(uart_tx, UVM_ALL_ON)
    `uvm_field_int(gpio_io, UVM_ALL_ON)
    `uvm_field_int(adc_sample_data, UVM_ALL_ON)
    `uvm_field_int(adc_sample_valid, UVM_ALL_ON)
    `uvm_field_int(alert_led, UVM_ALL_ON)
    `uvm_field_int(wdt_reset_n, UVM_ALL_ON)
    `uvm_field_int(core_irq_out, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "sentinelsoc_boundary_item");
    super.new(name);
  endfunction
endclass
