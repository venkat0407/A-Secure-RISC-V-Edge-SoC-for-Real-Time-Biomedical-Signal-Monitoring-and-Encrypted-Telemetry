// ==============================================================================
// Class: wdt_dut_test
// Description: UVM Test orchestrating Watchdog timeout and reset assertion
// ==============================================================================

class wdt_dut_test extends uvm_test;

    wdt_dut_env env;

    `uvm_component_utils(wdt_dut_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = wdt_dut_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        wdt_dut_sequence seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(), "================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting SentinelSoC DUT <-> WDT UVM VIP Test", UVM_LOW)
        `uvm_info(get_type_name(), "  1. DUT CPU configures Watchdog reload counter and enables timer", UVM_LOW)
        `uvm_info(get_type_name(), "  2. DUT CPU feeds watchdog with 0xA55AFEED to test feed strobe", UVM_LOW)
        `uvm_info(get_type_name(), "  3. WDT is permitted to expire, asserting active-low wdt_reset_n", UVM_LOW)
        `uvm_info(get_type_name(), "  4. VIP Monitor verifies active-low reset assertion", UVM_LOW)
        `uvm_info(get_type_name(), "================================================================", UVM_LOW)

        seq = wdt_dut_sequence::type_id::create("seq");
        seq.start(env.agent.seqr);

        #4000ns;
        `uvm_info(get_type_name(), "=== SentinelSoC DUT <-> WDT UVM VIP Verification Finished Successfully ===", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
