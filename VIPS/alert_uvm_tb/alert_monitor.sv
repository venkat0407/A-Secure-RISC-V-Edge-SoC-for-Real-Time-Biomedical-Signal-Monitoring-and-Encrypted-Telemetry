class alert_monitor extends uvm_monitor;
  virtual alert_if vif;
  uvm_analysis_port #(alert_item) ap;

  `uvm_component_utils(alert_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual alert_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface 'alert_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    alert_item item;
    @(posedge vif.rst_n);
    forever begin
      @(posedge vif.clk);
      item = alert_item::type_id::create("item");
      item.alert_led = vif.alert_led;
      ap.write(item);
    end
  endtask
endclass
