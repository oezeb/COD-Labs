`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 13:03:59
// Design Name: 
// Module Name: CPU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
 * Ctrl
 *   31   |   30   |   29   |   28   |   27   |   26   |   25   |   24   |   23   |   22   |   21   |   20   |   19   |   18   |   17   |   16   |
 * fstall | dstall | dflush | eflush |   0    |   0    |      a_fwd      |   0    |   0    |      b_fwd      |   0    | rf_wr  |      wb_sel     |
 *
 *   15   |   14   |   13   |   12   |   11   |   10   |   09   |   08   |   07   |   06   |   05   |   04   |   03   |   02   |   01   |   00   |
 *   0    |   0    |  m_rd  |  m_wr  |   0    |  jalr  |  jal   |   br   |       a_sel     |       b_sel     |              alu_op               |
 */

module CPU(
    input clk, rst,
    
    //IO_BUS
    output [7:0] io_addr,      //led和seg的地�????????
    output [31:0] io_dout,     //输出led和seg的数�????????
    output io_we,                 //输出led和seg数�?�时的使能信�?�
    input [31:0] io_din,        //�?�自sw的输入数�????????
    
    //Debug_BUS
    input [7:0] m_rf_addr,   //存储�????????(MEM)或寄存器�????????(RF)的调试读�?�地�????????
    output [31:0] rf_data,    //从RF读�?�的数�????????
    output [31:0] m_data,    //从MEM读�?�的数�????????

    //PC/IF/ID �?水段寄存器
    output [31:0] pc,
    output [31:0] pcd,
    output [31:0] ir,
    output [31:0] pcin,

    //ID/EX �?水段寄存器
    output [31:0] pce,
    output [31:0] a,
    output [31:0] b,
    output [31:0] imm,
    output [4:0] rd,
    output [31:0] ctrl,

    //EX/MEM �?水段寄存器
    output [31:0] y,
    output [31:0] bm,
    output [4:0] rdm,
    output [31:0] ctrlm,

    //MEM/WB �?水段寄存器
    output [31:0] yw,
    output [31:0] mdr,
    output [4:0] rdw,
    output [31:0] ctrlw
    );
    
    // PC_ADD_4 output
    wire [31:0] pc_add_4;

    // Instruction memory output
    wire [31:0] instr_mem_spo;

    wire [31:0] instr_mux;

    //
    wire [31:0] rf_mux;

    // RegFile outputs
    wire[31:0] rf_out1, rf_out2;

    // ImmGen output
    wire [31:0] imm_gen;

    wire [31:0] ire;
    assign rd = ire[11:7];

    //
    wire[31:0] alu_ctrl_mux1, alu_ctrl_mux2;

    //
    wire [31:0] pc_add_imm, rd1_add_imm;
    wire [31:0] jump_addr;
    //
    wire[31:0] alu;

    wire [2:0] alu_ctrl;
    
    wire [31:0] data_mem_spo;
    
    wire [31:0] mdr_mux;

    wire ctrl_branch, jal, jalr, m_wr, m_rd, rf_wr;
    wire [1:0] ALU_op, wb_sel, a_sel, b_sel;

    wire [31:0] ctrl_in;

    assign ctrl_in[3:0] = { 2'b0, ALU_op };
    assign ctrl_in[5:4] = b_sel;
    assign ctrl_in[7:6] = a_sel;
    assign ctrl_in[8] = ctrl_branch;
    assign ctrl_in[9] = jal;
    assign ctrl_in[10] = jalr; 
    assign ctrl_in[12] = m_wr;
    assign ctrl_in[13] = m_rd;
    assign ctrl_in[17:16] = wb_sel;
    assign ctrl_in[18] = rf_wr;

    wire [1:0] a_fwd, b_fwd;

    wire [31:0] alu_fwd_mux1, alu_fwd_mux2;

    wire branch;

    wire fstall, dstall, dflush, eflush;

    assign io_addr = y; // io_addr
    assign io_dout = bm; // io_dout
    assign io_we = y[10] && ctrlm[12]; // io_addr[10] && m_wr

    REG PC(
        .clk(clk), .hold(fstall), .clear(rst),
        .in(pcin), .out(pc)
    );

    ADD PC_ADD_4(
        .in0(pc), .in1(4),
        .out(pc_add_4)
    );

    instr_mem instr_mem(
        .clk(clk), .we(0),
        .a(pc/4),
        .spo(instr_mem_spo)
    );

    MUX2 instr_MUX (
        .in0(instr_mem_spo), .in1(0),
        .sel(dflush),
        .out(instr_mux)
    );

    REG PCD(
        .clk(clk), .hold(dstall), .clear(dflush),
        .in(pc), .out(pcd)
    );

    REG IR(
        .clk(clk), .hold(dstall), .clear(dflush),
        .in(instr_mux), .out(ir)
    );

    Control Control(
        .opcode(ir[6:0]), .rst(rst | dstall),
        .branch(ctrl_branch), .jal(jal), .jalr(jalr), 
        .m_wr(m_wr), .m_rd(m_rd), .rf_wr(rf_wr), 
        .ALU_op(ALU_op), .wb_sel(wb_sel),
        .a_sel(a_sel), .b_sel(b_sel)
    );

    HazardDetectionUnit HazardDetectionUnit(
        .rst(rst),
        .rs1(ir[19:15]), .rs2(ir[24:20]), .rde(ire[11:7]),
        .m_rd_e(ctrl[13]), 
        .branch(branch), .jump(ctrl[9] | ctrl[10]), // jal | jalr
        .fstall(fstall), .dstall(dstall), .dflush(dflush), .eflush(eflush)
    );

    RegFile RegFile (
        .clk(clk), 
        .we(ctrlw[18]),             // write enable. rf_wr
        .wd(rf_mux), .wa(rdw), 
        .ra0(ir[19:15]),     .ra1(ir[24:20]),     .ra2(m_rf_addr), // read address
        .rd0(rf_out1), .rd1(rf_out2), .rd2(rf_data)     // read data
    );

    ImmGen ImmGen(
        .instr(ir),
        .out(imm_gen)
    );

    REG CTRL(
        .clk(clk), .hold(0), .clear(eflush),
        .in(ctrl_in), .out(ctrl)
    );

    REG PCE(
        .clk(clk), .hold(0), .clear(eflush),
        .in(pcd), .out(pce)
    );

    REG A(
        .clk(clk), .hold(0), .clear(eflush),
        .in(rf_out1), .out(a)
    );
    
    REG B(
        .clk(clk), .hold(0), .clear(eflush),
        .in(rf_out2), .out(b)
    );
    
    REG Imm(
        .clk(clk), .hold(0), .clear(eflush),
        .in(imm_gen), .out(imm)
    );
    
    REG IRE(
        .clk(clk), .hold(0), .clear(eflush),
        .in(ir), .out(ire)
    );

    MUX4 ALU_CTRL_MUX1 (
        .in0(alu_fwd_mux1), .in1(pce), .in2(0), .in3(0),
        .sel(ctrl[7:6]), //a_sel
        .out(alu_ctrl_mux1)
    );

    MUX4 ALU_CTRL_MUX2 (
        .in0(alu_fwd_mux2), .in1(imm), .in2(4), .in3(0),
        .sel(ctrl[5:4]), //b_sel
        .out(alu_ctrl_mux2)
    );

    MUX4 ALU_FWD_MUX1 (
        .in0(a), .in1(rf_mux), .in2(y),
        .sel(a_fwd),
        .out(alu_fwd_mux1)
    );
    
    MUX4 ALU_FWD_MUX2 (
        .in0(b), .in1(rf_mux), .in2(y),
        .sel(b_fwd),
        .out(alu_fwd_mux2)
    );

    ADD RD1_ADD_Imm(
        .in0(a), .in1(imm),
        .out(rd1_add_imm)
    );

    ADD PC_ADD_Imm(
        .in0(pce), .in1(imm),
        .out(pc_add_imm)
    );

    MUX2 JumpAddr (
        .in0(pc_add_imm), .in1(rd1_add_imm & ~32'b1),
        .sel(ctrl[10]), // jalr
        .out(jump_addr)
    );
    ALU ALU (
        .in0(alu_ctrl_mux1), .in1(alu_ctrl_mux2),
        .op(alu_ctrl), 
        .out(alu)
    );

    Branch Branch(
        .ctrl_branch(ctrl[8]),
        .in0(alu_ctrl_mux1), .in1(alu_ctrl_mux2),
        .funct3(ire[14:12]),
        .branch(branch)
    );

    ALU_Control ALU_Control (
        .ALU_op(ctrl[1:0]),
        .instr(ire),
        .op(alu_ctrl)
    );

    ForwardingUnit ForwardingUnit(
        .rs1(ire[19:15]), .rs2(ire[24:20]),
        .rdm(rdm), .rdw(rdw),
        .rf_wr_m(ctrlm[18]), .rf_wr_wb(ctrlw[18]), // rf_wb
        .a_fwd(a_fwd), .b_fwd(b_fwd)
    );

    REG CTRLM(
        .clk(clk), .hold(0), .clear(rst),
        .in(ctrl), .out(ctrlm)
    );

    REG Y(
        .clk(clk), .hold(0), .clear(rst),
        .in(alu), .out(y)
    );

    REG BM(
        .clk(clk), .hold(0), .clear(rst),
        .in(alu_fwd_mux2), .out(bm)
    );

    REG RdM(
        .clk(clk), .hold(0), .clear(rst),
        .in(rd), .out(rdm)
    );
    
    data_mem data_mem(
        .clk(clk), .we(ctrlm[12] && ~y[10]), // m_wr && io_addr[10]
        .a(y/4),
        .dpra(m_rf_addr),
        .d(bm),
        .spo(data_mem_spo),
        .dpo(m_data)
    );

    MUX2 MDR_MUX (
        .in0(data_mem_spo), .in1(io_din),
        .sel(y[10]), // io_addr[10] 
        .out(mdr_mux)
    );
    
    REG CTRLW(
        .clk(clk), .hold(0), .clear(rst),
        .in(ctrlm), .out(ctrlw)
    );

    REG MDR(
        .clk(clk), .hold(0), .clear(rst),
        .in(mdr_mux), .out(mdr)
    );
    
    REG YW(
        .clk(clk), .hold(0), .clear(rst),
        .in(y), .out(yw)
    );

    REG RdW(
        .clk(clk), .hold(0), .clear(rst),
        .in(rdm), .out(rdw)
    );

    MUX2 RF_MUX (
        .in0(yw), .in1(mdr),
        .sel(ctrlw[16]), // wb_sel[0] 
        .out(rf_mux)
    );
    
    MUX2 PC_MUX (
        .in0(pc_add_4), .in1(jump_addr),
        .sel(rst ? 0 : branch | ctrl[9] | ctrl[10]), // branch | jal | jalr
        .out(pcin)
    );
endmodule
