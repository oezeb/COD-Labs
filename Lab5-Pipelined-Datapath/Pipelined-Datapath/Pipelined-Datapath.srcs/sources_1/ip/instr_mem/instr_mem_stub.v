// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
// Date        : Tue Jun  1 11:13:19 2021
// Host        : LAPTOP-F23L14UP running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               E:/Documents/USTC/BSc/Computer-Organization-and-Design/Labs/Lab5-Pipelined-Datapath/Pipelined-Datapath/Pipelined-Datapath.srcs/sources_1/ip/instr_mem/instr_mem_stub.v
// Design      : instr_mem
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "dist_mem_gen_v8_0_13,Vivado 2019.1" *)
module instr_mem(a, d, clk, we, spo)
/* synthesis syn_black_box black_box_pad_pin="a[7:0],d[31:0],clk,we,spo[31:0]" */;
  input [7:0]a;
  input [31:0]d;
  input clk;
  input we;
  output [31:0]spo;
endmodule
