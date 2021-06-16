`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 12:59:10
// Design Name: 
// Module Name: immgen
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


module ImmGen (
    input [31:0] instr,
    output reg [31:0] out
    );
    always @(*) begin
        case (instr[6:0]) // opcode
            7'b1101111: begin // jal
                out <= { instr[31] == 0 ? 12'h0 : 12'hfff, instr[31], instr[19:12], instr[20], instr[30:21] } << 1;
            end
            7'b1100111: begin // jalr
                out <= { instr[31] == 0 ? 20'h0 : 20'hfffff, instr[31:20] };
            end
            7'b1100011: begin // beq, bne, blt, bge
                out <= { instr[31] == 0 ? 12'h0 : 12'hfff, instr[31], instr[7], instr[30:25], instr[11:8] } << 1;
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
            7'b0110111: begin // lui
                out <= instr[31:12] << 12;
            end
            7'b0010111: begin // auipc
                out <= instr[31:12] << 12;
            end
        endcase
    end
endmodule
