`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 12:59:10
// Design Name: 
// Module Name: control
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


module Control (
    input rst,
    input [6:0] opcode,
    output reg branch, jal, jalr, m_wr, m_rd, rf_wr,
    output reg [1:0] ALU_op, wb_sel, a_sel, b_sel
    );
    always @(*) begin
        if(rst) begin
            {branch, jal, jalr, m_wr, rf_wr, wb_sel } <= 0;
        end
        else begin
            case (opcode)
                7'b1101111: begin // jal
                    { rf_wr, jal } <= 2'b11;
                    { m_wr, m_rd, jalr } <= 0;
                    a_sel <= 2'b01; b_sel <= 2'b10;
                    ALU_op <= 2'b00;
                end
                7'b1100111: begin // jalr
                    { rf_wr, jalr } <= 2'b11;
                    { m_wr, m_rd, jal } <= 0;
                    a_sel <= 2'b01; b_sel <= 2'b10;
                    ALU_op <= 2'b00;
                end
                7'b1100011: begin // beq, bne, blt, bge
                    branch <= 1'b1;
                    { jal, jalr, rf_wr, m_wr, m_rd } <= 0;
                    a_sel <= 2'b00; b_sel <= 2'b00;
                    ALU_op <= 2'b01;
                end
                7'b0000011: begin // lw
                    { rf_wr, m_rd } <= 2'b11;
                    { jal, jalr, branch, m_wr } <= 0;
                    a_sel <= 2'b00; b_sel <= 2'b01;
                    wb_sel <= 2'b01;
                    ALU_op <= 2'b00;
                end
                7'b0100011: begin // sw
                    m_wr <= 1'b1;
                    { jal, jalr, branch, rf_wr, m_rd } <= 0;
                    a_sel <= 2'b00; b_sel <= 2'b01;
                    ALU_op <= 2'b00;
                end
                7'b0010011: begin // addi
                    rf_wr <= 1'b1;
                    { jal, jalr, branch, m_wr, m_rd } <= 0;
                    a_sel <= 2'b00; b_sel <= 2'b01;
                    wb_sel <= 2'b0;
                    ALU_op <= 2'b00;
                end
                7'b0110011: begin // add, sub, or, and
                    rf_wr <= 1'b1;
                    { jal, jalr, branch, m_wr, m_rd } <= 0;
                    a_sel <= 2'b00; b_sel <= 2'b00;
                    wb_sel <= 2'b0;
                    ALU_op <= 2'b10;
                end
                7'b0110111: begin // lui
                    rf_wr <= 1'b1;
                    { jal, jalr, branch, m_wr, m_rd } <= 0;
                    a_sel <= 2'b10; b_sel <= 2'b01;
                    wb_sel <= 2'b0;
                    ALU_op <= 2'b00;
                end
                7'b0010111: begin // auipc
                    rf_wr <= 1'b1;
                    { jal, jalr, branch, m_wr, m_rd } <= 0;
                    a_sel <= 2'b01; b_sel <= 2'b01;
                    wb_sel <= 2'b0;
                    ALU_op <= 2'b00;
                end
                default: begin
                    {jal, jalr, branch, m_wr, m_rd, rf_wr} <= 0;
                end
            endcase
        end
    end
endmodule