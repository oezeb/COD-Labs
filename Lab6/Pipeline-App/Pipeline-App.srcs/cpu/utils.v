`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 12:59:10
// Design Name: 
// Module Name: utils
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


module REG #(parameter MSB = 31, LSB = 0)(
    input clk, hold, clear,
    input [MSB:LSB] in,
    output reg [MSB:LSB] out
    );
    initial begin
        out <= 0;
    end
    always @(posedge clk) begin
        if(clear) out <= 0;
        else if(hold) out <= out;
        else out <= in;
    end
endmodule

module ADD #(parameter MSB = 31, LSB = 0) (
    input [MSB:LSB] in0, in1,
    output [MSB:LSB] out
    );
    assign out = in0+in1;
endmodule

module MUX2 #(parameter MSB = 31, LSB = 0) (
    input [MSB:LSB] in0, in1,
    input sel,
    output reg [MSB:LSB] out
    );
    always @(*) begin
        case(sel)
            1'b0: out <= in0;
            1'b1: out <= in1;
        endcase
    end
endmodule

module MUX4 #(parameter MSB = 31, LSB = 0) (
    input [MSB:LSB] in0, in1, in2, in3,
    input [1:0]sel,
    output reg [MSB:LSB] out
    );
    always @(*) begin
        case(sel)
            2'b00: out <= in0;
            2'b01: out <= in1;
            2'b10: out <= in2;
            2'b11: out <= in3;
        endcase
    end
endmodule