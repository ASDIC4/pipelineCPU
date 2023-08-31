-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
-- Date        : Tue Aug 29 20:54:08 2023
-- Host        : DESKTOP-98I0ANI running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               F:/vivado/projects/pipelineCPU/pipelineCPU.srcs/sources_1/ip/ip_data_ram/ip_data_ram_stub.vhdl
-- Design      : ip_data_ram
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xa7a35tcsg324-1I
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ip_data_ram is
  Port ( 
    a : in STD_LOGIC_VECTOR ( 9 downto 0 );
    d : in STD_LOGIC_VECTOR ( 31 downto 0 );
    clk : in STD_LOGIC;
    we : in STD_LOGIC;
    i_ce : in STD_LOGIC;
    spo : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end ip_data_ram;

architecture stub of ip_data_ram is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "a[9:0],d[31:0],clk,we,i_ce,spo[31:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "dist_mem_gen_v8_0_13,Vivado 2019.2";
begin
end;
