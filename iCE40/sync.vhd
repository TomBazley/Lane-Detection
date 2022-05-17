-- Copyright 2022 Tom Bazley tombazley@outlook.com
-- SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
-- 
-- Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may
-- not use this file except in compliance with the License, or, at your option,
-- the Apache License version 2.0. You may obtain a copy of the License at
--
-- https://solderpad.org/licenses/SHL-2.1/
--
-- Unless required by applicable law or agreed to in writing, any work
-- distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
-- WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
-- License for the specific language governing permissions and limitations under
-- the License.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.common.all;

entity sync is

  port (
    clk : in std_logic;
    hsync : in std_logic;
    vsync : in std_logic;
    data_en : out bit_array(0 to 2);
    x : out integer range -118 to H_PERIOD;
    y : out integer range -V_BP to V_PERIOD
  );

end entity;

architecture a1 of sync is
  signal data_en_x : bit_array(0 to 2);
  signal data_en_y : bit_array(0 to 2);

begin
  data_en(0) <= data_en_x(0) and data_en_y(0);
  data_en(1) <= data_en_x(1) and data_en_y(0);
  data_en(2) <= data_en_x(2) and data_en_y(2);

  horizontal: process (clk, hsync)

    variable x_signal : integer range -118 to H_PERIOD;

  begin
    if rising_edge(clk) then

      if (hsync = '0') then
        x_signal := -118;
      else
        x_signal := x_signal + 1;
        x <= x_signal;
  
        if ((x_signal >= 0) AND (x_signal < XRES)) then
          data_en_x(0) <= '1';
        else
          data_en_x(0) <= '0';
        end if;
  
        if ((x_signal >= 1) AND (x_signal < XRES + 1)) then
          data_en_x(1) <= '1';
        else
          data_en_x(1) <= '0';
        end if;
  
        if ((x_signal >= 4) AND (x_signal < XRES + 4)) then
          data_en_x(2) <= '1';
        else
          data_en_x(2) <= '0';
        end if;

      end if;

    end if;
  end process horizontal;


  vertical: process (hsync)

    variable y_signal : integer range -V_BP to V_PERIOD;

  begin
    if falling_edge(hsync) then
      if (vsync = '0') then
        y_signal := -(V_BP);
      else
        y_signal := y_signal + 1;
        y <= y_signal;
  
        if ((y_signal >= 0) AND (y_signal < YRES - 1)) then
          data_en_y(0) <= '1';
        else
          data_en_y(0) <= '0';
        end if;
  
        if ((y_signal >= 1) AND (y_signal < YRES)) then
          data_en_y(2) <= '1';
        else
          data_en_y(2) <= '0';
        end if;

      end if;

    end if;
  end process vertical;

end architecture a1;
