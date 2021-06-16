`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 12:59:10
// Design Name: 
// Module Name: hazarddetection
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


module HazardDetectionUnit (
    input rst,
    input [4:0] rs1, rs2, rde,
    input m_rd_e,
    input branch, jump,
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
        else if(branch || jump) begin
            { fstall, dstall } <= 0;
            dflush <= 1;
            eflush <= 1;
        end
        else begin
            { fstall, dstall, dflush, eflush } <= 0;
        end
    end
endmodule
