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

package common is

  type bit_array is array (natural range <>) of std_logic;
  type vector_array is array (natural range <>) of std_logic_vector;

  constant XRES : integer;
  constant H_BP : integer; --horizontal back porch
  constant H_FP : integer; --horizontal front porch
  constant H_PULSE : integer;
  constant H_PERIOD : integer;

  constant YRES : integer;
  constant V_BP : integer;
  constant V_FP : integer;
  constant V_PULSE : integer;
  constant V_PERIOD : integer;

end common;

package body common is

  constant XRES : integer := 640;
  constant H_BP : integer := 48;
  constant H_FP : integer := 16;
  constant H_PULSE : integer := 96;
  constant H_PERIOD : integer := H_BP + XRES + H_FP + H_PULSE;

  constant YRES : integer := 480;
  constant V_BP : integer := 33;
  constant V_FP : integer := 10;
  constant V_PULSE : integer := 2;
  constant V_PERIOD : integer := V_BP + YRES + V_FP + H_PULSE;

end common;
