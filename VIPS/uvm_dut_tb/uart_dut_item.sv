// ==============================================================================
// Class: uart_dut_item
// Description: UVM Sequence Item representing a UART transaction between VIP and DUT
// ==============================================================================

class uart_dut_item extends uvm_sequence_item;

    rand bit [7:0] tx_data;       // Byte to drive from VIP into DUT (uart_rx)
    bit [7:0]      rx_data;       // Byte received from DUT output pin (uart_tx)
    bit            is_from_dut;   // Direction flag: 1 = DUT -> VIP, 0 = VIP -> DUT

    `uvm_object_utils_begin(uart_dut_item)
        `uvm_field_int(tx_data,     UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(rx_data,     UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(is_from_dut, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "uart_dut_item");
        super.new(name);
    endfunction

endclass
