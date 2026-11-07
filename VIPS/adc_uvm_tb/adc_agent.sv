class adc_agent extends uvm_agent;
  adc_driver    drv;
  adc_monitor   mon;
  adc_sequencer seqr;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  `uvm_component_utils_begin(adc_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = adc_monitor::type_id::create("mon", this);
    if (is_active == UVM_ACTIVE) begin
      drv  = adc_driver::type_id::create("drv", this);
      seqr = adc_sequencer::type_id::create("seqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass
