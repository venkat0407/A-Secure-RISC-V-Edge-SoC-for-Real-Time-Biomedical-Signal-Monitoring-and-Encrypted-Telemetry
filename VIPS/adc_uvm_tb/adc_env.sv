class adc_env extends uvm_env;
  adc_agent      agent;
  adc_scoreboard sb;

  `uvm_component_utils(adc_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = adc_agent::type_id::create("agent", this);
    sb    = adc_scoreboard::type_id::create("sb", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.mon.ap.connect(sb.ap_imp);
  endfunction
endclass
