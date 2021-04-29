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

module FPGA(
    input clk, BTN,
    input [7:0] sw,
    output [7:0] led,
    output [2:0] AN,
    output [3:0] D
    );
    wire clk_cpu, ready;
    reg valid;
    reg [31:0] cpu_in;
    reg [7:0] io_addr;
    reg [31:0] io_dout;
    wire [31:0] io_din;

    reg io_we;

    always @* begin
        case (io_addr)
            8'h00: begin 
                io_we <= 1;
                io_dout <= 0;
            end
            8'h04: begin
                io_we <= 1;
                io_dout <= ready;
            end
            8'h08: begin
                io_we <= 1;
                io_dout <= 0;
            end
            8'h0c: begin
                io_we <= 0;
                cpu_in <= io_din;
            end
            8'h10: begin
                io_we <= 0;
                valid <= io_din;
            end
            default: ;
        endcase
    end

    always @(posedge clk, posedge rst) begin
        if(rst) begin
            io_addr <= 0;
        end
        else if(led[6:5] == 0) begin // check
            case (io_addr)
                8'h00: io_addr <= 8'h04;
                8'h04: io_addr <= 8'h08;
                8'h08: io_addr <= 8'h0c;
                8'h0c: io_addr <= 8'h10;
                8'h10: io_addr <= 8'h00;
                default: ;
            endcase
        end
    end

    TOP TOP (
        .mem_clk(clk), .cpu_clk(clk_cpu), .rst(),
        
        .valid(valid),
        .in(cpu_in),
        .ready(ready),

        //.instr_dpra({ 24'h0, m_rf_addr }), 
        .data_dpra({ 24'h0, m_rf_addr }), .reg_dpra({ 24'h0, m_rf_addr }),
        //.instr_dpo(), 
        .data_dpo(m_data), .reg_dpo(rf_data),
        .pc(pc)
    );

    pdu_1cycle pdu_1cycle(
        .clk(clk),
        .rst(sw[7]),

  //选择CPU工作方式;
        .run(sw[6]), 
        .step(BTN),
        .clk_cpu(clk_cpu),

  //输入switch的端口
        .valid(sw[5]),
        .in(sw[4:0]),

  //输出led和seg的端口 
        .check(led[6:5]),  //led6-5:查看类型
        .out0(led[4:0]),    //led4-0
        .an(AN),     //8个数码管
        .seg(D),
        .ready(led[7]),          //led7

  //IO_BUS
        .io_addr(io_addr),
        .io_dout(io_dout),
        .io_we(io_we),
        .io_din(io_din),

  //Debug_BUS
        .m_rf_addr(m_rf_addr),
        .rf_data(rf_data),
        .m_data(m_data),
        .pc(pc)
    );
endmodule

module TOP (
    input clk, 
    input rst,
    
    //IO_BUS
    output [7:0] io_addr,      // led or seg address
    output [31:0] io_dout,     // data out
    output io_we,
    input [31:0] io_din,       // data in
    
    //Debug_BUS
    input [7:0] m_rf_addr,   // memory or regFile address
    output [31:0] rf_data,   // regfile data out
    output [31:0] m_data,    // memory data out
    output [31:0] pc         // output pc current state
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

module CPU (
    input clk, 
    input rst,
    
    //IO_BUS
    output [7:0] io_addr,      // led or seg address
    output [31:0] io_dout,     // data out
    output io_we,
    input [31:0] io_din,       // data in
    
    //Debug_BUS
    input [7:0] m_rf_addr,   // memory or regFile address
    output [31:0] rf_data,   // regfile data out
    output [31:0] m_data,    // memory data out
    output [31:0] pc         // output pc current state
    );
    
    wire [31:0] add4_out, instr, rf_wd, rf_out1, rf_out2, imm_out;
    wire rf_we; // regfile write enable
     
    PC PC (
        .clk(clk), .rst(rst),
        .in(),
        .out(pc)
    );
    
    ADD ADD4(
        .in0(4), .in1(pc),
        .out(add4_out)
    );

    instr_mem instr_mem(
        .clk(clk), .we(0),
        .a(pc),
        //.dpra(dpra),
        //.d(d),
        .spo(instr),
        //.dpo(instr_dpo)
    );

    Decoder Decoder(
        .instr(instr),      // instruction
        .rd(rd),        // destination
        .rs1(rs1), .rs2(rs2),  // sources
        .opcode(opcode)
    );

    
    RegFile RegFile (
        .clk(clk), .rst(rst), .we(rf_we),  // write enable
        .wd(rf_wd),           // write data
        .wa(rd), .ra0(rs1), .ra1(rs2), .ra2(m_rf_addr), // write, read address
        .rd0(rf_out1), .rd1(rf_out2), .rd2(rf_data)     // read data
    );
    
    Imm Imm(
        .instr(instr),
        .out(imm_out)
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


//--------------------------------------------------------------------------------------

    // get instructions from instructions memory
    output [31:0] instr_a,
    input [31:0] instr,
    
    // get data from data memory
    output [31:0] data_a,
    output [31:0] data_in,
    output data_we,
    input [31:0] data_spo,
    
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
    input  [31:0] instr,          // instruction
    output [31:0] rd,        // destination
    output [31:0] rs1, rs2,  // sources
    output [6:0]  opcode
    );
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
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
    input [31:0] instr,
    output reg [31:0] out
    );
    always @(*) begin
        case (instr[6:0]) // opcode
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

module ALU_Control (
    input [31:0] instr,
    output reg [2:0] funct3
    );
    always @* begin
        if(instr[6:0] == 7'b1101111) begin // jal opcode
            funct3 <= 0;
        end
        else begin // sw, lw, addi, add, beq
            funct3 <= instr[14:12];
        end
    end
endmodule