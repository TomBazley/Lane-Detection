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

entity spi_master_in is
  port (
    sck : in std_logic;
    cs_n : in std_logic;
    mosi : in std_logic;

    parallel_rx : out std_logic_vector(7 downto 0)
  );
end entity;

architecture a1 of spi_master_in is

begin
  process (sck, cs_n)

    variable rx_buffer : std_logic_vector(7 downto 0) := (others => '0');

  begin
    
    if (rising_edge(sck)) then
      rx_buffer := rx_buffer(6 downto 0) & mosi;
    elsif (rising_edge(cs_n)) then
      parallel_rx <= rx_buffer;
    end if;

  end process;
end a1;