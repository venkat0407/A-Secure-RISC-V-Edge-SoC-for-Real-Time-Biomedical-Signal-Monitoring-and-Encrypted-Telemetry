class uart_item extends uvm_sequence_item;

  rand bit uart_rx;
  bit uart_tx;

  `uvm_object_utils_begin(uart_item)
    `uvm_field_int(uart_rx, UVM_ALL_ON)
    `uvm_field_int(uart_tx, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "uart_item");
    super.new(name);
  endfunction
endclass
