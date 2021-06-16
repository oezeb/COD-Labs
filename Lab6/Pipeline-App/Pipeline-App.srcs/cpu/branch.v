`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 12:59:10
// Design Name: 
// Module Name: branch
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




module Branch (
    input ctrl_branch,
    input [31:0] in0, in1,
    input [2:0] funct3,
    output reg branch
    );

    wire eq, ne, lt, ge; // equal, not equal, less than, greater or equal

    assign eq = in0 == in1;
    assign lt = in0 < in1;

    always @* begin
        if(ctrl_branch) begin
            case (funct3)
                3'b000: branch <= eq;  // beq
                3'b001: branch <= !eq; // bne
                3'b100: branch <= lt;  // blt
                3'b101: branch <= !lt;  // bge
                default: branch <= 0;
            endcase
        end
        else begin
            branch <= 0;
        end
    end
endmodule
