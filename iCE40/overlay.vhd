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

entity overlay is
  generic (
    lower_boundary : integer := 255;
    upper_boundary : integer := 360
  );
  port (
    clk : in std_logic;
    r_in : in std_logic_vector(7 downto 0);
    g_in : in std_logic_vector(7 downto 0);
    b_in : in std_logic_vector(7 downto 0);
    overlay_input : in std_logic_vector(7 downto 0);
    vsync : in std_logic;
    x : in integer range -118 to H_PERIOD;
    y : in integer range -V_BP to V_PERIOD;

    read_data : in vector_array(0 to 3)(15 downto 0);

    write_data : out std_logic_vector(15 downto 0);
    write_en : out bit_array(0 to 3);

    address : out std_logic_vector(7 downto 0);

    r_out : out std_logic_vector(7 downto 0);
    g_out : out std_logic_vector(7 downto 0);
    b_out : out std_logic_vector(7 downto 0)
  );

end entity;

architecture a1 of overlay is

  signal bank_read : integer range 0 to 3;
  signal bank_y_write : integer range 0 to 3;
  signal bank_x : integer range 0 to 3;
  signal second_edge : std_logic;

  type state_type is (s0, s1);
  signal state : state_type;
  
begin

  process(clk)
  begin

    if rising_edge(clk) then
      write_data <= std_logic_vector(to_unsigned(x, 16));
      address <= std_logic_vector(to_unsigned(y - lower_boundary, 8));

      if (x < XRES / 2) then
        bank_x <= 0;
      else
        bank_x <= 2;
      end if;

      if (y > lower_boundary and y < upper_boundary) then
        
        if (x < 0) then -- clear old data
          write_en(bank_y_write) <= '1';
          write_en(bank_y_write + 2) <= '1';
        else
          if (x < XRES / 2) then
            write_en(bank_y_write) <= overlay_input(0);
            write_en(bank_y_write + 2) <= '0';
            second_edge <= '0';
          else
            for i in 0 to 1 loop
              write_en(i) <= '0';
            end loop;
          end if;
          if (x > XRES / 2) then
            write_en(bank_y_write + 2) <= overlay_input(0) and not second_edge;
            write_en(bank_y_write) <= '0';
            if (second_edge = '0') then
              second_edge <= overlay_input(0);
            end if;
          else
            for i in 2 to 3 loop
              write_en(i) <= '0';
            end loop;
          end if;
        end if;
  
        if (abs(x + 10 - signed(read_data(bank_read))) < 10) then
          r_out <= x"ff";
          g_out <= x"00";
          b_out <= x"00";
        elsif (abs(x - signed(read_data(bank_read + 2))) < 10) then
          r_out <= x"ff";
          g_out <= x"00";
          b_out <= x"00";
        else
          r_out <= r_in;
          g_out <= g_in;
          b_out <= b_in;
        end if;
      else
        r_out <= r_in;
        g_out <= g_in;
        b_out <= b_in;
      end if;
    end if;

  end process;

  process(vsync)
  begin
    
    if (rising_edge(vsync)) then
      case state is
        when s0 =>
          state <= s1;
          bank_y_write <= 0;
          bank_read <= 1;

        when s1 =>
          state <= s0;
          bank_y_write <= 1;
          bank_read <= 0;
      end case;
    end if;
  end process;

end a1;