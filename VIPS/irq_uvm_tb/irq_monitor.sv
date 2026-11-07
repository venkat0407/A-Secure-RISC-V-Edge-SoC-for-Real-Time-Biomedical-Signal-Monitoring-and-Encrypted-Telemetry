class irq_monitor extends uvm_monitor;
  virtual irq_if vif;
  uvm_analysis_port #(irq_item) ap;

  `uvm_component_utils(irq_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual irq_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", $sformatf("Virtual interface 'irq_if' not found in config_db for %s", get_full_name()))
    end
  endfunction

  task run_phase(uvm_phase phase);
    irq_item item;
    @(posedge vif.rst_n);
    forever begin
      @(posedge vif.clk);
      item = irq_item::type_id::create("item");
      item.core_irq_out = vif.core_irq_out;
      ap.write(item);
    end
  endtask
endclass
