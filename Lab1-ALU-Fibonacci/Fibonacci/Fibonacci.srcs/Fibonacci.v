`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2021 19:50:39
// Design Name: 
// Module Name: Fibonacci
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
    Fibonacci Fibonacci(
        .clk(clk), .rst(sw[7]), .en(BTN),
        .in(sw[6:0]),
        .out(led[6:0])
    );
endmodule

module Fibonacci #(parameter MSB = 6, LSB = 0) (
    input clk, rst, en,
    input [MSB:LSB] in,
    output reg [MSB:LSB] out
    );
    reg done;
    reg [1:0] count;
    reg [MSB:LSB] prev;

    always @(posedge clk) begin
        if(rst) begin
            out <= 0;
            prev <= 0;
            count <= 0;
            done <= 0;
        end
        else if(en == 1) begin
            if(done == 0) begin 
                done <= 1;
                prev <= out;
                if(count < 2) begin
                    out <= in;
                    count = count + 1;
                end
                else begin
                    out <= out + prev;
                end
            end
        end
        else begin
            done <= 0;
        end
    end
endmodule
