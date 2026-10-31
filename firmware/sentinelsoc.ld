/* ============================================================================
 * sentinelsoc.ld — Authoritative Linker Script for SentinelSoC RISC-V SoC
 * Target: RISC-V RV32IM / VeeR EL2
 * 
 * Memory Layout:
 *   IMEM (Instruction SRAM): Base 0x00000000, Size 64 KB (0x00000000 - 0x0000FFFF)
 *   DMEM (Data SRAM)       : Base 0x00010000, Size 64 KB (0x00010000 - 0x0001FFFF)
 * 
 * Stack Top: 0x00018000 (32 KB allocated for BSS/Data, 32 KB for Stack)
 * ============================================================================ */

OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    IMEM (rx)  : ORIGIN = 0x00000000, LENGTH = 64K
    DMEM (rwx) : ORIGIN = 0x00010000, LENGTH = 64K
}

SECTIONS
{
    .text : {
        . = ALIGN(4);
        KEEP(*(.text.init))
        *(.text .text.*)
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
        . = ALIGN(4);
        _etext = .;
    } > IMEM

    .data : {
        . = ALIGN(4);
        _sdata = .;
        __global_pointer$ = . + 0x800;
        *(.data .data.*)
        *(.sdata .sdata.*)
        . = ALIGN(4);
        _edata = .;
    } > DMEM AT > IMEM
    
    _sidata = LOADADDR(.data);

    .bss (NOLOAD) : {
        . = ALIGN(4);
        _sbss = .;
        *(.sbss .sbss.*)
        *(.bss .bss.*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
    } > DMEM

    .stack (NOLOAD) : {
        . = ALIGN(16);
        _stack_bottom = .;
        . = ORIGIN(DMEM) + 0x8000;
        _stack_top = .;
    } > DMEM

    _end = .;

    /DISCARD/ : {
        *(.eh_frame)
        *(.comment)
    }
}
