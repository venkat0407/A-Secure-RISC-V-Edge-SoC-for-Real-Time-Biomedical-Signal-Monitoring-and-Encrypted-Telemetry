class alert_test extends uvm_test;
  alert_env env;

  `uvm_component_utils(alert_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = alert_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    alert_base_sequence seq;
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "=== Starting ALERT UVM Verification Sequence ===", UVM_LOW)
    seq = alert_base_sequence::type_id::create("seq");
    seq.start(env.agent.seqr);
    #100ns;
    `uvm_info(get_type_name(), "=== ALERT Sequence Finished Successfully ===", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
