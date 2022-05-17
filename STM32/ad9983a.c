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
#include "ad9983a.h"

/******************************/
/* Control register addresses */
/******************************/

#define CONV_ADDR_RO_CHIP_REV           0x00
#define CONV_ADDR_PLL_DIV_H             0x01
#define CONV_ADDR_PLL_DIV_L             0x02
#define CONV_ADDR_VCO_CPMP              0x03
#define CONV_ADDR_PHA_ADJ               0x04
#define CONV_ADDR_RED_GAIN              0x05
#define CONV_ADDR_RED_GAIN_F            0x06
#define CONV_ADDR_GRN_GAIN              0x07
#define CONV_ADDR_GRN_GAIN_F            0x08
#define CONV_ADDR_BLU_GAIN              0x09
#define CONV_ADDR_BLU_GAIN_F            0x0a
#define CONV_ADDR_RED_OFFSET_H          0x0b
#define CONV_ADDR_RED_OFFSET_L          0x0c
#define CONV_ADDR_GRN_OFFSET_H          0x0d
#define CONV_ADDR_GRN_OFFSET_L          0x0e
#define CONV_ADDR_BLU_OFFSET_H          0x0f
#define CONV_ADDR_BLU_OFFSET_L          0x10
#define CONV_ADDR_SYNC_THRESH           0x11
#define CONV_ADDR_HSYNC_CTRL            0x12
#define CONV_ADDR_HSYNC_DUR             0x13
#define CONV_ADDR_VSYNC_CTRL            0x14
#define CONV_ADDR_VSYNC_DUR             0x15
#define CONV_ADDR_PRECOAST              0x16
#define CONV_ADDR_POSTCOAST             0x17
#define CONV_ADDR_COAST_CLAMP           0x18
#define CONV_ADDR_CLAMP_PLCMNT          0x19
#define CONV_ADDR_CLAMP_DUR             0x1a
#define CONV_ADDR_CLAMP_OFFSET          0x1b
#define CONV_ADDR_TESTREG0              0x1c
#define CONV_ADDR_SOG_CTRL              0x1d
#define CONV_ADDR_PWR                   0x1e
#define CONV_ADDR_OUT_SEL_1             0x1f
#define CONV_ADDR_OUT_SEL_2             0x20
#define CONV_ADDR_SYNC_FILT_WIDTH       0x23
#define CONV_ADDR_RO_SYNC_DTCT          0x24
#define CONV_ADDR_RO_SYNC_POL_DTCT      0x25
#define CONV_ADDR_RO_HSYNC_P_VSYNC_H    0x26
#define CONV_ADDR_RO_HSYNC_P_VSYNC_L    0x27
#define CONV_ADDR_TESTREG1              0x28
#define CONV_ADDR_TESTREG2              0x29
#define CONV_ADDR_RO_TESTREG3           0x2a
#define CONV_ADDR_RO_TESTREG4           0x2b
#define CONV_ADDR_OFFSET_HOLD           0x2c
#define CONV_ADDR_TESTREG5              0x2d
#define CONV_ADDR_TESTREG6              0x2e
#define CONV_ADDR_SOG_FILT              0x34
#define CONV_ADDR_VCO_GEAR              0x36
#define CONV_ADDR_AUTO_GAIN             0x3c


/*********************/
/* Control registers */
/*********************/

/* CONV_ADDR_PLL_DIV_L 0x02 */
#define CONV_CR_PLL_DIV_L_Pos           (4)
#define CONV_CR_PLL_DIV_L_Msk           (0xf << CONV_CR_PLL_DIV_L_Pos)
#define CONV_CR_PLL_DIV_L               CONV_CR_PLL_DIV_L_Msk


/* CONV_ADDR_VCO_CPMP 0x03 */
#define CONV_CR_VCO_RNG_Pos             (6)
#define CONV_CR_VCO_RNG_Msk             (0x3 << CONV_CR_VCO_RNG_Pos)
#define CONV_CR_VCO_RNG                 CONV_CR_VCO_RNG_Msk

