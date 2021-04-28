`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2021 19:29:37
// Design Name: 
// Module Name: ALU
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


module FPGA (
    input clk, BTN,
    input [7:0] sw,
    output [7:0] led
    );

    Control #(.MSB(5)) Control (
    .clk(clk), .en(BTN),
    .sel(sw[7:6]),
    .in(sw[5:0]),
    .out(led[5:0]),
    .z(led[7])
    );
endmodule

module Control #(parameter MSB = 31, LSB = 0, F_MSB = 2, F_LSB = 0) (
    input clk, en,
    input [1:0] sel,
    input [MSB:LSB] in,
    output reg [MSB:LSB] out,
    output reg z
    );
    wire ea,eb,ef;
    wire [MSB:LSB] a, b, ALU_out, ALU_z;
    wire [F_MSB:F_LSB] f;

    always @(negedge clk) begin //use negedge cause ef_edge is using posedege
        if(ef_edge) begin 
            out <= ALU_out;
            z <= ALU_z;
        end
    end

    signal_edge signal_edge(
    .clk(clk),
    .in(ef),
    .out(ef_edge)
    );

    ALU  #(.MSB(MSB),.LSB(LSB)) ALU(
    .clk(clk),
    .a(a), .b(b), 
    .f(f),   
    .out(ALU_out),
    .z(ALU_z) 
    );

    Decoder Decoder(
        .clk(clk),
        .en(en),
        .sel(sel),
        .ea(ea), .eb(eb), .ef(ef)
        );
    
    REG #(.MSB(MSB),.LSB(LSB)) A(
        .clk(clk),
        .en(ea),
        .in(in),
        .out(a)
        );

    REG #(.MSB(MSB),.LSB(LSB)) B(
        .clk(clk),
        .en(eb),
        .in(in),
        .out(b)
        );

    REG #(.MSB(F_MSB),.LSB(F_LSB)) F(
        .clk(clk),
        .en(ef),
        .in(in),
        .out(f)
        );
endmodule

module ALU #(parameter MSB = 31, LSB = 0, F_MSB = 2, F_LSB = 0) (
    input clk,
    input [MSB:LSB] a, b, 
    input [F_MSB:F_LSB] f,   
    output reg [MSB:LSB] out,
    output reg z
    );
    parameter ADD = 0;
    parameter SUB = 1;
    parameter AND = 2;
    parameter OR = 3;
    parameter XOR = 4;

    always @(posedge clk) begin
        case (f)
            ADD: out <= a+b;
            SUB: out <= a-b;
            AND: out <= a&b;
            OR: out <= a|b;
            XOR: out <= a^b;
            default: begin
                out <= 0;
                z <= 1;
            end
        endcase
    end
endmodule

module Decoder (
    input clk, en,
    input [1:0] sel,
    output reg ea, eb, ef
    );
    
    parameter NONE = 0;
    parameter F = 1;
    parameter A = 2;
    parameter B = 3;
    
    wire btn_edge;

    always @(negedge clk) begin //use negedge cause btn_edge is using posedege
        if(btn_edge) begin
            case (sel)
                NONE: begin
                    ef <= 0; ea <= 0; eb <= 0;
                end
                F: begin
                    ef <= 1;
                end
                A: begin
                    ea <= 1;
                end
                B: begin
                    eb <= 1;
                end
            endcase
        end
        else begin
            ef <= 0; ea <= 0; eb <= 0;
        end
    end

    signal_edge signal_edge(
    .clk(clk),
    .in(en),
    .out(btn_edge)
    );
endmodule

module REG #(parameter MSB = 31, LSB = 0) (
    input clk, en,
    input [MSB:LSB] in,
    output reg [MSB:LSB] out
    );

    always @(posedge clk)
        if(en) out <= in;
endmodule

module signal_edge #(parameter MSB = 0, LSB = 0) (
    input clk,
    input[MSB:LSB]  in,
    output reg [MSB:LSB] out
    );
    reg [MSB:LSB] s1,s2;
    always@(posedge clk) s1 <= in;
    always@(posedge clk) s2 <= s1;
    always @(posedge clk) begin
        if(s1 == s2) 
            out <= 0;
        else 
            out <= s1;
    end
endmodule