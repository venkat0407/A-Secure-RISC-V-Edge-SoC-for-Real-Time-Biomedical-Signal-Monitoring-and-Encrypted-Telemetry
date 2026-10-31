# ==============================================================================
# SentinelSoC — Simulation Filelist for VCS / QuestaSim / ModelSim
# ==============================================================================

# Simulation Defines
+define+SIMULATION
+define+RV_BUILD_AXI4

# Top-level Module
-top tb_sentinelsoc_top

# Include Directories
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

# ==============================================================================
# 1. AXI4 Interconnect Fabric
# ==============================================================================
../rtl/interconnect/arbiter.v
../rtl/interconnect/priority_encoder.v
../rtl/interconnect/axi_interconnect.v
../rtl/interconnect/sentinelsoc_axi_interconnect_3x11.v

# ==============================================================================
# 2. Common AXI Bridges & Adapters
# ==============================================================================
../rtl/common/axi4lite_slave_adapter.sv
../rtl/common/axi4_to_axi4lite_bridge.sv
../rtl/common/axi_dummy_slave.sv

# ==============================================================================
# 3. CPU Core Wrapper & On-Chip Memories
# ==============================================================================
../rtl/riscv/axi_imem_slave.sv
../rtl/riscv/axi_dmem_slave.sv
../rtl/riscv/el2_veer_wrapper.v

# ==============================================================================
# 4. Peripherals (M00 - M08)
# ==============================================================================
# M00: UART Controller
../rtl/uart/axi_internal_fifo.v
../rtl/uart/uart_parity_bit_compute.v
../rtl/uart/uart_receiver.v
../rtl/uart/uart_transmitter.v
../rtl/uart/uart_controller.v
../rtl/uart/axi_uart_top.v

# M01: Hardware Timer
../rtl/timer/timer_core.sv
../rtl/timer/timer_regs.sv
../rtl/timer/timer_axi.sv

# M02: GPIO Subsystem
../rtl/gpio/gpio_bit.sv
../rtl/gpio/gpio_regs.sv
../rtl/gpio/gpio_wrapper.sv
../rtl/gpio/gpio_axi.sv

# M03: 12-Bit SAR ADC Interface
../rtl/ADC/adc_pkg.sv
../rtl/ADC/adc_fifo.sv
../rtl/ADC/adc_sample_acquisition.sv
../rtl/ADC/adc_sampling_scheduler.sv
../rtl/ADC/adc_registers.sv
../rtl/ADC/adc_axi_lite_slave.sv
../rtl/ADC/adc_controller.sv

# M04: 16-Tap FIR Filter Engine
../rtl/FIR/axis_fifo.v
../rtl/FIR/fir_axi_lite.v
../rtl/FIR/fir_dsp.v
../rtl/FIR/fir_top.v

# M05: QRS Detection Engine
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

# M06: AES-128 Encryption Engine
../rtl/AES/aes_sbox.v
../rtl/AES/aes_rcon.v
../rtl/AES/aes_key_expand_128.v
../rtl/AES/aes_cipher_top.v
../rtl/AES/axi_aes_cipher_slave.v

# M07: Watchdog Timer (WDT)
../rtl/wdt/wdt_axi.sv

# M08: Interrupt Aggregator
../rtl/interrupt/interrupt_aggregator.sv

# ==============================================================================
# 5. Top-Level SoC Integration
# ==============================================================================
../rtl/sentinelsoc_top.sv

# ==============================================================================
# 6. Testbench
# ==============================================================================
../tb/tb_sentinelsoc_top.sv
