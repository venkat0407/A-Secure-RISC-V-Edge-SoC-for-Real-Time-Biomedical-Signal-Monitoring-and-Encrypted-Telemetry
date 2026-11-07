class sentinelsoc_boundary_driver extends uvm_driver #(sentinelsoc_boundary_item);
  virtual sentinelsoc_boundary_if vif;

  `uvm_component_utils(sentinelsoc_boundary_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual sentinelsoc_boundary_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface 'sentinelsoc_boundary_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    // Initialize driven outputs
    @(posedge vif.rst_n);
    forever begin
      seq_item_port.get_next_item(req);
      @(posedge vif.clk);
      vif.uart_rx <= req.uart_rx;
      vif.gpio_io <= req.gpio_io;
      vif.adc_sample_data <= req.adc_sample_data;
      vif.adc_sample_valid <= req.adc_sample_valid;
      seq_item_port.item_done();
    end
  endtask
endclass
