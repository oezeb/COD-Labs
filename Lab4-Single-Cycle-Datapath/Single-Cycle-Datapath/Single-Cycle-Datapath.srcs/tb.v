`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.04.2021 01:56:13
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

module test_ALU();
    parameter MSB = 31;
    parameter LSB = 0;
    
    localparam ADD = 0;
    localparam SUB = 1;
    localparam AND = 2;
    localparam OR = 3;
    localparam XOR = 4;

    reg [2:0] f;
    reg [MSB:LSB] a,b;

    wire [MSB:LSB] out;

    initial begin
        a <= 5; b <= 3; f <= ADD;
        #5 f <= SUB;
        #5 a <= 1; b <= 1; f <= AND;
        #5 a <= 0; b <= 0; f <= OR;
        #5 a <= 1; b <= 0; f <= XOR;
        #5 f <= 5;
        #5 $finish;
    end

    ALU ALU(
        .a(a), .b(b), 
        .f(f),   
        .out(out)
    );
endmodule


module test_TOP();
    reg mem_clk, cpu_clk, rst;
    
    wire [31:0] instr_dpra = pc/4;
    wire [31:0] instr_dpo;
    
    reg [31:0] reg_dpra;
    wire [31:0] reg_dpo;
    
    reg [31:0] data_dpra;
    wire [31:0] data_dpo;

    wire [31:0] pc;
     
    reg valid;
    reg [31:0] in;
    wire ready;
        
    integer i;
    initial begin
        rst <= 1; mem_clk <= 0; cpu_clk <= 0; reg_dpra <= 0; data_dpra <= 0;  in <= 1; valid <= 0;
        #2 rst <= 0;

        for (i = 0; i < 10; i = i+1) begin
            #2 reg_dpra <= 5;
            #2 reg_dpra <= 10;
            #2 reg_dpra <= 11;
            #2 reg_dpra <= 12;
            #2 reg_dpra <= 0;
            
            #2 cpu_clk <= 1; // clock
            #2 cpu_clk <= 0;
            /*reg_dpra <= 0; instr_dpra <= 0; data_dpra <= 0;
            for (j = 0; j < 32; j = j+1) begin
                #2 reg_dpra <= reg_dpra+1; instr_dpra <= instr_dpra+1; data_dpra <= data_dpra+1;
            end*/
        end
        #5 $finish;
    end

    always #1 mem_clk <= ~mem_clk;
    
    always@(*) begin
        // input
        if(ready) begin
            #3 valid <= 1;
        end
        else begin 
            valid <= 0;
        end
    end
    
    TOP TOP (
        .mem_clk(mem_clk), .rst(rst),
        .cpu_clk(cpu_clk),
        .valid(valid),
        .in(in),
        .ready(ready),
        .instr_dpra(instr_dpra), .data_dpra(data_dpra), .reg_dpra(reg_dpra),
        .instr_dpo(instr_dpo), .data_dpo(data_dpo), .reg_dpo(reg_dpo),
        .pc(pc)
    );
endmodule



module test_dist_mem ();
    reg clk;
    wire[31:0] data_in = 0;
    reg [31:0] dpra;
    wire [31:0] dpo;
    
    initial begin
        clk <= 0; dpra <= 0;
        #20  $finish;
    end

    
    always begin
        #1 clk <= ~clk; 
        if(dpra >= 10) dpra <= 0;
        else dpra <= dpra+1;
    end
    
    instr_mem data_mem(
        .clk(clk), .we(0),
        //.a(data_a),
        .dpra(dpra),
        .d(data_in),
        //.spo(data_spo),
        .dpo(dpo)
    );
endmodule