#define CONV_CR_CP_CURRENT_Pos          (3)
#define CONV_CR_CP_CURRENT_Msk          (0x7 << CONV_CR_CP_CURRENT_Pos)
#define CONV_CR_CP_CURRENT              CONV_CR_CP_CURRENT_Msk

#define CONV_CR_EXT_CLK_EN_Pos          (2)
#define CONV_CR_EXT_CLK_EN_Msk          (0x1 << CONV_CR_EXT_CLK_EN_Pos)
#define CONV_CR_EXT_CLK_EN              CONV_CR_EXT_CLK_EN_Msk


/* CONV_ADDR_PHA_ADJ 0x04 */
#define CONV_CR_PHA_ADJ_Pos             (3)
#define CONV_CR_PHA_ADJ_Msk             (0x1f << CONV_CR_PHA_ADJ_Pos)
#define CONV_CR_PHA_ADJ                 CONV_CR_PHA_ADJ_Msk


/* CONV_ADDR_RED_GAIN 0x05 */
#define CONV_CR_RED_GAIN_Msk            (0x7f)
#define CONV_CR_RED_GAIN                CONV_CR_RED_GAIN_Msk


/* CONV_ADDR_GRN_GAIN 0x07 */
#define CONV_CR_GRN_GAIN_Msk            (0x7f)
#define CONV_CR_GRN_GAIN                CONV_CR_GRN_GAIN_Msk


/* CONV_ADDR_BLU_GAIN 0x09 */
#define CONV_CR_BLU_Msk                 (0x7f << CONV_CR_BLU_Pos)
#define CONV_CR_BLU                     CONV_CR_BLU_Msk


/* CONV_ADDR_RED_OFFSET_L 0x0c */
#define CONV_CR_RED_OFFSET_L_Pos        (7)
#define CONV_CR_RED_OFFSET_L_Msk        (0x1 << CONV_CR_RED_OFFSET_L_Pos)
#define CONV_CR_RED_OFFSET_L            CONV_CR_RED_OFFSET_L_Msk


/* CONV_ADDR_GRN_OFFSET_L 0x0e */
#define CONV_CR_GRN_OFFSET_L_Pos        (7)
#define CONV_CR_GRN_OFFSET_L_Msk        (0x1 << CONV_CR_GRN_OFFSET_L_Pos)
#define CONV_CR_GRN_OFFSET_L            CONV_CR_GRN_OFFSET_L_Msk


/* CONV_ADDR_BLU_OFFSET_L 0x10 */
#define CONV_CR_BLU_OFFSET_L_Pos        (7)
#define CONV_CR_BLU_OFFSET_L_Msk        (0x1 << CONV_CR_BLU_OFFSET_L_Pos)
#define CONV_CR_BLU_OFFSET_L            CONV_CR_BLU_OFFSET_L_Msk


/* CONV_ADDR_HSYNC_CTRL 0x12 */
#define CONV_CR_HSYNC_OVRID_Pos         (7)
#define CONV_CR_HSYNC_OVRID_Msk         (0x1 << CONV_CR_HSYNC_OVRID_Pos)
#define CONV_CR_HSYNC_OVRID             CONV_CR_HSYNC_OVRID_Msk

#define CONV_CR_HSYNC_SOURCE_Pos        (6)
#define CONV_CR_HSYNC_SOURCE_Msk        (0x1 << CONV_CR_HSYNC_SOURCE_Pos)
#define CONV_CR_HSYNC_SOURCE            CONV_CR_HSYNC_SOURCE_Msk

#define CONV_CR_HSYNC_IN_POL_OVRID_Pos  (5)
#define CONV_CR_HSYNC_IN_POL_OVRID_Msk  (0x1 << CONV_CR_HSYNC_IN_POL_OVRID_Pos)
#define CONV_CR_HSYNC_IN_POL_OVRID      CONV_CR_HSYNC_IN_POL_OVRID_Msk

#define CONV_CR_HSYNC_IN_POL_Pos        (4)
#define CONV_CR_HSYNC_IN_POL_Msk        (0x1 << CONV_CR_HSYNC_IN_POL_Pos)
#define CONV_CR_HSYNC_IN_POL            CONV_CR_HSYNC_IN_POL_Msk

