`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 12:59:10
// Design Name: 
// Module Name: forwarding
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
