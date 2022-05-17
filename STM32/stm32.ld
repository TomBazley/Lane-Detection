/*
  Copyright 2022 Tom Bazley tombazley@outlook.com
  SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1

  Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may
  not use this file except in compliance with the License, or, at your option,
  the Apache License version 2.0. You may obtain a copy of the License at

  https://solderpad.org/licenses/SHL-2.1/
  
  Unless required by applicable law or agreed to in writing, any work
  distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
  License for the specific language governing permissions and limitations under
  the License.
*/

MEMORY
{
    rom (rx)  : ORIGIN = 0x08000000, LENGTH = 64K
    ram (rwx) : ORIGIN = 0x20000000, LENGTH = 18K
}

SECTIONS
{
    .text :
    {
        . = ALIGN(4);
        KEEP(*(vectors))
        . = ALIGN(4);
        *(.text*)
        KEEP(*(.init))
        KEEP(*(.fini))
        KEEP(*(.eh_frame))
        . = ALIGN(4);
    } > rom

    .rodata :
    {
        . = ALIGN(4);
        ice40_bin_start = .;
        KEEP(*(.ice40_bin*))
        ice40_bin_end = .;
        . = ALIGN(4);
        *(.rodata*)
    } > rom

    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > rom
    .ARM :
    {
        *(.ARM.exidx*)
    } > rom

    _sidata = LOADADDR(.data);

    .data :
    {
        . = ALIGN(4);
        _sdata = .;

        *(.data*)

        . = ALIGN(4);
        _edata = .;
    } >ram AT >rom

    .bss (NOLOAD) :
    {
        . = ALIGN(4);
        _sbss = .;
        __bss_start__ = _sbss;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        _ebss = .;
        __bss_end__ = _ebss;
    } >ram

    end = .;

    .dynamic_allocations :
    {
        . = ALIGN(4);
        _ssystem_ram = .;
        . = . + 1000;
        . = ALIGN(4);
        _esystem_ram = .;
    } > ram

    /DISCARD/ :
    {
        libc.a ( * )
        libm.a ( * )
        libgcc.a ( * )
    }
}
