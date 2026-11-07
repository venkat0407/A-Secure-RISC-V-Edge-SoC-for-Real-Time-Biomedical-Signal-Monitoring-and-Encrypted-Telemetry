class wdt_monitor extends uvm_monitor;
  virtual wdt_if vif;
  uvm_analysis_port #(wdt_item) ap;

  `uvm_component_utils(wdt_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual wdt_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface 'wdt_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    wdt_item item;
    @(posedge vif.rst_n);
    forever begin
      @(posedge vif.clk);
      item = wdt_item::type_id::create("item");
      item.wdt_reset_n = vif.wdt_reset_n;
      ap.write(item);
    end
  endtask
endclass
