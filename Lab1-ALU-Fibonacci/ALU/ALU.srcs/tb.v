`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.04.2021 20:38:10
// Design Name: 
// Module Name: test_bunch
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

//test Control

module tb();
    parameter MSB = 5;
    parameter LSB = 0;

    parameter NONE = 0;
    parameter F = 1;
    parameter A = 2;
    parameter B = 3;
    
    parameter ADD = 0;
    parameter SUB = 1;
    parameter AND = 2;
    parameter OR = 3;
    parameter XOR = 4;

    reg clk, en;
    reg [1:0] sel;
    reg [MSB:LSB] in;


    wire [MSB:LSB] out;
    wire z;

    initial begin
        clk <= 0; en <= 0; sel = NONE;
        #5 in <= 3; sel <= A;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= 2; sel <= B;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= ADD; sel <= F;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= 6; sel <= A;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= 3; sel <= B;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= SUB; sel <= F;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= 0; sel <= A;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= 1; sel <= B;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= AND; sel <= F;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= 1; sel <= A;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= 0; sel <= B;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= OR; sel <= F;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= 1; sel <= A;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= 1; sel <= B;
        #2 en <= 1;
        #5 en <= 0;
        
        #5 in <= XOR; sel <= F;
        #2 en <= 1;
        #5 en <= 0;
        
        #12 $finish;
    end
    
    always #1 clk = ~clk;

    Control #(.MSB(MSB), .LSB(LSB)) Control (
    .clk(clk), .en(en),
    .sel(sel),
    .in(in),
    .out(out),
    .z(z)
    );
endmodule

//test ALU
/*
module tb();
    parameter MSB = 5;
    parameter LSB = 0;
    
    parameter ADD = 0;
    parameter SUB = 1;
    parameter AND = 2;
    parameter OR = 3;
    parameter XOR = 4;

    reg clk;
    reg [2:0] f;
    reg [MSB:LSB] a,b;

    wire [MSB:LSB] out;
    wire z;

    initial begin
        clk <= 0;
        a <= 5; b <= 3; f <= ADD;
        #5 f <= SUB;
        #5 a <= 1; b <= 1; f <= AND;
        #5 a <= 0; b <= 0; f <= OR;
        #5 a <= 1; b <= 0; f <= XOR;
        #5 f <= 5;
        #5 $finish;
    end
    
    always #1 clk = ~clk;

    ALU  #(.MSB(MSB),.LSB(LSB)) ALU(
    .clk(clk),
    .a(a), .b(b), 
    .f(f),   
    .out(out),
    .z(z) 
    );
endmodule
*/

//test Decoder
/*
module tb ();

    parameter NONE = 0;
    parameter F = 1;
    parameter A = 2;
    parameter B = 3;

    reg clk, en;
    reg [1:0] sel;
    wire ea, eb, ef;

    initial begin
        clk <= 0; en <= 0; sel <= NONE; 
        #5 sel <= A;
        #5 en <= 1;
        #10 en <= 0;

        #5 sel <= B;
        #5 en <= 1;
        #10 en <= 0;
        
        #5 sel <= F;
        #5 en <= 1;
        #10 en <= 0;
        
        #5 $finish;
    end
    
    always #1 clk = ~clk;

    Decoder Decoder (
    .clk(clk), .en(en),
    .sel(sel),
    .ea(ea), .eb(eb), .ef(ef)
    );
endmodule
*/

//test signal edge
/*
module tb ();
    parameter MSB = 5;
    parameter LSB = 0;
    parameter VAL = 3;

    reg clk;
    reg [MSB:LSB] in;
    wire [MSB:LSB] out;

    initial begin
        clk <= 0; in <= 0;
        #15 in <= VAL;
        #7 in <= 0;
        #11 in <= VAL;
        #5 in <= 0;
        #12 in <= VAL;
        #6 in <= 0;
        #13 in <= VAL;
        #6 in <= 0;
        #14 in <= VAL;
        #7 in <= 0;
        #15 in <= VAL;
        #7 in <= 0;
        #16 in <= VAL;
        #8 in <= 0;
        #17 in <= VAL;
        #8 in <= 0;
        $finish;
    end
    
    always #1 clk = ~clk;

    signal_edge #(.MSB(MSB), .LSB(LSB)) signal_edge(
    .clk(clk),
    .in(in),
    .out(out)
    );
endmodule
*/