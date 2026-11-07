class irq_item extends uvm_sequence_item;

  bit core_irq_out;

  `uvm_object_utils_begin(irq_item)
    `uvm_field_int(core_irq_out, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "irq_item");
    super.new(name);
  endfunction
endclass
