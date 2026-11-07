class adc_monitor extends uvm_monitor;
  virtual adc_if vif;
  uvm_analysis_port #(adc_item) ap;

  `uvm_component_utils(adc_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual adc_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface 'adc_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    adc_item item;
    @(posedge vif.rst_n);
    forever begin
      @(posedge vif.clk);
      item = adc_item::type_id::create("item");
      item.adc_sample_data = vif.adc_sample_data;
      item.adc_sample_valid = vif.adc_sample_valid;
      ap.write(item);
    end
  endtask
endclass
