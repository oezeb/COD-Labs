`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.04.2021 19:50:22
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

module TOP (
    input mem_clk, cpu_clk, rst,
    input [31:0] pc,
    
    input valid,
    input [31:0] in,
    output ready,

    input [31:0] instr_dpra, data_dpra, reg_dpra,
    output [31:0] instr_dpo, data_dpo, reg_dpo
    );
    
    wire [31:0] instr_a;
    wire [31:0] instr;
    
    wire [31:0] data_a;
    wire [31:0] data_in;
    wire data_we;
    wire [31:0] data_spo;
    
    data_mem data_mem(
        .clk(mem_clk), .we(data_we),
        .a(data_a),
        .dpra(data_dpra),
        .d(data_in),
        .spo(data_spo),
        .dpo(data_dpo)
    );
    
    instr_mem instr_mem(
        .clk(mem_clk), .we(0),
        .a(instr_a),
        .dpra(instr_dpra),
        //.d(d),
        .spo(instr),
        .dpo(instr_dpo)
    );
    
    CPU CPU(
        .clk(cpu_clk), .rst(rst),

        .valid(valid),
        .in(in),
        .ready(ready),

        .instr_a(instr_a),
        .instr(instr),
        
        .data_a(data_a),
        .data_in(data_in),
        .data_we(data_we),
        .data_spo(data_spo),

        .pc(pc),

        .reg_a(reg_dpra),
        .reg_out(reg_dpo)
    );
endmodule

module CPU(
    input clk, rst,

    // Getting inputs
    input valid,
    input [31:0] in,
    output ready,

    // get instructions from instructions memory
    output [31:0] instr_a,
    input [31:0] instr,
    
    // get data from data memory
    output [31:0] data_a,
    output [31:0] data_in,
    output data_we,
    input [31:0] data_spo,
    
    // PC state 
    output [31:0] pc,
    
    // port to read RegFile content
    input [31:0] reg_a,
    output [32:0] reg_out
    );

    // Control signals
    wire pc_mux,
        reg_write, mem_write,
        alu_mux1, alu_mux2;
    wire [1:0] mux3;   
    wire [2:0] funct3; // ALU function
    
    wire [31:0] pc_mux_out, pc, 
        add4_out, 
        rs1, rs2, rd, 
        opcode, imm_out, 
        reg_in, reg_out1, reg_out2, 
        alu_out, alu_mux1_out, alu_mux2_out,
        mux3_out;
    
    assign instr_a = pc/4;
    assign data_a = alu_out/4;
    assign data_in = reg_out2;
    assign reg_in = ready ? in : mux3_out; //when ready, get input from IO

    PC PC (
        .clk(clk), .rst(rst),
        .in(pc_mux_out),
        .out(pc)
    );

    ADD ADD4(
        .in0(4), .in1(pc),
        .out(add4_out)
    );
    
    RegFile RegFile (
        .clk(clk), .rst(rst), .we(reg_write),                    // write enable
        .wd(reg_in),           // write data
        .wa(rd), .ra0(rs1), .ra1(rs2), .ra2(reg_a), // write, read address
        .rd0(reg_out1), .rd1(reg_out2), .rd2(reg_out)     // read data
    );
    
    MUX2 ALU_MUX1 (
        .in0(pc), .in1(reg_out1),
        .sel(alu_mux1),
        .out(alu_mux1_out)
    );

    MUX2 ALU_MUX2 (
        .in0(reg_out2), .in1(imm_out),
        .sel(alu_mux2),
        .out(alu_mux2_out)
    );
    
    ALU ALU (
        .a(alu_mux1_out), .b(alu_mux2_out),
        .f(funct3),
        .out(alu_out)
    );
    
    MUX2 PC_MUX (
        .in0(add4_out), .in1(alu_out),
        .sel(pc_mux),
        .out(pc_mux_out)
    );

    Decoder Decoder(
        .instr(instr),      // instruction
        .rd(rd),        // destination
        .rs1(rs1), .rs2(rs2),  // sources
        .opcode(opcode)
    );
    
    Imm Imm(
        .opcode(opcode),
        .instr(instr),
        .out(imm_out)
    );

    MUX3 MUX3 (
        .in0(add4_out), .in1(alu_out), .in2(data_spo),
        .sel(mux3),
        .out(mux3_out)
    );

    Control Control (
        .opcode(opcode),
        .instr(instr),
        .reg1(reg_out1), .reg2(reg_out2), // RegFile output
        .valid(valid), // validate IO inputs
        .pc_mux(pc_mux), 
        .reg_write(reg_write), .mem_write(data_we),
        .alu_mux1(alu_mux1), .alu_mux2(alu_mux2),
        .syscall(ready),
        .mux3(mux3),
        .funct3(funct3)
    );
endmodule



module ALU #(parameter MSB = 31, LSB = 0, F_MSB = 2, F_LSB = 0) (
    input [MSB:LSB] a, b,
    input [F_MSB:F_LSB] f,
    output reg [MSB:LSB] out
    );
    localparam ADD = 0;
    localparam SUB = 1;
    localparam AND = 2;
    localparam OR = 3;
    localparam XOR = 4;
    
    always @(*) begin
        case (f)
            ADD: out <= a+b;
            SUB: out <= a-b;
            AND: out <= a&b;
            OR: out <= a|b;
            XOR: out <= a^b;
        endcase
    end
endmodule

module RegFile (
    input clk, rst, we,             // write enable
    input [31:0] wd,                // write data
    input [31:0] wa, ra0, ra1, ra2, // write, read address
    output [31:0] rd0, rd1, rd2     // read data
    );
    localparam SIZE = 32; 
    reg [31:0] memory[SIZE-1:0]; 
    
    assign rd0 = memory[ra0];
    assign rd1 = memory[ra1];
    assign rd2 = memory[ra2];

    integer i;
    always @(posedge clk or posedge rst) begin
        if(rst == 1) begin
            for (i = 0; i < SIZE; i = i+1) begin
                memory[i] <= 0;
            end
        end
        else if(we == 1 & wa != 0) begin
            memory[wa] <= wd;
        end
    end
endmodule

module Decoder (
    input [31:0] instr,          // instruction
    output reg [31:0] rd,        // destination
    output reg [31:0] rs1, rs2,  // sources
    output [6:0] opcode
    );
    assign opcode = instr[6:0];
    
    always @(*) begin
        case (opcode)
            7'b1101111: begin // jal
                rd <= instr[11:7];
                rs1 <= 0;
                rs2 <= 0;
            end
            7'b1100011: begin // beq
                rd <= 0;
                rs1 <= instr[19:15];
                rs2 <= instr[24:20];
            end
            7'b0000011: begin // lw
                rd <= instr[11:7];
                rs1 <= instr[19:15];
                rs2 <= 0;
            end
            7'b0100011: begin // sw
                rd <= 0;
                rs1 <= instr[19:15];
                rs2 <= instr[24:20];
            end
            7'b0010011: begin // addi
                rd <= instr[11:7];
                rs1 <= instr[19:15];
                rs2 <= 0;
            end
            7'b0110011: begin // add
                rd <= instr[11:7];
                rs1 <= instr[19:15];
                rs2 <= instr[24:20];
            end
            7'b1110011: begin // ecall         
                rd <= 32'ha; // x10 (a0) register
                rs1 <= 0;
                rs2 <= 32'h11; // x17 (a7) register
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

module MUX3 #(parameter MSB = 31, LSB = 0) (
    input [MSB:LSB] in0, in1, in2,
    input [1:0]sel,
    output reg [MSB:LSB] out
    );
    always @(*) begin
        case(sel)
            2'b00: out <= in0;
            2'b01: out <= in1;
            2'b10: out <= in2;
        endcase
    end
endmodule

module ADD #(parameter MSB = 31, LSB = 0) (
    input [MSB:LSB] in0, in1,
    output reg [MSB:LSB] out
    );
    always @(*) begin
        out <= in0+in1;
    end
endmodule

module PC #(parameter MSB = 31, LSB = 0) (
    input clk, rst,
    input [MSB:LSB] in,
    output reg [MSB:LSB] out
    );
    always @(posedge clk or posedge rst) begin
        if(rst == 1) out <= 0;
        else out <= in;
    end
endmodule

module Imm (
    input [6:0] opcode,
    input [31:0] instr,
    output reg [31:0] out
    );
    always @(*) begin
        case (opcode)
            7'b1101111: begin // jal
                out <= { instr[31] == 0 ? 12'h0 : 12'hfff, instr[31], instr[19:12], instr[20], instr[30:21] } << 1;
            end
            7'b1100011: begin // beq
                out <= { instr[31] == 0 ? 12'h0 : 12'hfff, instr[31], instr[7], instr[30:25], instr[11:8] } << 1;
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
            7'b0110011: begin // add
                out <=   0;
            end
            7'b1110011: begin // ecall         
                out <= 0;
            end
        endcase
    end
endmodule

module Control (
    input [6:0] opcode,
    input [31:0] instr,
    input [31:0] reg1, reg2, // RegFile output
    input valid, // validate IO input
    output reg pc_mux, reg_write, alu_mux1, alu_mux2, mem_write, syscall,
    output reg [1:0] mux3,
    output [2:0] funct3
    );
    assign funct3 = opcode == 7'b1101111 ? /*jal*/ 0 : instr[14:12];
    always @(*) begin
        case (opcode)
            7'b1101111: begin // jal
                pc_mux <= 1;
                reg_write <= 1;
                alu_mux2 <= 1;
                mux3 <= 0;
                { alu_mux1, mem_write, syscall } <= 0;

            end
            7'b1100011: begin // beq
                pc_mux <= (reg1 == reg2);
                alu_mux2 <= 1;
                mux3 <= 1;
                { reg_write, alu_mux1, mem_write, syscall } <= 0;
            end
            7'b0000011: begin // lw
                reg_write <= 1;
                alu_mux1 <= 1;
                alu_mux2 <= 1;
                mux3 <= 2;
                { pc_mux, mem_write, syscall } <= 0;
            end
            7'b0100011: begin // sw
                alu_mux1 <= 1;
                alu_mux2 <= 1;
                mem_write <= 1;
                mux3 <= 1;
                { pc_mux, reg_write, syscall } <= 0; 
            end
            7'b0010011: begin // addi
                reg_write <= 1;
                alu_mux1 <= 1;
                alu_mux2 <= 1;
                mux3 <= 1;
                { pc_mux, mem_write, syscall } <= 0;
            end
            7'b0110011: begin // add
                reg_write <= 1;
                alu_mux1 <= 1;
                mux3 <= 1;
                { pc_mux, alu_mux2, mem_write, syscall } <= 0;
            end
            7'b1110011: begin // ecall (suport only ecall 5 ReadInt)
                syscall <= 1;
                if(/*reg2 == 5 &&*/ valid == 0) begin // reg2 must be the output of a7
                    reg_write <= 0;
                    alu_mux2 <= 1;
                    pc_mux <= 1;
                    { alu_mux1, mem_write, mux3 } <= 0;
                end
                else begin
                    alu_mux1 <= 1;
                    alu_mux2 <= 1;
                    reg_write <= 1;
                    { pc_mux, mem_write, mux3 } <= 0;
                end
            end
            default: begin
                { reg_write, mem_write } <= 0;
            end
        endcase
    end
endmodule