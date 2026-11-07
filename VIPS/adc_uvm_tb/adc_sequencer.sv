class adc_sequencer extends uvm_sequencer #(adc_item);
  `uvm_component_utils(adc_sequencer)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