#define CONV_CR_HSYNC_OUT_POL_Pos       (3)
#define CONV_CR_HSYNC_OUT_POL_Msk       (0x1 << CONV_CR_HSYNC_OUT_POL_Pos)
#define CONV_CR_HSYNC_OUT_POL           CONV_CR_HSYNC_OUT_POL_Msk


/* CONV_ADDR_VSYNC_CTRL 0x14 */
#define CONV_CR_VSYNC_OVRID_Pos         (7)
#define CONV_CR_VSYNC_OVRID_Msk         (0x1 << CONV_CR_VSYNC_OVRID_Pos)
#define CONV_CR_VSYNC_OVRID             CONV_CR_VSYNC_OVRID_Msk

#define CONV_CR_VSYNC_SOURCE_Pos        (6)
#define CONV_CR_VSYNC_SOURCE_Msk        (0x1 << CONV_CR_VSYNC_SOURCE_Pos)
#define CONV_CR_VSYNC_SOURCE            CONV_CR_VSYNC_SOURCE_Msk

#define CONV_CR_VSYNC_IN_POL_OVRID_Pos  (5)
#define CONV_CR_VSYNC_IN_POL_OVRID_Msk  (0x1 << CONV_CR_VSYNC_IN_POL_OVRID_Pos)
#define CONV_CR_VSYNC_IN_POL_OVRID      CONV_CR_VSYNC_IN_POL_OVRID_Msk

#define CONV_CR_VSYNC_IN_POL_Pos        (4)
#define CONV_CR_VSYNC_IN_POL_Msk        (0x1 << CONV_CR_VSYNC_IN_POL_Pos)
#define CONV_CR_VSYNC_IN_POL            CONV_CR_VSYNC_IN_POL_Msk

#define CONV_CR_VSYNC_OUT_POL_Pos       (3)
#define CONV_CR_VSYNC_OUT_POL_Msk       (0x1 << CONV_CR_VSYNC_OUT_POL_Pos)
#define CONV_CR_VSYNC_OUT_POL           CONV_CR_VSYNC_OUT_POL_Msk

#define CONV_CR_VSYNC_FILT_EN_Pos       (2)
#define CONV_CR_VSYNC_FILT_EN_Msk       (0x1 << CONV_CR_VSYNC_FILT_EN_Pos)
#define CONV_CR_VSYNC_FILT_EN           CONV_CR_VSYNC_FILT_EN_Msk

#define CONV_CR_VSYNC_DUR_EN_Pos        (1)
#define CONV_CR_VSYNC_DUR_EN_Msk        (0x1 << CONV_CR_VSYNC_DUR_EN_Pos)
#define CONV_CR_VSYNC_DUR_EN            CONV_CR_VSYNC_DUR_EN_Msk


/* CONV_ADDR_COAST_CLAMP 0x18 */
#define CONV_CR_COAST_SOURCE_Pos        (7)
#define CONV_CR_COAST_SOURCE_Msk        (0x1 << CONV_CR_COAST_SOURCE_Pos)
#define CONV_CR_COAST_SOURCE            CONV_CR_COAST_SOURCE_Msk

#define CONV_CR_COAST_POL_OVRID_Pos     (6)
#define CONV_CR_COAST_POL_OVRID_Msk     (0x1 << CONV_CR_COAST_POL_OVRID_Pos)
#define CONV_CR_COAST_POL_OVRID         CONV_CR_COAST_POL_OVRID_Msk

#define CONV_CR_COAST_IN_POL_Pos        (5)
#define CONV_CR_COAST_IN_POL_Msk        (0x1 << CONV_CR_COAST_IN_POL_Pos)
#define CONV_CR_COAST_IN_POL            CONV_CR_COAST_IN_POL_Msk

#define CONV_CR_CLAMP_SRC_SEL_Pos       (4)
#define CONV_CR_CLAMP_SRC_SEL_Msk       (0x1 << CONV_CR_CLAMP_SRC_SEL_Pos)
#define CONV_CR_CLAMP_SRC_SEL           CONV_CR_CLAMP_SRC_SEL_Msk

