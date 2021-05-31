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
 * fstall | dstall | dflash | eflush |   0    |   0    |      a_fwd      |   0    |   0    |      b_fwd      |   0    | rf_wr  |      wb_sel     |
 *
 *   15   |   14   |   13   |   12   |   11   |   10   |   09   |   08   |   07   |   06   |   05   |   04   |   03   |   02   |   01   |   00   |
 *   0    |   0    | m_edm  |  m_wr  |   0    |   0    |   jal  |   br   |   0    |   0    | a_sell | b_sell |              alu_op               |
 */

module CPU(
    input clk, rst,
    
    //IO_BUS
    output [7:0] io_addr,      //led和seg的地�?????
    output [31:0] io_dout,     //输出led和seg的数�?????
    output io_we,                 //输出led和seg数据时的使能信号
    input [31:0] io_din,        //来自sw的输入数�?????
    
    //Debug_BUS
    input [7:0] m_rf_addr,   //存储�?????(MEM)或寄存器�?????(RF)的调试读口地�?????
    output [31:0] rf_data,    //从RF读取的数�?????
    output [31:0] m_data,    //从MEM读取的数�?????

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
    wire[31:0] alu_mux;

    //
    wire [31:0] pc_add_imm;

    //
    wire[31:0] alu;
    wire zero;

    wire [2:0] alu_ctrl;
    
    wire [31:0] data_mem_spo;

    wire branch, jal, m_wr, rf_wr;
    wire [1:0] ALU_op, wb_sel;

    wire [31:0] ctrl_in;

    assign ctrl_in[8] = branch;
    assign ctrl_in[9] = jal; 
    assign ctrl_in[12] = m_wr;
    assign ctrl_in[18] = rf_wr;
    assign ctrl_in[3:0] = { 2'b0, ALU_op };
    assign ctrl_in[17:16] = wb_sel;

    PC PC (
        .clk(clk), .rst(rst), .en(1),
        .in(pc_mux),
        .out(pc)
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

    REG PCD(
        .clk(clk), .hold(0), .clear(rst),
        .in(pc), .out(pcd)
    );

    REG IR(
        .clk(clk), .hold(0), .clear(rst),
        .in(instr_mem_spo), .out(ir)
    );

    Control Control(
        .opcode(ir[6:0]),
        .branch(branch), .jal(jal), .m_wr(m_wr), .rf_wr(rf_wr), 
        .ALU_op(ALU_op), .wb_sel(wb_sel)
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
        .clk(clk), .hold(0), .clear(rst),
        .in(ctrl_in), .out(ctrl)
    );

    REG PCE(
        .clk(clk), .hold(0), .clear(rst),
        .in(pcd), .out(pce)
    );

    REG A(
        .clk(clk), .hold(0), .clear(rst),
        .in(rf_out1), .out(a)
    );
    
    REG B(
        .clk(clk), .hold(0), .clear(rst),
        .in(rf_out2), .out(b)
    );
    
    REG Imm(
        .clk(clk), .hold(0), .clear(rst),
        .in(imm_gen), .out(imm)
    );
    
    REG IRE(
        .clk(clk), .hold(0), .clear(rst),
        .in(ir), .out(ire)
    );
    
    MUX2 ALU_MUX (
        .in0(b), .in1(imm),
        .sel(1), //
        .out(alu_mux)
    );

    ADD PC_ADD_Imm(
        .in0(pce), .in1(imm<<1),
        .out(pc_add_imm)
    );
    
    ALU ALU (
        .in0(a), .in1(alu_mux),
        .op(alu_ctrl), 
        .out(alu),
        .zero(zero)
    );

    ALU_Control ALU_Control (
        .ALU_op(ctrl[1:0]),
        .instr(ire),
        .op(alu_ctrl)
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
        .in(b), .out(bm)
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
                out <= { instr[31:20] };
            end
            7'b0100011: begin // sw
                out <= { instr[31:25], instr[11:7] };
            end
            7'b0010011: begin // addi
                out <= { instr[31:20] };
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
    input [6:0] opcode,
    output reg branch, jal, m_wr, rf_wr,
    output reg [1:0] ALU_op, wb_sel
    );
    always @(*) begin
        case (opcode)
            7'b1101111: begin // jal
                jal <= 1;
                { rf_wr, m_wr } <= 0;
                ALU_op <= 2'b00;
            end
            7'b1100011: begin // beq
                branch <= 1'b1;
                { jal, rf_wr, m_wr } <= 0;
                ALU_op <= 2'b01;
            end
            7'b0000011: begin // lw
                rf_wr <= 1'b1;
                { jal, branch, m_wr } <= 0;
                wb_sel <= 2'b1;
                ALU_op <= 2'b00;
            end
            7'b0100011: begin // sw
                m_wr <= 1'b1;
                { jal, branch, rf_wr } <= 0;
                ALU_op <= 2'b00;
            end
            7'b0010011: begin // addi
                rf_wr <= 1'b1;
                { jal, branch, m_wr } <= 0;
                wb_sel <= 2'b0;
                ALU_op <= 2'b00;
            end
            7'b0110011: begin // add
                rf_wr <= 1'b1;
                { jal, branch, m_wr } <= 0;
                wb_sel <= 2'b0;
                ALU_op <= 2'b10;
            end
        endcase
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