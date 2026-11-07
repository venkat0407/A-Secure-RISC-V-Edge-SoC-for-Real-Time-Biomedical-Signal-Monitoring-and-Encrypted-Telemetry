class adc_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp #(adc_item, adc_scoreboard) ap_imp;

  `uvm_component_utils(adc_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap_imp = new("ap_imp", this);
  endfunction

  function void write(adc_item item);
    `uvm_info(get_type_name(), $sformatf("Received item: %s", item.sprint()), UVM_HIGH)
  endfunction
endclass
