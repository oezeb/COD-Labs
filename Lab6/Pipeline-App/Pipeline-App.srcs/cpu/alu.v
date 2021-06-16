`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 12:59:10
// Design Name: 
// Module Name: alu
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

module ALU #(parameter MSB = 31, LSB = 0, F_MSB = 2, F_LSB = 0) (
    input [MSB:LSB] in0, in1,
    input [F_MSB:F_LSB] op,
    output reg [MSB:LSB] out
    );
    always @(*) begin
        case (op)
            `AND: out <= in0 & in1;
            `OR: out  <= in0 | in1;
            `ADD: out <= in0 + in1;
            `SUB: out <= in0 - in1;
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
