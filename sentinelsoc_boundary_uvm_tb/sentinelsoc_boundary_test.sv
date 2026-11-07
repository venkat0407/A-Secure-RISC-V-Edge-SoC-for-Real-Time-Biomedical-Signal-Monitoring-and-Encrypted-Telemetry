class sentinelsoc_boundary_test extends uvm_test;
  sentinelsoc_boundary_env env;

  `uvm_component_utils(sentinelsoc_boundary_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = sentinelsoc_boundary_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    sentinelsoc_boundary_base_sequence seq;
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "=== Starting SENTINELSOC_BOUNDARY UVM Verification Sequence ===", UVM_LOW)
    seq = sentinelsoc_boundary_base_sequence::type_id::create("seq");
    seq.start(env.agent.seqr);
    #100ns;
    `uvm_info(get_type_name(), "=== SENTINELSOC_BOUNDARY Sequence Finished Successfully ===", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
