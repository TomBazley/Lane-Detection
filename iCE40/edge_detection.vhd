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

entity edge_detection is
  port (
    clk : in std_logic;
    
    x : in integer range -118 to H_PERIOD;
    y : in integer range -V_BP to V_PERIOD;
    
    top : in std_logic_vector(7 downto 0);
    mid : in std_logic_vector(7 downto 0);
    bot : in std_logic_vector(7 downto 0);
    
    edge : out std_logic_vector(7 downto 0);
    edge_threshold : out std_logic_vector(7 downto 0)
  );
end entity;

architecture a1 of edge_detection is

begin

  process (clk)
    variable G_xp : signed(10 downto 0);
    variable G_xn : signed(10 downto 0);
  
    variable top_row : vector_array(0 to 4)(7 downto 0);
    variable mid_row : vector_array(0 to 4)(7 downto 0);
    variable bot_row : vector_array(0 to 4)(7 downto 0);
  begin
    if rising_edge(clk) then

      top_row := top & top_row(0 to 3);
      mid_row := mid & mid_row(0 to 3);
      bot_row := bot & bot_row(0 to 3);
      
      G_xp := signed(("000" & unsigned(top_row(1))) +
                     ("000" & unsigned(mid_row(1))) +
                     ("000" & unsigned(mid_row(1))) +
                     ("000" & unsigned(bot_row(1))) + 
                     ("000" & unsigned(top_row(0))) +
                     ("000" & unsigned(mid_row(0))) +
                     ("000" & unsigned(mid_row(0))) +
                     ("000" & unsigned(bot_row(0))));
      
      G_xn := signed(("000" & unsigned(top_row(4))) +
                     ("000" & unsigned(mid_row(4))) +
                     ("000" & unsigned(mid_row(4))) +
                     ("000" & unsigned(bot_row(4))) + 
                     ("000" & unsigned(top_row(3))) +
                     ("000" & unsigned(mid_row(3))) +
                     ("000" & unsigned(mid_row(3))) +
                     ("000" & unsigned(bot_row(3))));

      if (x < 10 or x > XRES) then
        edge <= (others => '0');
        edge_threshold <= (others => '0');
      else
        edge <= std_logic_vector(unsigned(abs(G_xp - G_xn)))(10 downto 3);
        if (unsigned(abs(G_xp - G_xn)) > x"64") then
          edge_threshold <= (others => '1');
        else
          edge_threshold <= (others => '0');
        end if;
      end if;
    end if;
  end process;
end a1;