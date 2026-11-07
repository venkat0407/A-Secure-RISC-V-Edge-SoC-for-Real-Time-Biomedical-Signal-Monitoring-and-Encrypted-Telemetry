// ==============================================================================
// Class: boundary_dut_env
// Description: UVM Environment for Unified Boundary VIP
// ==============================================================================

class boundary_dut_env extends uvm_env;

    boundary_dut_agent      agent;
    boundary_dut_scoreboard sb;

    `uvm_component_utils(boundary_dut_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = boundary_dut_agent::type_id::create("agent", this);
        sb    = boundary_dut_scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.mon.ap.connect(sb.ap_imp);
    endfunction

endclass
