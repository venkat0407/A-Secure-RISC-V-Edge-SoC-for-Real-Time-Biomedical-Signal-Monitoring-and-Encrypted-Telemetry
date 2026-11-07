class gpio_item extends uvm_sequence_item;

  rand bit [7:0] gpio_io;

  `uvm_object_utils_begin(gpio_item)
    `uvm_field_int(gpio_io, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "gpio_item");
    super.new(name);
  endfunction
endclass
