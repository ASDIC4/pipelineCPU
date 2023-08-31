// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Tue Aug 29 20:54:08 2023
// Host        : DESKTOP-98I0ANI running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               F:/vivado/projects/pipelineCPU/pipelineCPU.srcs/sources_1/ip/ip_data_ram/ip_data_ram_stub.v
// Design      : ip_data_ram
// Purpose     : Stub declaration of top-level module interface
// Device      : xa7a35tcsg324-1I
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_13,Vivado 2019.2" *)
module ip_data_ram(a, d, clk, we, i_ce, spo)
/* synthesis syn_black_box black_box_pad_pin="a[9:0],d[31:0],clk,we,i_ce,spo[31:0]" */;
  input [9:0]a;
  input [31:0]d;
  input clk;
  input we;
  input i_ce;
  output [31:0]spo;
endmodule
