class sentinelsoc_boundary_sequencer extends uvm_sequencer #(sentinelsoc_boundary_item);
  `uvm_component_utils(sentinelsoc_boundary_sequencer)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass
