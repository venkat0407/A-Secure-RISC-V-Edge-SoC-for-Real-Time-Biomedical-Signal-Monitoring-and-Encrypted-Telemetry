class wdt_test extends uvm_test;
  wdt_env env;

  `uvm_component_utils(wdt_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = wdt_env::type_id::create("env", this);
  endfunction

  task run_phase(uvm_phase phase);
    wdt_base_sequence seq;
    phase.raise_objection(this);
    `uvm_info(get_type_name(), "=== Starting WDT UVM Verification Sequence ===", UVM_LOW)
    seq = wdt_base_sequence::type_id::create("seq");
    seq.start(env.agent.seqr);
    #100ns;
    `uvm_info(get_type_name(), "=== WDT Sequence Finished Successfully ===", UVM_LOW)
    phase.drop_objection(this);
  endtask
endclass
