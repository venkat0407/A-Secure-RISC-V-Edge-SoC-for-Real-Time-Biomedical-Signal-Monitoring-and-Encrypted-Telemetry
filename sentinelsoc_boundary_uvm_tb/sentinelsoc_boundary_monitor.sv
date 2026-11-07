class sentinelsoc_boundary_monitor extends uvm_monitor;
  virtual sentinelsoc_boundary_if vif;
  uvm_analysis_port #(sentinelsoc_boundary_item) ap;

  `uvm_component_utils(sentinelsoc_boundary_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual sentinelsoc_boundary_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface 'sentinelsoc_boundary_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    sentinelsoc_boundary_item item;
    @(posedge vif.rst_n);
    forever begin
      @(posedge vif.clk);
      item = sentinelsoc_boundary_item::type_id::create("item");
      item.uart_rx = vif.uart_rx;
      item.uart_tx = vif.uart_tx;
      item.gpio_io = vif.gpio_io;
      item.adc_sample_data = vif.adc_sample_data;
      item.adc_sample_valid = vif.adc_sample_valid;
      item.alert_led = vif.alert_led;
      item.wdt_reset_n = vif.wdt_reset_n;
      item.core_irq_out = vif.core_irq_out;
      ap.write(item);
    end
  endtask
endclass
