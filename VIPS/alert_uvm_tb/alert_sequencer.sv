class alert_sequencer extends uvm_sequencer #(alert_item);
  `uvm_component_utils(alert_sequencer)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
