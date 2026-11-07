class irq_env extends uvm_env;
  irq_agent      agent;
  irq_scoreboard sb;

  `uvm_component_utils(irq_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = irq_agent::type_id::create("agent", this);
    sb    = irq_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.mon.ap.connect(sb.ap_imp);
  endfunction
endclass