#define CONV_CR_RED_CLAMP_SEL_Pos       (3)
#define CONV_CR_RED_CLAMP_SEL_Msk       (0x1 << CONV_CR_RED_CLAMP_SEL_Pos)
#define CONV_CR_RED_CLAMP_SEL           CONV_CR_RED_CLAMP_SEL_Msk

#define CONV_CR_GRN_CLAMP_SEL_Pos       (2)
#define CONV_CR_GRN_CLAMP_SEL_Msk       (0x1 << CONV_CR_GRN_CLAMP_SEL_Pos)
#define CONV_CR_GRN_CLAMP_SEL           CONV_CR_GRN_CLAMP_SEL_Msk

#define CONV_CR_BLU_CLAMP_SEL_Pos       (1)
#define CONV_CR_BLU_CLAMP_SEL_Msk       (0x1 << CONV_CR_BLU_CLAMP_SEL_Pos)
#define CONV_CR_BLU_CLAMP_SEL           CONV_CR_BLU_CLAMP_SEL_Msk


/* CONV_ADDR_CLAMP_OFFSET 0x1b */
#define CONV_CR_EXT_CLAMP_POL_OVRID_Pos (7)
#define CONV_CR_EXT_CLAMP_POL_OVRID_Msk (0x1 << CONV_CR_EXT_CLAMP_POL_OVRID_Pos)
#define CONV_CR_EXT_CLAMP_POL_OVRID     CONV_CR_EXT_CLAMP_POL_OVRID_Msk

#define CONV_CR_EXT_CLAMP_POL_Pos       (6)
#define CONV_CR_EXT_CLAMP_POL_Msk       (0x1 << CONV_CR_EXT_CLAMP_POL_Pos)
#define CONV_CR_EXT_CLAMP_POL           CONV_CR_EXT_CLAMP_POL_Msk

#define CONV_CR_AUTO_OFFSET_EN_Pos      (5)
#define CONV_CR_AUTO_OFFSET_EN_Msk      (0x1 << CONV_CR_AUTO_OFFSET_EN_Pos)
#define CONV_CR_AUTO_OFFSET_EN          CONV_CR_AUTO_OFFSET_EN_Msk

#define CONV_CR_AO_FREQ_Pos             (3)
#define CONV_CR_AO_FREQ_Msk             (0x3 << CONV_CR_AO_FREQ_Pos)
#define CONV_CR_AO_FREQ                 CONV_CR_AO_FREQ_Msk

#define CONV_CR_CLAMP_OFFSET_011_Msk    (0x7)
#define CONV_CR_CLAMP_OFFSET_011        CONV_CR_CLAMP_OFFSET_011_Msk


/* CONV_ADDR_SOG_CTRL 0x1d */
#define CONV_CR_SOG_SLICER_THRESH_Pos   (3)
#define CONV_CR_SOG_SLICER_THRESH_Msk   (0x1f << CONV_CR_SOG_SLICER_THRESH_Pos)
#define CONV_CR_SOG_SLICER_THRESH       CONV_CR_SOG_SLICER_THRESH_Msk

#define CONV_CR_SOGOUT_POL_Pos          (2)
#define CONV_CR_SOGOUT_POL_Msk          (0x1 << CONV_CR_SOGOUT_POL_Pos)
#define CONV_CR_SOGOUT_POL              CONV_CR_SOGOUT_POL_Msk

#define CONV_CR_SOGOUT_SEL_Msk          (0x3)
#define CONV_CR_SOGOUT_SEL              CONV_CR_SOGOUT_SEL_Msk


/* CONV_ADDR_PWR 0x1e */
#define CONV_CR_CH_SEL_OVRID_Pos        (7)
#define CONV_CR_CH_SEL_OVRID_Msk        (0x1 << CONV_CR_CH_SEL_OVRID_Pos)
#define CONV_CR_CH_SEL_OVRID            CONV_CR_CH_SEL_OVRID_Msk

