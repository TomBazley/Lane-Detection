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

entity rgb_to_luma is
  port (
    clk : in std_logic;
    red : in unsigned(7 downto 0);
    green : in unsigned(7 downto 0);
    blue : in unsigned(7 downto 0);
    
    x : in integer range -118 to H_PERIOD;
    y : in integer range -V_BP to V_PERIOD;

    luma : out std_logic_vector(7 downto 0);
    luma_threshold : out std_logic_vector(7 downto 0)
  );
end entity;

architecture a1 of rgb_to_luma is

begin
  process (clk)

    variable l_red : unsigned(15 downto 0);
    variable l_green : unsigned(15 downto 0);
    variable l_blue : unsigned(15 downto 0);

    variable sample_pixel : vector_array(0 to 3)(7 downto 0);
    variable sample_total : unsigned(9 downto 0);

    variable luma_var : unsigned(7 downto 0);
  begin

    if rising_edge(clk) then
      l_red := 54 * red;
      l_green := 183 * green;
      l_blue := 18 * blue;

      luma_var := std_logic_vector(l_red + l_green + l_blue)(15 downto 8);

      luma <= luma_var;
      
      for i in 0 to 3 loop
        if x = XRES / 2 - 30 + 20 * i and y = 360 then
          sample_pixel(i) := std_logic_vector(luma_var);
        end if;
      end loop;

      sample_total := ("00" & unsigned(sample_pixel(0))) +
                      ("00" & unsigned(sample_pixel(1))) +
                      ("00" & unsigned(sample_pixel(2))) +
                      ("00" & unsigned(sample_pixel(3)));

      if (luma_var > sample_total(9 downto 2) + 20) then
        luma_threshold <= (others => '1');
      else
        luma_threshold <= (others => '0');
      end if;
    end if;
  end process;
end architecture;