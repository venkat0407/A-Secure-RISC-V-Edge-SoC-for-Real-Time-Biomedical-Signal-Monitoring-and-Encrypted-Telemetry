// ==============================================================================
// Class: adc_dut_test
// Description: UVM Test controlling ADC streaming and DUT synchronization
// ==============================================================================

class adc_dut_test extends uvm_test;

    adc_dut_env env;

    `uvm_component_utils(adc_dut_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = adc_dut_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        adc_dut_sequence seq;
        phase.raise_objection(this);

        `uvm_info(get_type_name(), "================================================================", UVM_LOW)
        `uvm_info(get_type_name(), "  Starting SentinelSoC DUT <-> ADC UVM VIP Interconnect Test", UVM_LOW)
        `uvm_info(get_type_name(), "  1. DUT CPU initializes ADC controller via AXI bus at 0x1000_3000", UVM_LOW)
        `uvm_info(get_type_name(), "  2. VIP Driver streams digitized 12-bit ECG samples with valid strobes", UVM_LOW)
        `uvm_info(get_type_name(), "  3. VIP Monitor & Scoreboard track and verify sample ingress", UVM_LOW)
        `uvm_info(get_type_name(), "================================================================", UVM_LOW)

        seq = adc_dut_sequence::type_id::create("seq");
        seq.start(env.agent.seqr);

        #4000ns;
        `uvm_info(get_type_name(), "=== SentinelSoC DUT <-> ADC UVM VIP Verification Finished Successfully ===", UVM_LOW)
        phase.drop_objection(this);
    endtask

endclass
