`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.05.2021 22:18:25
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

`define AND 4'b0000
`define OR  4'b0001
`define ADD 4'b0010
`define SUB 4'b0110

/*
 * Ctrl
 *   31   |   30   |   29   |   28   |   27   |   26   |   25   |   24   |   23   |   22   |   21   |   20   |   19   |   18   |   17   |   16   |
 * fstall | dstall | dflush | eflush |   0    |   0    |      a_fwd      |   0    |   0    |      b_fwd      |   0    | rf_wr  |      wb_sel     |
 *
 *   15   |   14   |   13   |   12   |   11   |   10   |   09   |   08   |   07   |   06   |   05   |   04   |   03   |   02   |   01   |   00   |
 *   0    |   0    |  m_rd  |  m_wr  |   0    |   0    |   jal  |   br   |   0    |   0    | a_sel  | b_sel  |              alu_op               |
 */

module CPU(
    input clk, rst,
    
    //IO_BUS
    output [7:0] io_addr,      //led和seg的地�????????
    output [31:0] io_dout,     //输出led和seg的数�????????
    output io_we,                 //输出led和seg数据时的使能信号
    input [31:0] io_din,        //来自sw的输入数�????????
    
    //Debug_BUS
    input [7:0] m_rf_addr,   //存储�????????(MEM)或寄存器�????????(RF)的调试读口地�????????
    output [31:0] rf_data,    //从RF读取的数�????????
    output [31:0] m_data,    //从MEM读取的数�????????

    //PC/IF/ID 流水段寄存器
    output [31:0] pc,
    output [31:0] pcd,
    output [31:0] ir,
    output [31:0] pcin,

    //ID/EX 流水段寄存器
    output [31:0] pce,
    output [31:0] a,
    output [31:0] b,
    output [31:0] imm,
    output [4:0] rd,
    output [31:0] ctrl,

    //EX/MEM 流水段寄存器
    output [31:0] y,
    output [31:0] bm,
    output [4:0] rdm,
    output [31:0] ctrlm,

    //MEM/WB 流水段寄存器
    output [31:0] yw,
    output [31:0] mdr,
    output [4:0] rdw,
    output [31:0] ctrlw
    );

    //
    wire [31:0] pc_mux;
    
    // PC_ADD_4 output
    wire [31:0] pc_add_4;

    // Instruction memory output
    wire [31:0] instr_mem_spo;

    wire [31:0] instr_mux;

    //
    wire [31:0] rf_mux;
    wire [4:0] rdw;

    // RegFile outputs
    wire[31:0] rf_out1, rf_out2;

    // ImmGen output
    wire [31:0] imm_gen;

    wire [31:0] ire;
    assign rd = ire[11:7];

    //
    wire[31:0] alu_ctrl_mux;

    //
    wire [31:0] pc_add_imm;

    //
    wire[31:0] alu;
    wire zero;

    wire [2:0] alu_ctrl;
    
    wire [31:0] data_mem_spo;

    wire branch, jal, m_wr, m_rd, rf_wr, a_sel, b_sel;
    wire [1:0] ALU_op, wb_sel;

    wire [31:0] ctrl_in;

    assign ctrl_in[3:0] = { 2'b0, ALU_op };
    assign ctrl_in[4] = b_sel;
    assign ctrl_in[5] = a_sel;
    assign ctrl_in[8] = branch;
    assign ctrl_in[9] = jal; 
    assign ctrl_in[12] = m_wr;
    assign ctrl_in[13] = m_rd;
    assign ctrl_in[17:16] = wb_sel;
    assign ctrl_in[18] = rf_wr;

    wire [1:0] a_fwd, b_fwd;

    wire [31:0] alu_fwd_mux1, alu_fwd_mux2;

    wire fstall, dstall, dflush, eflush;

    REG PC(
        .clk(clk), .hold(fstall), .clear(rst),
        .in(pc_mux), .out(pc)
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
        .branch(branch), .jal(jal), .m_wr(m_wr), .m_rd(m_rd), .rf_wr(rf_wr), .a_sel(a_sel), .b_sel(b_sel),
        .ALU_op(ALU_op), .wb_sel(wb_sel)
    );

    HazardDetectionUnit HazardDetectionUnit(
        .rst(rst),
        .rs1(ir[19:15]), .rs2(ir[24:10]), .rde(ire[11:7]),
        .m_rd_e(ctrl[13]), 
        .branch(ctrlm[8]&&zero), .jal(ctrl[9]),
        .fstall(fstall), .dstall(dstall), .dflush(dflush), .eflush(eflush)
    );

    RegFile RegFile (
        .clk(clk), .rst(rst), 
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
    
    MUX2 ALU_CTRL_MUX (
        .in0(alu_fwd_mux2), .in1(imm),
        .sel(ctrl[4]), //b_sel
        .out(alu_ctrl_mux)
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

    ADD PC_ADD_Imm(
        .in0(pce), .in1(imm<<1),
        .out(pc_add_imm)
    );
    
    ALU ALU (
        .in0(alu_fwd_mux1), .in1(alu_ctrl_mux),
        .op(alu_ctrl), 
        .out(alu),
        .zero(zero)
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
        .clk(clk), .we(ctrlm[12]), // m_wr
        .a(y/4),
        .dpra(m_rf_addr),
        .d(bm),
        .spo(data_mem_spo),
        .dpo(m_data)
    );
    
    REG CTRLW(
        .clk(clk), .hold(0), .clear(rst),
        .in(ctrlm), .out(ctrlw)
    );

    REG MDR(
        .clk(clk), .hold(0), .clear(rst),
        .in(data_mem_spo), .out(mdr)
    );
    
    REG YW(
        .clk(clk), .hold(0), .clear(rst),
        .in(y), .out(yw)
    );

    REG RdW(
        .clk(clk), .hold(0), .clear(rst),
        .in(rdm), .out(rdw)
    );

    MUX4 RF_MUX (
        .in0(yw), .in1(mdr), .in2(), .in3(),
        .sel(ctrlw[17:16]), // wb_sel 
        .out(rf_mux)
    );
    
    MUX2 PC_MUX (
        .in0(pc_add_4), .in1(pc_add_imm),
        .sel((ctrl[8]&&zero)||ctrl[9]), // (branch&&zero) || jal
        .out(pc_mux)
    );
endmodule

module HazardDetectionUnit (
    input rst,
    input [4:0] rs1, rs2, rde,
    input m_rd_e,
    input branch, jal,
    output reg fstall, dstall, dflush, eflush
    );
    always @* begin
        if(rst) begin
            { fstall, dstall, dflush, eflush } <= 0;
        end
        else if(rde != 0 && (rs1 == rde || rs2 == rde) && m_rd_e) begin
            { dflush, eflush } <= 0;
            fstall <= 1;
            dstall <= 1;
        end
        else if(branch || jal) begin
            { fstall, dstall } <= 0;
            dflush <= 1;
            //eflush <= 1;
        end
        else begin
            { fstall, dstall, dflush, eflush } <= 0;
        end
    end
endmodule

module ForwardingUnit (
    input [4:0] rs1, rs2,
    input [4:0] rdm, rdw,
    input rf_wr_m, rf_wr_wb,
    output reg [1:0] a_fwd, b_fwd
    );
    always @* begin
        if(rf_wr_m && rdm != 0 && rs1 == rdm) a_fwd <= 2;
        else if(rf_wr_wb && rdw != 0 && rs1 == rdw) a_fwd <= 1;
        else a_fwd <= 0;

        if(rf_wr_m && rdm != 0 && rs2 == rdm) b_fwd <= 2;
        else if(rf_wr_wb && rdw != 0 && rs2 == rdw) b_fwd <= 1;
        else b_fwd <= 0;
    end
endmodule

module REG #(parameter MSB = 31, LSB = 0)(
    input clk, hold, clear,
    input [MSB:LSB] in,
    output reg [MSB:LSB] out
    );
    always @(posedge clk or posedge clear) begin
        if(clear) out <= 0;
        else if(hold) out <= out;
        else out <= in;
    end
endmodule

module PC #(parameter MSB = 31, LSB = 0) (
    input clk, en, rst,
    input [MSB:LSB] in,
    output reg [MSB:LSB] out
    );
    always @(posedge clk or posedge rst) begin
        if(rst) out <= 0;
        else if(en) out <= in;
    end
endmodule

module ADD #(parameter MSB = 31, LSB = 0) (
    input [MSB:LSB] in0, in1,
    output [MSB:LSB] out
    );
    assign out = in0+in1;
endmodule

module RegFile (
    input clk, rst, we,             // write enable
    input [31:0] wd,                // write data
    input [4:0] wa, ra0, ra1, ra2, // write, read address
    output [31:0] rd0, rd1, rd2     // read data
    );
    localparam SIZE = 32; 
    reg [31:0] memory[SIZE-1:0]; 

    assign rd0 = (we == 1 && ra0 == wa) ? wd : memory[ra0];
    assign rd1 = (we == 1 && ra1 == wa) ? wd : memory[ra1];
    assign rd2 = (we == 1 && ra2 == wa) ? wd : memory[ra2];

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            memory[0] <= 0;
        end
        else if(wa != 0 & we == 1) begin
            memory[wa] <= wd;
        end
    end
endmodule

module ALU #(parameter MSB = 31, LSB = 0, F_MSB = 2, F_LSB = 0) (
    input [MSB:LSB] in0, in1,
    input [F_MSB:F_LSB] op,
    output zero,
    output reg [MSB:LSB] out
    );
    assign zero = (out == 0);
    always @(*) begin
        case (op)
            `AND: out <= in0 & in1;
            `OR: out  <= in0 | in1;
            `ADD: out <= in0 + in1;
            `SUB: out <= in0 - in1;
        endcase
    end
endmodule

module ImmGen (
    input [31:0] instr,
    output reg [31:0] out
    );
    always @(*) begin
        case (instr[6:0]) // opcode
            7'b1101111: begin // jal
                out <= { instr[31] == 0 ? 12'h0 : 12'hfff, instr[31], instr[19:12], instr[20], instr[30:21] };
            end
            7'b1100011: begin // beq
                out <= { instr[31] == 0 ? 12'h0 : 12'hfff, instr[31], instr[7], instr[30:25], instr[11:8] };
            end
            7'b0000011: begin // lw
                out <= { instr[31] == 0 ? 20'h0 : 20'hfffff, instr[31:20] };
            end
            7'b0100011: begin // sw
                out <= { instr[31] == 0 ? 20'h0 : 20'hfffff, instr[31:25], instr[11:7] };
            end
            7'b0010011: begin // addi
                out <= { instr[31] == 0 ? 20'h0 : 20'hfffff, instr[31:20] };
            end
        endcase
    end
endmodule

module MUX2 #(parameter MSB = 31, LSB = 0) (
    input [MSB:LSB] in0, in1,
    input sel,
    output reg [MSB:LSB] out
    );
    always @(*) begin
        case(sel)
            1'b0: out <= in0;
            1'b1: out <= in1;
        endcase
    end
endmodule

module MUX4 #(parameter MSB = 31, LSB = 0) (
    input [MSB:LSB] in0, in1, in2, in3,
    input [1:0]sel,
    output reg [MSB:LSB] out
    );
    always @(*) begin
        case(sel)
            2'b00: out <= in0;
            2'b01: out <= in1;
            2'b10: out <= in2;
            2'b11: out <= in3;
        endcase
    end
endmodule

module Control (
    input rst,
    input [6:0] opcode,
    output reg branch, jal, m_wr, m_rd, rf_wr, a_sel, b_sel,
    output reg [1:0] ALU_op, wb_sel
    );
    always @(*) begin
        if(rst) begin
            {branch, jal, m_wr, rf_wr, wb_sel } <= 0;
        end
        else begin
            a_sel <= 0;
            case (opcode)
                7'b1101111: begin // jal
                    jal <= 1;
                    { rf_wr, m_wr, m_rd } <= 0;
                    ALU_op <= 2'b00;
                end
                7'b1100011: begin // beq
                    branch <= 1'b1;
                    { jal, rf_wr, m_wr, m_rd, b_sel } <= 0;
                    ALU_op <= 2'b01;
                end
                7'b0000011: begin // lw
                    { b_sel, rf_wr, m_rd } <= 3'b111;
                    { jal, branch, m_wr } <= 0;
                    wb_sel <= 2'b1;
                    ALU_op <= 2'b00;
                end
                7'b0100011: begin // sw
                    { b_sel, m_wr } <= 2'b11;
                    { jal, branch, rf_wr, m_rd } <= 0;
                    ALU_op <= 2'b00;
                end
                7'b0010011: begin // addi
                    {b_sel, rf_wr } <= 2'b11;
                    { jal, branch, m_wr, m_rd } <= 0;
                    wb_sel <= 2'b0;
                    ALU_op <= 2'b00;
                end
                7'b0110011: begin // add
                    rf_wr <= 1'b1;
                    { jal, branch, m_wr, m_rd, b_sel } <= 0;
                    wb_sel <= 2'b0;
                    ALU_op <= 2'b10;
                end
            endcase
        end
    end
endmodule

module ALU_Control (
    input [1:0] ALU_op,
    input [31:0] instr,
    output reg [2:0] op
    );
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    always @* begin
        case (ALU_op)
            2'b00: op <= `ADD;
            2'b01: op <= `SUB;
            2'b10: begin
                case ({funct7, funct3})
                    10'b0000000000: op <= `ADD;
                    10'b0100000000: op <= `SUB;
                    10'b0000000111: op <= `AND;
                    10'b0000000110: op <= `OR; 
                endcase
            end
            2'b11: op <= `SUB;
       endcase 
    end
endmodule