# Copyright 2022 Tom Bazley tombazley@outlook.com
# SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
# 
# Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may
# not use this file except in compliance with the License, or, at your option,
# the Apache License version 2.0. You may obtain a copy of the License at
#
# https://solderpad.org/licenses/SHL-2.1/
#
# Unless required by applicable law or agreed to in writing, any work
# distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

OBJS = ad9983a.o boot.o main.o ice40.o ice40_bin.o vec.o

CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld
AS = arm-none-eabi-as
OBJCOPY = arm-none-eabi-objcopy

CFLAGS += -std=c99 -mcpu=cortex-m0plus -mthumb -Wall -Wextra
LDFLAGS = -Tstm32.ld -mcpu=cortex-m0plus -mthumb -Wl,--gc-sections -lc -lnosys

CFLAGS += -DSTM32G051xx

CFLAGS += -I/opt/STM32/STM32G0
CFLAGS += -I/usr/arm-none-eabi/include/

ifeq ($(DEBUG),1)
CFLAGS += -Og -ggdb -DDEBUG
else
CFLAGS += -O2
endif

stm32.bin: stm32
	$(OBJCOPY) $^ $@ -O binary

stm32: $(OBJS)
	$(CC) $^ -o $@ $(LDFLAGS)

ice40_bin.o: ../iCE40/iCE40_Implmnt/sbt/outputs/bitmap/top_level_bitmap.bin

flash: stm32.bin
	openocd -f openocd.cfg

clean:
	rm -f $(OBJS) stm32 stm32.bin