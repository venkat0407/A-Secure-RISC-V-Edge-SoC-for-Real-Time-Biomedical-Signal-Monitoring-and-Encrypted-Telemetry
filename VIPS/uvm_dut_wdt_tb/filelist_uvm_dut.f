# ==============================================================================
# Filelist for SentinelSoC DUT + WDT UVM VIP Verification with Verdi FSDB Support
# ==============================================================================

+define+SIMULATION
+define+RV_BUILD_AXI4
+define+FSDB

-top tb_top

+incdir+../rtl/interconnect
+incdir+../rtl/uart/include
+incdir+../rtl/ADC
+incdir+../rtl/FIR
+incdir+../rtl/QRS
+incdir+../rtl/AES
+incdir+../rtl/wdt
+incdir+../rtl/interrupt
+incdir+../rtl/gpio
+incdir+../rtl/timer
+incdir+../rtl/common
+incdir+../rtl/riscv
+incdir+../firmware
+incdir+../tb
+incdir+.

# 1. Interconnect
../rtl/interconnect/arbiter.v
../rtl/interconnect/priority_encoder.v
../rtl/interconnect/axi_interconnect.v
../rtl/interconnect/sentinelsoc_axi_interconnect_3x11.v

# 2. Common Bridges
../rtl/common/axi4lite_slave_adapter.sv
../rtl/common/axi4_to_axi4lite_bridge.sv
../rtl/common/axi_dummy_slave.sv

# 3. CPU Core & Memories
../rtl/riscv/axi_imem_slave.sv
../rtl/riscv/axi_dmem_slave.sv
../rtl/riscv/el2_veer_wrapper.v

# 4. Peripherals
../rtl/uart/axi_internal_fifo.v
../rtl/uart/uart_parity_bit_compute.v
../rtl/uart/uart_receiver.v
../rtl/uart/uart_transmitter.v
../rtl/uart/uart_controller.v
../rtl/uart/axi_uart_top.v

../rtl/timer/timer_core.sv
../rtl/timer/timer_regs.sv
../rtl/timer/timer_axi.sv

../rtl/gpio/gpio_bit.sv
../rtl/gpio/gpio_regs.sv
../rtl/gpio/gpio_wrapper.sv
../rtl/gpio/gpio_axi.sv

../rtl/ADC/adc_pkg.sv
../rtl/ADC/adc_fifo.sv
../rtl/ADC/adc_sample_acquisition.sv
../rtl/ADC/adc_sampling_scheduler.sv
../rtl/ADC/adc_registers.sv
../rtl/ADC/adc_axi_lite_slave.sv
../rtl/ADC/adc_controller.sv

../rtl/FIR/axis_fifo.v
../rtl/FIR/fir_axi_lite.v
../rtl/FIR/fir_dsp.v
../rtl/FIR/fir_top.v

../rtl/QRS/baseline_filter.v
../rtl/QRS/first_difference.v
../rtl/QRS/icg_generic.v
../rtl/QRS/moving_sum12.v
../rtl/QRS/moving_sum20.v
../rtl/QRS/pow2_normalizer.v
../rtl/QRS/rr_classifier.v
../rtl/QRS/schmitt_peak_detector.v
../rtl/QRS/search_back.v
../rtl/QRS/shannon_lut12.v
../rtl/QRS/square10.v
../rtl/QRS/ecg_wtsee_v6_top.v
../rtl/QRS/qrs_axi4_wrapper.v

../rtl/AES/aes_sbox.v
../rtl/AES/aes_rcon.v
../rtl/AES/aes_key_expand_128.v
../rtl/AES/aes_cipher_top.v
../rtl/AES/axi_aes_cipher_slave.v

../rtl/wdt/wdt_axi.sv
../rtl/interrupt/interrupt_aggregator.sv

# 5. Top-Level DUT Integration
../rtl/sentinelsoc_top.sv

# 6. WDT UVM VIP & Testbench Files
wdt_dut_if.sv
wdt_dut_pkg.sv
tb_top.sv
