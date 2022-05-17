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
use work.common.all;

entity synchroniser is
  port (
    update : in std_logic;
    write_data : in std_logic_vector(7 downto 0);
    read_clk : in std_logic;

    read_data : out std_logic_vector(7 downto 0)
  );
end entity;

architecture a1 of synchroniser is

  signal r_update : std_logic_vector(3 downto 0);

begin
  process (read_clk)
  begin

    if (rising_edge(read_clk)) then
      r_update <= r_update(2) & r_update(1) & r_update(0) & update;
      if (r_update(3) = '0' and r_update(2) = '1') then
        read_data <= write_data;
      end if;
    end if;
    
  end process;
end a1;