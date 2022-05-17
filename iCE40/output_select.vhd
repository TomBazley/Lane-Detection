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

entity output_select is
  port (
    channel_select : in std_logic_vector(7 downto 0);

    data_en : in bit_array (0 to 2);
    r_in : in std_logic_vector(7 downto 0);
    g_in : in std_logic_vector (7 downto 0);
    b_in : in std_logic_vector (7 downto 0);
    luma : in std_logic_vector(7 downto 0);
    edge : in std_logic_vector(7 downto 0);
    luma_threshold : in std_logic_vector(7 downto 0);
    edge_threshold : in std_logic_vector(7 downto 0);
    combined : in std_logic_vector(7 downto 0);
    overlay_out_r : in std_logic_vector(7 downto 0);
    overlay_out_g : in std_logic_vector(7 downto 0);
    overlay_out_b : in std_logic_vector(7 downto 0);

    overlay_input : out std_logic_vector(7 downto 0);
    
    data_en_out : out std_logic;
    r_out : out std_logic_vector(7 downto 0);
    g_out : out std_logic_vector(7 downto 0);
    b_out : out std_logic_vector(7 downto 0)
  );
end entity output_select;

architecture rtl of output_select is

begin
  with channel_select(3 downto 0) select r_out <=
    r_in when x"1",
    luma when x"2",
    luma_threshold when x"3",
    edge when x"4",
    edge_threshold when x"5",
    combined when x"6",
    overlay_out_r when x"7",
    r_in when others;

  with channel_select(3 downto 0) select g_out <=
    g_in when x"1",
    luma when x"2",
    luma_threshold when x"3",
    edge when x"4",
    edge_threshold when x"5",
    combined when x"6",
    overlay_out_g when x"7",
    g_in when others;

  with channel_select(3 downto 0) select b_out <=
    b_in when x"1",
    luma when x"2",
    luma_threshold when x"3",
    edge when x"4",
    edge_threshold when x"5",
    combined when x"6",
    overlay_out_b when x"7",
    b_in when others;

  with channel_select(3 downto 0) select data_en_out <=
    data_en(0) when x"1",
    data_en(1) when x"2",
    data_en(1) when x"3",
    data_en(2) when x"4",
    data_en(2) when x"5",
    data_en(0) when x"6",
    data_en(0) when x"7",
    data_en(0) when others;

  with channel_select(7 downto 4) select overlay_input <=
    luma_threshold when x"1",
    edge_threshold when x"2",
    combined when x"3",
    x"00" when others;
end architecture;