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

module test_fibonnaci ();
    reg clk, BTN;
    reg [7:0] sw;
    wire [7:0] led;
    wire [2:0] AN;
    wire [3:0] D;

    
    integer i;
    initial begin
        clk <= 0; BTN <= 0; sw[7] <= 1; sw[6:5] <= 0; sw[4:0] <= 1;
        #2 sw[7] <= 0;
        for (i = 0; i < 16; i=i+1) begin
            #5 BTN <= 1;
            #5 BTN <= 0;
            if(i==8 | i==9) 
            sw[5] <= 1;
            else sw[5] <= 0;
        end
        #4 $finish;
    end


    always #1 clk <= ~clk;

    TOP TOP (
        .clk(clk), .BTN(BTN),
        .sw(sw),
        .led(led),
        .AN(AN),
        .D(D)
    );
endmodule

module test_TOP ();
    reg clk, BTN;
    reg [7:0] sw;
    wire [7:0] led;
    wire [2:0] AN;
    wire [3:0] D;
    
    integer i;
    initial begin
        clk <= 0; BTN <= 0; sw[7] <= 1; sw[6:5] <= 0; sw[4:0] <= 5'b11111;
        #2 sw[7] <= 0;
        for (i = 0; i < 16; i=i+1) begin
            #5 BTN <= 1;
            #5 BTN <= 0; 
        end
        #4 $finish;
    end

    always #1 clk <= ~clk;

    TOP TOP (
        .clk(clk), .BTN(BTN),
        .sw(sw),
        .led(led),
        .AN(AN),
        .D(D)
    );
endmodule

module test_CPU ();
    reg clk, rst;

    wire [31:0] io_addr;
    wire [31:0] io_dout;
    wire io_we;
    //reg [31:0] io_din;

    reg [7:0] m_rf_addr;   // memory or regFile address
    wire [31:0] rf_data;   // regfile data out
    wire [31:0] m_data;    // memory data out
    wire [31:0] pc;

    initial begin
        clk <= 0; rst <= 1; m_rf_addr <= 0;
        #1 rst <= 0;
        #1 clk <= ~clk; m_rf_addr <= 10;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk; m_rf_addr <= 1;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk; m_rf_addr <= 0;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk; m_rf_addr <= 11;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk;
        #1 clk <= ~clk;
        
        #1 clk <= ~clk;
        #1 clk <= ~clk;
        #1 $finish;
    end

    CPU CPU(
        .clk(clk), 
        .rst(rst),
        
    //IO_BUS
        .io_addr(io_addr),      // led or seg address
        .io_dout(io_dout),     // data out
        .io_we(io_we),
        //.io_din(io_din),       // data in
    
    //Debug_BUS
        .m_rf_addr(m_rf_addr),   // memory or regFile address
        .rf_data(rf_data),   // regfile data out
        .m_data(m_data),    // memory data out
        .pc(pc)         // output pc current state
    );
endmodule

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
