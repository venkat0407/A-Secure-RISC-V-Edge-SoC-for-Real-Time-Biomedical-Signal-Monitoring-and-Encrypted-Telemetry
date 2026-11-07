class irq_test extends uvm_test;
  irq_env env;

  `uvm_component_utils(irq_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = irq_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    irq_base_sequence seq;
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "=== Starting IRQ UVM Verification Sequence ===", UVM_LOW)
    seq = irq_base_sequence::type_id::create("seq");
    seq.start(env.agent.seqr);
    #100ns;
    `uvm_info(get_type_name(), "=== IRQ Sequence Finished Successfully ===", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
