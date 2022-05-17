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

entity memory_controller is
  port (
    clk : in std_logic;
    hsync : in std_logic;
    vsync : in std_logic;
    x : in integer range -118 to H_PERIOD;
    y : in integer range -V_BP to V_PERIOD;
    write_address : out std_logic_vector(8 downto 0);
    read_address : out std_logic_vector(8 downto 0);
    write_bank_field : out std_logic_vector(5 downto 0);
    read_bank_x : out integer range 0 to 1;
    bank_pos_top : out integer range 0 to 4;
    bank_pos_mid : out integer range 0 to 4;
    bank_pos_bot : out integer range 0 to 4
  );

end entity;

architecture a1 of memory_controller is

  signal bank_sel_x : integer range 0 to 1;
  signal bank_sel_y : integer range 0 to 4;
  signal write_bank : integer range 0 to 6;

  type state_type is (s0, s1, s2);
  signal state : state_type;
  
begin

  bank_select_x: process(clk)
  begin

    if rising_edge(clk) then
      if (x < XRES / 2 + 5) then
        read_bank_x <= 0;
      else
        read_bank_x <= 1;
      end if;

      if (x < XRES / 2 + 1) then
        read_address <= std_logic_vector(to_unsigned(x - 1, 9));
        bank_sel_x <= 0;
      else
        read_address <= std_logic_vector(to_unsigned(x - XRES / 2 - 1, 9));
        bank_sel_x <= 1;
      end if;

      if (x < XRES / 2) then
        write_address <= std_logic_vector(to_unsigned(x, 9));
      else
        write_address <= std_logic_vector(to_unsigned(x - XRES / 2, 9));
      end if;
      write_bank <= bank_sel_y + bank_sel_x;

      case write_bank is
        when 0 =>
        write_bank_field <= "000001";
        when 1 =>
        write_bank_field <= "000010";
        when 2 =>
        write_bank_field <= "000100";
        when 3 =>
        write_bank_field <= "001000";
        when 4 =>
        write_bank_field <= "010000";
        when 5 =>
        write_bank_field <= "100000";
        when others =>
        write_bank_field <= "000000";
      end case;
    end if;

  end process bank_select_x;

  bank_select_y: process(hsync)
  begin

    if rising_edge(hsync) then
      case state is
        when s0 =>
          state <= s1;
          bank_sel_y <= 0;
          bank_pos_top <= 0;
          bank_pos_mid <= 2;
          bank_pos_bot <= 4;

        when s1 =>
          state <= s2;
          bank_sel_y <= 2;
          bank_pos_top <= 2;
          bank_pos_mid <= 4;
          bank_pos_bot <= 0;

        when s2 =>
          state <= s0;
          bank_sel_y <= 4;
          bank_pos_top <= 4;
          bank_pos_mid <= 0;
          bank_pos_bot <= 2;
      end case;
    end if;
  end process bank_select_y;

end a1;