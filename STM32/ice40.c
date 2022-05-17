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

#define PIN_SS     4
#define PIN_SCK    5
#define PIN_SDO    6
#define PIN_SDI    7
#define PIN_RESET  0
#define LED  0

extern char ice40_bin_start, ice40_bin_end;

static void gpio_config(GPIO_TypeDef* GPIOx, int pin, int mode) {
  GPIOx->MODER &= ~(3 << (2 * pin));
  GPIOx->MODER |= (mode << (2 * pin));
}

void send_data(uint8_t data) {
  while (!(SPI1->SR & SPI_SR_TXE)) {
		__NOP();
	}

	*(uint8_t *) &SPI1->DR = data;
}

void ice40_configure() {
  RCC->APBENR2 |= RCC_APBENR2_SPI1EN;

  gpio_config(GPIOB, PIN_RESET, 1);
  gpio_config(GPIOA, PIN_SS, 1);
  gpio_config(GPIOA, PIN_SCK, 2);
  gpio_config(GPIOA, PIN_SDO, 0); //not used
  gpio_config(GPIOA, PIN_SDI, 2);

  GPIOA->AFR[0] |= (0 << GPIO_AFRL_AFSEL5_Pos) |
                   (0 << GPIO_AFRL_AFSEL7_Pos);

  SPI1->CR1 |= SPI_CR1_SSI | SPI_CR1_SSM | SPI_CR1_MSTR | SPI_CR1_CPOL |
               SPI_CR1_CPHA | SPI_CR1_BR_2;
	SPI1->CR1 |= SPI_CR1_SPE;

  GPIOB->ODR &= ~(1 << PIN_RESET);
  GPIOA->ODR &= ~(1 << PIN_SS);
  GPIOA->ODR |= (1 << LED);

  RCC->APBENR1 |= RCC_APBENR1_TIM2EN;

  TIM2->CR1 |= TIM_CR1_CEN;
  TIM2->EGR |= TIM_EGR_UG;

	for (int n = 0; n < 1000000; n++) __NOP();
  
  GPIOB->ODR |= (1 << PIN_RESET);

	for (int n = 0; n < 1000000; n++) __NOP();

  GPIOA->ODR |= (1 << PIN_SS);

  send_data(0x55); //dummy byte
  
	while (SPI1->SR & SPI_SR_BSY) { __NOP(); }

  GPIOA->ODR &= ~(1 << PIN_SS);

  for (char *c = &ice40_bin_start; c < &ice40_bin_end; c++) {
    send_data(*c);
  }

	while (SPI1->SR & SPI_SR_BSY) { __NOP(); }

  GPIOA->ODR |= (1 << PIN_SS);

  for(int n = 0; n < 100; n++) { //max 100 clock cycles
    send_data(0x55);
  }

  GPIOA->ODR &= ~(1 << LED);
  TIM2->CR1 &= ~TIM_CR1_CEN;
}