#define CONV_CR_CH_SEL_Pos              (6)
#define CONV_CR_CH_SEL_Msk              (0x1 << CONV_CR_CH_SEL_Pos)
#define CONV_CR_CH_SEL                  CONV_CR_CH_SEL_Msk

#define CONV_CR_BANDWIDTH_Pos           (5)
#define CONV_CR_BANDWIDTH_Msk           (0x1 << CONV_CR_BANDWIDTH_Pos)
#define CONV_CR_BANDWIDTH               CONV_CR_BANDWIDTH_Msk

#define CONV_CR_PWR_DWN_CTR_SEL_Pos     (4)
#define CONV_CR_PWR_DWN_CTR_SEL_Msk     (0x1 << CONV_CR_PWR_DWN_CTR_SEL_Pos)
#define CONV_CR_PWR_DWN_CTR_SEL         CONV_CR_PWR_DWN_CTR_SEL_Msk

#define CONV_CR_PWR_DWN_Pos             (3)
#define CONV_CR_PWR_DWN_Msk             (0x1 << CONV_CR_PWR_DWN_Pos)
#define CONV_CR_PWR_DWN                 CONV_CR_PWR_DWN_Msk

#define CONV_CR_PWR_DWN_POL_Pos         (2)
#define CONV_CR_PWR_DWN_POL_Msk         (0x1 << CONV_CR_PWR_DWN_POL_Pos)
#define CONV_CR_PWR_DWN_POL             CONV_CR_PWR_DWN_POL_Msk

#define CONV_CR_PWR_DWN_FST_CTRL_Pos    (1)
#define CONV_CR_PWR_DWN_FST_CTRL_Msk    (0x1 << CONV_CR_PWR_DWN_FST_CTRL_Pos)
#define CONV_CR_PWR_DWN_FST_CTRL        CONV_CR_PWR_DWN_FST_CTRL_Msk

#define CONV_CR_SOGOUT_H_Z_CTRL_Msk     (0x1)
#define CONV_CR_SOGOUT_H_Z_CTRL         CONV_CR_SOGOUT_H_Z_CTRL_Msk


/* CONV_ADDR_OUT_SEL_1 0x1f */
#define CONV_CR_OUTPUT_MODE_Pos         (5)
#define CONV_CR_OUTPUT_MODE_Msk         (0x7 << CONV_CR_OUTPUT_MODE_Pos)
#define CONV_CR_OUTPUT_MODE             CONV_CR_OUTPUT_MODE_Msk

#define CONV_CR_PRIMARY_OUT_EN_Pos      (4)
#define CONV_CR_PRIMARY_OUT_EN_Msk      (0x1 << CONV_CR_PRIMARY_OUT_EN_Pos)
#define CONV_CR_PRIMARY_OUT_EN          CONV_CR_PRIMARY_OUT_EN_Msk

#define CONV_CR_SECONDARY_OUT_EN_Pos    (3)
#define CONV_CR_SECONDARY_OUT_EN_Msk    (0x1 << CONV_CR_SECONDARY_OUT_EN_Pos)
#define CONV_CR_SECONDARY_OUT_EN        CONV_CR_SECONDARY_OUT_EN_Msk

#define CONV_CR_OUT_DRIVE_STRENGTH_Pos  (1)
#define CONV_CR_OUT_DRIVE_STRENGTH_Msk  (0x3 << CONV_CR_OUT_DRIVE_STRENGTH_Pos)
#define CONV_CR_OUT_DRIVE_STRENGTH      CONV_CR_OUT_DRIVE_STRENGTH_Msk

#define CONV_CR_OUT_CLK_INV_Msk         (0x1)
#define CONV_CR_OUT_CLK_INV             CONV_CR_OUT_CLK_INV_Msk


/* CONV_ADDR_OUT_SEL_2 0x20 */
#define CONV_CR_OUT_CLK_SEL_Pos         (6)
#define CONV_CR_OUT_CLK_SEL_Msk         (0x2 << CONV_CR_OUT_CLK_SEL_Pos)
#define CONV_CR_OUT_CLK_SEL             CONV_CR_OUT_CLK_SEL_Msk

