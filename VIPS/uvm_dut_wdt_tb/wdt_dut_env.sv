// ==============================================================================
// Class: wdt_dut_env
// Description: UVM Environment for WDT VIP
// ==============================================================================

class wdt_dut_env extends uvm_env;

    wdt_dut_agent      agent;
    wdt_dut_scoreboard sb;

    `uvm_component_utils(wdt_dut_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = wdt_dut_agent::type_id::create("agent", this);
        sb    = wdt_dut_scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(sb.ap_imp);
    endfunction

endclass
