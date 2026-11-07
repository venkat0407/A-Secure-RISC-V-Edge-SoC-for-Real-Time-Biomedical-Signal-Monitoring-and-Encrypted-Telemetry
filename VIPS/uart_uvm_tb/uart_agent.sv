class uart_agent extends uvm_agent;
  uart_driver    drv;
  uart_monitor   mon;
  uart_sequencer seqr;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  `uvm_component_utils_begin(uart_agent)
    `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
  `uvm_component_utils_end

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon = uart_monitor::type_id::create("mon", this);
    if (is_active == UVM_ACTIVE) begin
      drv  = uart_driver::type_id::create("drv", this);
      seqr = uart_sequencer::type_id::create("seqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction
endclass
