# ==============================================================================
# SentinelSoC RISC-V SoC — Firmware Makefile
# Target: RISC-V RV32IM / VeeR EL2
# ==============================================================================

CROSS_COMPILE ?= riscv64-unknown-elf-
CC            := $(CROSS_COMPILE)gcc
OBJCOPY       := $(CROSS_COMPILE)objcopy
OBJDUMP       := $(CROSS_COMPILE)objdump
SIZE          := $(CROSS_COMPILE)size

ARCH_FLAGS    := -march=rv32imc -mabi=ilp32
CFLAGS        := $(ARCH_FLAGS) -O0 -g -ffreestanding -nostdlib -Wall -Wextra -I.
LDFLAGS       := -T sentinelsoc.ld -nostdlib -Wl,--gc-sections

TARGET        := sentinelsoc_test
ELF           := $(TARGET).elf
BIN           := $(TARGET).bin
HEX           := $(TARGET).hex
VHX           := $(TARGET).vhx
DUMP          := $(TARGET).dump

SRCS_S        := start.S
SRCS_C        := sentinelsoc_test.c

ifeq ($(shell which $(CC) 2>/dev/null),)
all:
	@echo "[-] $(CC) not found in PATH. Using build_firmware.py..."
	python3 build_firmware.py
else
all: $(ELF) hex vhx bin disassemble size
	@echo "--------------------------------------------------------"
	@echo "SentinelSoC Firmware Build Complete:"
	@echo "  ELF:         $(ELF)"
	@echo "  Binary:      $(BIN)"
	@echo "  Intel HEX:   $(HEX)"
	@echo "  Verilog HEX: $(VHX) (for simulation \$$readmemh)"
	@echo "  Disassembly: $(DUMP)"
	@echo "--------------------------------------------------------"

$(ELF): $(SRCS_S) $(SRCS_C) sentinelsoc.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SRCS_S) $(SRCS_C)
endif

hex: $(HEX)
$(HEX): $(ELF)
	$(OBJCOPY) -O ihex $< $@

vhx: $(VHX)
$(VHX): $(ELF)
	$(OBJCOPY) -O verilog $< $@

bin: $(BIN)
$(BIN): $(ELF)
	$(OBJCOPY) -O binary $< $@

disassemble: $(DUMP)
$(DUMP): $(ELF)
	$(OBJDUMP) -d -S $< > $@

size: $(ELF)
	@echo "=== Firmware Memory Utilization ==="
	$(SIZE) $<

clean:
	rm -f $(ELF) $(BIN) $(HEX) $(VHX) $(DUMP)
	rm -rf build output

help:
	@echo "SentinelSoC Firmware Targets:"
	@echo "  make              - Build all targets (ELF, HEX, VHX, BIN, DUMP)"
	@echo "  make hex          - Generate Intel HEX file ($(HEX))"
	@echo "  make vhx          - Generate Verilog HEX file ($(VHX) for \$$readmemh)"
	@echo "  make bin          - Generate flat binary image ($(BIN))"
	@echo "  make disassemble  - Generate assembly dump ($(DUMP))"
	@echo "  make clean        - Remove all generated files"