#define CONV_CR_OUT_H_Z_Pos             (5)
#define CONV_CR_OUT_H_Z_Msk             (0x1 << CONV_CR_OUT_H_Z_Pos)
#define CONV_CR_OUT_H_Z                 CONV_CR_OUT_H_Z_Msk

#define CONV_CR_SOGOUT_H_Z_Pos          (4)
#define CONV_CR_SOGOUT_H_Z_Msk          (0x1 << CONV_CR_SOG_H_Z_Pos)
#define CONV_CR_SOGOUT_H_Z              CONV_CR_SOG_H_Z_Msk

#define CONV_CR_FIELD_OUT_POL_Pos       (3)
#define CONV_CR_FIELD_OUT_POL_Msk       (0x1 << CONV_CR_FIELD_OUT_POL_Pos)
#define CONV_CR_FIELD_OUT_POL           CONV_CR_FIELD_OUT_POL_Msk

#define CONV_CR_PLL_SYNC_FILT_EN_Pos    (2)
#define CONV_CR_PLL_SYNC_FILT_EN_Msk    (0x1 << CONV_CR_PLL_SYNC_FILT_EN_Pos)
#define CONV_CR_PLL_SYNC_FILT_EN        CONV_CR_PLL_SYNC_FILT_EN_Msk

#define CONV_CR_SYNC_PROC_SEL_Pos       (1)
#define CONV_CR_SYNC_PROC_SEL_Msk       (0x1 << CONV_CR_SYNC_PROC_SEL_Pos)
#define CONV_CR_SYNC_PROC_SEL           CONV_CR_SYNC_PROC_SEL_Msk

#define CONV_CR_OUT_SEL_2_1_Msk         (0x1)
#define CONV_CR_OUT_SEL_2_1             CONV_CR_OUT_SEL_2_1_Msk


/* CONV_ADDR_OFFSET_HOLD 0x2c */
#define CONV_CR_OFFSET_HOLD_000_POS     (5)
#define CONV_CR_OFFSET_HOLD_000_MSK     (0X7 << CONV_CR_OFFSET_HOLD_000_POS)
#define CONV_CR_OFFSET_HOLD_000         CONV_CR_OFFSET_HOLD_000_MSK

#define CONV_CR_AUTO_OFFSET_HOLD_Pos    (4)
#define CONV_CR_AUTO_OFFSET_HOLD_Msk    (0x1 << CONV_CR_AUTO_OFFSET_HOLD_Pos)
#define CONV_CR_AUTO_OFFSET_HOLD        CONV_CR_AUTO_OFFSET_HOLD_Msk

#define CONV_CR_OFFSET_HOLD_0000_Msk    (0xf)
#define CONV_CR_OFFSET_HOLD_0000        CONV_CR_OFFSET_HOLD_0000_Msk


/* CONV_ADDR_SOG_FILT 0x34 */
#define CONV_CR_SOG_FILT_EN_Pos         (2)
#define CONV_CR_SOG_FILT_EN_Msk         (0x1 << CONV_CR_SOG_FILT_EN_Pos)
#define CONV_CR_SOG_FILT_EN             CONV_CR_SOG_FILT_EN_Msk


/* CONV_ADDR_VCO_GEAR 0x36 */
#define CONV_CR_VCO_GEAR_Msk            (0x1)
#define CONV_CR_VCO_GEAR                CONV_CR_VCO_GEAR_Msk


/* CONV_ADDR_AUTO_GAIN 0x3c */
#define CONV_CR_AUTO_GAIN_0000_Pos      (4)
#define CONV_CR_AUTO_GAIN_0000_Msk      (0xf << CONV_CR_AUTO_GAIN_0000_Pos)
#define CONV_CR_AUTO_GAIN_0000          CONV_CR_AUTO_GAIN_0000_Msk

#define CONV_CR_AUTO_GAIN_HOLD_Pos      (3)
#define CONV_CR_AUTO_GAIN_HOLD_Msk      (0x1 << CONV_CR_AUTO_GAIN_HOLD_Pos)
#define CONV_CR_AUTO_GAIN_HOLD          CONV_CR_AUTO_GAIN_HOLD_Msk


