class wdt_item extends uvm_sequence_item;

  bit wdt_reset_n;

  `uvm_object_utils_begin(wdt_item)
    `uvm_field_int(wdt_reset_n, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "wdt_item");
    super.new(name);
  endfunction
endclass
