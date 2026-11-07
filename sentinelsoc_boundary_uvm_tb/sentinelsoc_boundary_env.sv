class sentinelsoc_boundary_env extends uvm_env;
  sentinelsoc_boundary_agent      agent;
  sentinelsoc_boundary_scoreboard sb;

  `uvm_component_utils(sentinelsoc_boundary_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = sentinelsoc_boundary_agent::type_id::create("agent", this);
    sb    = sentinelsoc_boundary_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.mon.ap.connect(sb.ap_imp);
  endfunction
endclass
