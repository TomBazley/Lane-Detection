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

#include <stm32g0xx.h>
#include "ice40.h"
#include "ad9983a.h"

#define PIN_SS 4

static uint8_t mode[11] = {
  0x11, 0x12, 0x13, 0x17, //luma
  0x11, 0x12, 0x14, 0x15, 0x27, //edge
  0x16, 0x37 //combined
};

static uint8_t n = 0;

static void send_mode(uint8_t byte) {
  GPIOA->ODR &= ~(1 << PIN_SS);
  send_data(byte);
  while (SPI1->SR & SPI_SR_BSY) { __NOP(); }
  GPIOA->ODR |= (1 << PIN_SS);
  for (int n = 0; n < 1000000; n++) __NOP();
}

int main () {
  RCC->IOPENR |= RCC_IOPENR_GPIOAEN |
                 RCC_IOPENR_GPIOBEN;

  GPIOA->MODER &= ~(3 << 0);
  GPIOA->MODER |= (1 << 0);

  GPIOB->MODER &= ~(3 << (2 * 9));
  GPIOB->PUPDR |= (1 << (2 * 9));

  ad9983a_configure();

  ice40_configure();
  
  send_mode(mode[n]);
  
  while(1) {
    if (!(GPIOB->IDR & (1 << 9))) {
      n = (n + 1 == sizeof(mode) ? 0: n + 1);
      send_mode(mode[n]);
    }
  }
}