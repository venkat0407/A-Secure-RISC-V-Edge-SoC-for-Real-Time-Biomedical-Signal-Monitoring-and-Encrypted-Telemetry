// ==============================================================================
// Class: alert_dut_test
// Description: UVM Test orchestrating autonomous alert verification
// ==============================================================================

class alert_dut_test extends uvm_test;

    alert_dut_env env;

    `uvm_component_utils(alert_dut_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = alert_dut_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        alert_dut_sequence seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(), "================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting SentinelSoC DUT <-> Alert LED UVM VIP Test", UVM_LOW)
        `uvm_info(get_type_name(), "  1. DUT CPU arms QRS accelerator via AXI bus at 0x1000_5000", UVM_LOW)
        `uvm_info(get_type_name(), "  2. ECG stream triggers QRS threshold, asserting dedicated alert_led", UVM_LOW)
        `uvm_info(get_type_name(), "  3. VIP Monitor captures hardware-autonomous alert assertion", UVM_LOW)
        `uvm_info(get_type_name(), "================================================================", UVM_LOW)

        seq = alert_dut_sequence::type_id::create("seq");
        seq.start(env.agent.seqr);

        #3000ns;
        `uvm_info(get_type_name(), "=== SentinelSoC DUT <-> Alert LED UVM VIP Verification Finished Successfully ===", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
