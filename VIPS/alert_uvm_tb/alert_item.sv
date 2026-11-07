class alert_item extends uvm_sequence_item;

  bit alert_led;

  `uvm_object_utils_begin(alert_item)
    `uvm_field_int(alert_led, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "alert_item");
    super.new(name);
  endfunction
endclass
