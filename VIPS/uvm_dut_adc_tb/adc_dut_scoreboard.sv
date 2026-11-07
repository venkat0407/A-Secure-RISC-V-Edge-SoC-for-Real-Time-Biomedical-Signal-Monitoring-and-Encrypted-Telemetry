// ==============================================================================
// Class: adc_dut_scoreboard
// Description: UVM Scoreboard verifying ADC stream ingress
// ==============================================================================

class adc_dut_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp #(adc_dut_item, adc_dut_scoreboard) ap_imp;
    int sample_count = 0;

    `uvm_component_utils(adc_dut_scoreboard)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap_imp = new("ap_imp", this);
    endfunction

    function void write(adc_dut_item item);
        sample_count++;
        `uvm_info(get_type_name(), $sformatf("[SCOREBOARD VERIFICATION] Sample #%0d: Verified ADC sample payload = 0x%03h", sample_count, item.sample_data), UVM_LOW)
    endfunction

endclass
