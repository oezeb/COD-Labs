`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2021 20:25:03
// Design Name: 
// Module Name: tb
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

//test fibonacci

module tb();
    
    reg clk, rst, en;
    reg [6:0] in;
    wire [6:0] out;

    initial begin
        clk <= 0; rst <= 1; en <= 0; in <= 2;
        #3 en <= 1;
        #5 rst <= 0;
        #19 en <= 0;
        #5 in <= 3;
        #6 en <= 1;
        #10 en <= 0;
        #5 in <= 4;
        #7 en <= 1;
        #10 en <= 0;
        #5 $finish;
    end

    always #5 clk=~clk;

    Fibonacci Fibonacci (
    .clk(clk), .rst(rst), .en(en),
    .in(in),
    .out(out)
    );
endmodule