#define CONV_CR_AUTO_GAIN_EN_Msk        (0x7)
#define CONV_CR_AUTO_GAIN_EN            CONV_CR_AUTO_GAIN_EN_Msk



static const uint8_t control_registers [] = { // address byte, data byte
  CONV_ADDR_PLL_DIV_H, 0x32,
  CONV_ADDR_PLL_DIV_L, 0x00,
  CONV_ADDR_VCO_CPMP, (0b00 << CONV_CR_VCO_RNG_Pos) |
                      (0b101 << CONV_CR_CP_CURRENT_Pos) |
                      (0b0 << CONV_CR_EXT_CLK_EN_Pos),
  CONV_ADDR_HSYNC_CTRL, (1 << CONV_CR_HSYNC_IN_POL_Pos) |
                        (0 << CONV_CR_HSYNC_OUT_POL_Pos),
  CONV_ADDR_VSYNC_CTRL, (1 << CONV_CR_VSYNC_IN_POL_Pos) |
                        (0 << CONV_CR_VSYNC_OUT_POL_Pos),
  CONV_ADDR_OUT_SEL_1, (0b100 << CONV_CR_OUTPUT_MODE_Pos) |
                       (1 << CONV_CR_PRIMARY_OUT_EN_Pos) |
                       (0 << CONV_CR_SECONDARY_OUT_EN_Pos) |
                       (10 << CONV_CR_OUT_DRIVE_STRENGTH_Pos),
  CONV_ADDR_GRN_OFFSET_H, 0b1001000,
  CONV_ADDR_GRN_OFFSET_L, 0 << CONV_CR_GRN_OFFSET_L_Pos,
  CONV_ADDR_RED_OFFSET_H, 0b1000100,
  CONV_ADDR_RED_OFFSET_L, 0 << CONV_CR_RED_OFFSET_L_Pos,
  CONV_ADDR_PHA_ADJ, 188
};

static uint8_t address = 0xff; //reset value

void ad9983a_configure() {

  uint8_t data_length = sizeof(control_registers) / 2;

  RCC->APBENR1 |= RCC_APBENR1_I2C1EN;

  GPIOB->MODER &= ~(GPIO_MODER_MODE6_Msk |
                    GPIO_MODER_MODE7_Msk);

  GPIOB->MODER |= GPIO_MODER_MODE6_1 |
                  GPIO_MODER_MODE7_1;

  GPIOB->OTYPER |= GPIO_OTYPER_OT6 |
                   GPIO_OTYPER_OT7;

  GPIOB->OSPEEDR |= GPIO_OSPEEDR_OSPEED6 |
                    GPIO_OSPEEDR_OSPEED7;

  GPIOB->AFR[0] |= (6 << GPIO_AFRL_AFSEL6_Pos) |
                   (6 << GPIO_AFRL_AFSEL7_Pos);


  I2C1->CR1 |= I2C_CR1_TCIE;
  I2C1->CR2 &= ~I2C_CR2_RD_WRN; // request write

  I2C1->CR2 |= (0b1001100 << (I2C_CR2_SADD_Pos + 1));
  I2C1->CR2 |= (data_length << I2C_CR2_NBYTES_Pos);
  I2C1->CR1 |= I2C_CR1_PE;

  for (uint8_t i = 0; i < data_length; i++) {

    if (control_registers[i * 2] != address + 1) {
      I2C1->CR2 |= I2C_CR2_START;
      while(!(I2C1->ISR & I2C_ISR_TXE));
      I2C1->TXDR = control_registers[i * 2];
    }
    address = control_registers[2 * i];

    while(!(I2C1->ISR & I2C_ISR_TXE));
    I2C1->TXDR = control_registers[i * 2 + 1];

    if(control_registers[i * 2 + 2] != address + 1) {
      address = 0xff;
      while(!(I2C1->ISR & I2C_ISR_TXE));
      I2C1->CR2 |= I2C_CR2_STOP;
    }
  }
}
