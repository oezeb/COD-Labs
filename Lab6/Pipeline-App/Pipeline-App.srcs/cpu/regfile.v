`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 12:59:10
// Design Name: 
// Module Name: regfile
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


module RegFile (
    input clk, we,             // write enable
    input [31:0] wd,                // write data
    input [4:0] wa, ra0, ra1, ra2, // write, read address
    output [31:0] rd0, rd1, rd2     // read data
    );
    localparam SIZE = 32; 
    reg [31:0] memory[SIZE-1:0]; 

    assign rd0 = (we == 1 && ra0 == wa) ? wd : memory[ra0];
    assign rd1 = (we == 1 && ra1 == wa) ? wd : memory[ra1];
    assign rd2 = (we == 1 && ra2 == wa) ? wd : memory[ra2];

    initial begin
        memory[0] <= 0; // x0: null register
        memory[2] <= 8'hff; // sp: stack pointer
    end

    always @(posedge clk) begin
        if(wa != 0 & we == 1) begin
            memory[wa] <= wd;
        end
    end
endmodule
