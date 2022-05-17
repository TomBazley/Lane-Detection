// Copyright 2022 Tom Bazley tombazley@outlook.com
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
// 
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may
// not use this file except in compliance with the License, or, at your option,
// the Apache License version 2.0. You may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work
// distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
// License for the specific language governing permissions and limitations under
// the License.

#include <string.h>

static inline void copy_data() {
	extern char _sdata, _edata, _sidata;

	memcpy(&_sdata, &_sidata, &_edata - &_sdata);
}

static inline void clear_bss() {
	extern char _sbss, _ebss;

	memset(&_sbss, 0, &_ebss - &_sbss);
}

void reset () {
	extern int main();
	extern void __libc_init_array();

	copy_data();
	clear_bss();

	__libc_init_array();

	main();

	while (1) {
		__asm__ __volatile__("WFI");
	}
}
