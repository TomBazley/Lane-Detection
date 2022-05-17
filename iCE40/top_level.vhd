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

library sb_ice40_components_syn;
use sb_ice40_components_syn.components.all;

entity top_level is

  port (
    clk : in std_logic;

    sck : in std_logic;
    cs_n : in std_logic;
    mosi : in std_logic;

    r_in : in std_logic_vector(7 downto 0);
    g_in : in std_logic_vector(7 downto 0);
    b_in : in std_logic_vector(7 downto 0);
    sogout : in std_logic;
    hsync : in std_logic;
    vsync : in std_logic;
    oe_field : in std_logic;
    clamp : out std_logic := '0';

    r_out : out std_logic_vector(7 downto 0);
    g_out : out std_logic_vector(7 downto 0);
    b_out : out std_logic_vector(7 downto 0);
    disp_clk : out std_logic;
    disp_disp : out std_logic := '1';
    disp_hsync : out std_logic;
    disp_vsync : out std_logic;
    disp_den : out std_logic := '0';
    disp_bist : out std_logic := '0';

    led : out std_logic := '0'
  );

end entity;

architecture a1 of top_level is

  component edge_detection is
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
  end component;

  component memory_controller is
    port(
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
  end component;

  component output_select is
    port (
      channel_select : in std_logic_vector(7 downto 0);
  
      data_en : in bit_array (0 to 2);
      r_in : in std_logic_vector(7 downto 0);
      g_in : in std_logic_vector(7 downto 0);
      b_in : in std_logic_vector(7 downto 0);
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
  end component;

  component overlay is
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
  end component;
  
  component rgb_to_luma is
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
  end component;

  component spi_master_in is
    port (
      sck : in std_logic;
      cs_n : in std_logic;
      mosi : in std_logic;
  
      parallel_rx : out std_logic_vector(7 downto 0)
    );
  end component;

  component sync is
    port (
      clk : in std_logic;
      hsync : in std_logic;
      vsync : in std_logic;
      data_en : out bit_array(0 to 2);
      x : out integer range -118 to H_PERIOD;
      y : out integer range -V_BP to V_PERIOD
    );
  end component;

  component synchroniser is
    port (
      update : in std_logic;
      write_data : in std_logic_vector(7 downto 0);
      read_clk : in std_logic;
  
      read_data : out std_logic_vector(7 downto 0)
    );
  end component;

  component SB_RAM256x16
    generic (
      INIT_0 : bit_vector(255 downto 0);
      INIT_1 : bit_vector(255 downto 0); 
      INIT_2 : bit_vector(255 downto 0); 
      INIT_3 : bit_vector(255 downto 0); 
      INIT_4 : bit_vector(255 downto 0); 
      INIT_5 : bit_vector(255 downto 0);
      INIT_6 : bit_vector(255 downto 0);
      INIT_7 : bit_vector(255 downto 0);
      INIT_8 : bit_vector(255 downto 0);
      INIT_9 : bit_vector(255 downto 0);
      INIT_A : bit_vector(255 downto 0);
      INIT_B : bit_vector(255 downto 0);
      INIT_C : bit_vector(255 downto 0);
      INIT_D : bit_vector(255 downto 0);
      INIT_E : bit_vector(255 downto 0);
      INIT_F : bit_vector(255 downto 0)
    ) ;
    port( 
      RDATA : out std_logic_vector(15 downto 0);
      RCLK : in std_logic;
      RCLKE : in std_logic;
      RE : in std_logic;
      RADDR : in std_logic_vector(7 downto 0);
      WCLK : in std_logic;
      WCLKE : in std_logic;
      WE : in std_logic;
      WADDR : in std_logic_vector(7 downto 0);
      MASK : in std_logic_vector(15 downto 0);
      WDATA : in std_logic_vector(15 downto 0)
    );
  end component;


  component SB_RAM512x8
    generic (
      INIT_0 : bit_vector(255 downto 0);
      INIT_1 : bit_vector(255 downto 0); 
      INIT_2 : bit_vector(255 downto 0); 
      INIT_3 : bit_vector(255 downto 0); 
      INIT_4 : bit_vector(255 downto 0); 
      INIT_5 : bit_vector(255 downto 0);
      INIT_6 : bit_vector(255 downto 0);
      INIT_7 : bit_vector(255 downto 0);
      INIT_8 : bit_vector(255 downto 0);
      INIT_9 : bit_vector(255 downto 0);
      INIT_A : bit_vector(255 downto 0);
      INIT_B : bit_vector(255 downto 0);
      INIT_C : bit_vector(255 downto 0);
      INIT_D : bit_vector(255 downto 0);
      INIT_E : bit_vector(255 downto 0);
      INIT_F : bit_vector(255 downto 0)
    );
    port(
      RDATA : out std_logic_vector(7 downto 0);
      RCLK : in std_logic;
      RCLKE : in std_logic;
      RE : in std_logic;
      RADDR : in std_logic_vector(8 downto 0);
      WCLK : in std_logic;
      WCLKE : in std_logic;
      WE : in std_logic;
      WADDR : in std_logic_vector(8 downto 0);
      WDATA : in std_logic_vector(7 downto 0)
    );
  end component;

  signal cs_n_signal : bit_array(0 to 1);
  
  signal bank_pos_bot : integer range 0 to 4;
  signal bank_pos_mid : integer range 0 to 4;
  signal bank_pos_top : integer range 0 to 4;
  signal channel_select : std_logic_vector(7 downto 0);
  signal data_en : bit_array(0 to 2);
  signal edge : std_logic_vector(7 downto 0);
  signal edge_threshold : std_logic_vector(7 downto 0);
  signal luma : std_logic_vector(7 downto 0);
  signal luma_threshold : std_logic_vector(7 downto 0);
  signal mem_data_out : vector_array(0 to 5)(7 downto 0);

  signal overlay_address : std_logic_vector(7 downto 0);
  signal overlay_input : std_logic_vector(7 downto 0);
  signal overlay_out_b : std_logic_vector(7 downto 0);
  signal overlay_out_g : std_logic_vector(7 downto 0);
  signal overlay_out_r : std_logic_vector(7 downto 0);
  signal overlay_read : vector_array(0 to 3) (15 downto 0);
  signal overlay_write : std_logic_vector(15 downto 0);
  signal overlay_write_en : bit_array(0 to 3);

  signal read_address : std_logic_vector(8 downto 0);
  signal read_bank_x : integer range 0 to 1;
  signal spi_rx : std_logic_vector(7 downto 0);
  signal write_address : std_logic_vector(8 downto 0);
  signal write_bank_field : std_logic_vector(5 downto 0);
  signal x : integer range -118 to H_PERIOD;
  signal y : integer range -V_BP to V_PERIOD;
  
  
begin

  edge_memory : for i in 0 to 5 generate
    edge_memory_i : SB_RAM512x8
    generic map (
      INIT_0 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_8 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_9 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_A =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_B =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_C =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_D =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_E =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_F =>
        X"0000000000000000000000000000000000000000000000000000000000000000"
    )
    port map (
      WDATA => luma,
      WADDR => write_address,
      WE => write_bank_field(i),
      WCLKE => write_bank_field(i),
      WCLK => clk,
      RDATA => mem_data_out(i),
      RADDR => read_address,
      RCLK => clk,
      RCLKE => '1',
      RE => '1'
    );
  end generate edge_memory;

  U0 : spi_master_in
  port map (
    sck => sck,
    cs_n => cs_n,
    mosi => mosi,
    parallel_rx => spi_rx
  );
 
  U1 : synchroniser
  port map (
    update => cs_n,
    write_data => spi_rx,
    read_clk => clk,
    read_data => channel_select
  );

  U2 : output_select
  port map (
    channel_select => channel_select,
    data_en => data_en,
    r_in => r_in,
    g_in => g_in,
    b_in => b_in,
    luma => luma,
    edge => edge,
    luma_threshold => luma_threshold,
    edge_threshold => edge_threshold,
    combined => luma_threshold and edge_threshold,
    overlay_out_r => overlay_out_r,
    overlay_out_g => overlay_out_g,
    overlay_out_b => overlay_out_b,
    overlay_input => overlay_input,
    data_en_out => disp_den,
    r_out => r_out,
    g_out => g_out,
    b_out => b_out
  );

  U3 : rgb_to_luma
  port map (
    clk => clk,
    red => unsigned(r_in),
    green => unsigned(g_in),
    blue => unsigned(b_in),
    x => x,
    y => y,
    luma => luma,
    luma_threshold => luma_threshold
  );

  U4 : sync
  port map (
    clk => clk,
    hsync => hsync,
    vsync => vsync,
    data_en => data_en,
    x => x,
    y => y
  );

  U5 : memory_controller
  port map (
    clk => clk,
    hsync => hsync,
    vsync => vsync,
    x => x,
    y => y,
    write_address => write_address,
    read_address => read_address,
    write_bank_field => write_bank_field,
    read_bank_x => read_bank_x,
    bank_pos_top => bank_pos_top,
    bank_pos_mid => bank_pos_mid,
    bank_pos_bot => bank_pos_bot
  );

  U6 : edge_detection
  port map (
    clk => clk,
    x => x,
    y => y,
    top => mem_data_out(bank_pos_top + read_bank_x),
    mid => mem_data_out(bank_pos_mid + read_bank_x),
    bot => mem_data_out(bank_pos_bot + read_bank_x),
    edge => edge,
    edge_threshold => edge_threshold
  );

  U7 : overlay
  port map (
    clk => clk,
    vsync => vsync,
    r_in => r_in,
    g_in => g_in,
    b_in => b_in,
    overlay_input => overlay_input,
    x => x,
    y => y,
    read_data => overlay_read,
    write_data => overlay_write,
    write_en => overlay_write_en,
    address => overlay_address,
    r_out => overlay_out_r,
    g_out => overlay_out_g,
    b_out => overlay_out_b
  );

  overlay_memory : for i in 0 to 3 generate
    overlay_memory_i : SB_RAM256x16
    generic map (
      INIT_0 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_1 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_2 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_3 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_4 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_5 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_6 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_7 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_8 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_9 =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_A =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_B =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_C =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_D =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_E =>
        X"0000000000000000000000000000000000000000000000000000000000000000",
      INIT_F =>
        X"0000000000000000000000000000000000000000000000000000000000000000"
    )
    port map (
      WDATA => overlay_write,
      MASK => x"0000",
      WADDR => overlay_address,
      WE => overlay_write_en(i),
      WCLKE => overlay_write_en(i),
      WCLK => clk,
      RDATA => overlay_read(i),
      RADDR => overlay_address,
      RCLK => clk,
      RCLKE => '1',
      RE => '1'
    );
  end generate overlay_memory;
  
  disp_clk <= clk;
  disp_hsync <= hsync;
  disp_vsync <= vsync;

end architecture;