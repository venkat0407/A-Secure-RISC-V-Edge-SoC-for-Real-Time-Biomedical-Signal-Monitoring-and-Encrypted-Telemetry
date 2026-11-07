class wdt_driver extends uvm_driver #(wdt_item);
  virtual wdt_if vif;

  `uvm_component_utils(wdt_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual wdt_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface 'wdt_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    // Initialize driven outputs
    @(posedge vif.rst_n);
    forever begin
      seq_item_port.get_next_item(req);
      @(posedge vif.clk);
      seq_item_port.item_done();
    end
  endtask
endclass
