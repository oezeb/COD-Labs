`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.04.2021 18:56:07
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

//FPGA test

module FPGA_tb ();
    reg clk, rst, enq, deq;
    reg [3:0] in;

    wire BTN = rst;
    wire [7:0] sw = {enq, deq, 2'b0, in};

    wire [2:0] AN;
    wire [3:0] D;
    wire [7:0] led;

    initial begin
        clk <= 0; rst <= 1; in <= 0; enq <= 0; deq <= 0;
        #30 rst <= 0;
        #2 in <= 1;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 2;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #5 deq <= 1;
        #5 deq <= 0;
        #5 deq <= 1;
        #5 deq <= 0;
        
        
        #2 in <= 7;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 8;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 9;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 10;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 11;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 12;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 13;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 14;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 15;
        #5 enq <= 1;
        #5 enq <= 0;
        
        #5 $finish;
    end

    always #1 clk <= ~clk;

    FPGA FPGA(
        .clk(clk), .BTN(BTN),
        .sw(sw),
        .AN(AN),
        .D(D),
        .led(led)
    );
endmodule


//FIFO test

module FIFO_tb ();
    reg clk, rst, enq, deq;
    reg [3:0] in;
    wire full, empty;
    wire [3:0] front, curr_size;
    wire [3:0] ra;

    initial begin
        clk <= 0; rst <= 1; in <= 0; enq <= 0; deq <= 0;
        #5 rst <= 0;
        #2 in <= 1;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 2;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #5 deq <= 1;
        #5 deq <= 0;
        #5 deq <= 1;
        #5 deq <= 0;
        
        
        #2 in <= 7;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 8;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 9;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 10;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 11;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 12;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 13;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 14;
        #5 enq <= 1;
        #5 enq <= 0; 
        
        #2 in <= 15;
        #5 enq <= 1;
        #5 enq <= 0;
        
        #5 $finish;
    end

    always #1 clk <= ~clk;

    FIFO FIFO (
        .clk(clk), .rst(rst), 
        .enq(enq), .deq(deq),
        .in(in),
        .full(full), .empty(empty), 
        .front(ra), .curr_size(curr_size), //front : address(not value)
        .ra(ra), .rd(front)
    );
endmodule


//RegFile

module RegFile_tb();
    parameter A_MSB = 1, D_MSB = 2, A_LSB = 0, D_LSB = 0;
    reg clk;
    reg [D_MSB:D_LSB] wd;           // write data
    reg [A_MSB:A_LSB] wa, ra0, ra1; // write, read address
    reg we;                         // write enable
    wire [D_MSB:D_LSB] rd0, rd1;            // read data

    initial begin
        clk <= 0; we <= 0; ra0 <= 0; ra1 <= 2;
        #5 wd <= 5; wa <= 0;
        #5 we <= 1;
        #5 we <= 0;
        #5 wd <= 6; wa <= 2;
        #5 we <= 1;
        #5 we <=0;
        #5 $finish;
    end

    always #1 clk <= ~clk;

    RegFile #(.A_MSB(A_MSB),.D_MSB(D_MSB),.A_LSB(A_LSB),.D_LSB(D_LSB)) RegFile (
        .clk(clk),
        .wd(wd),           // write data
        .wa(wa), .ra0(ra0), .ra1(ra1), // write, read address
        .we(we),                         // write enable
        .rd0(rd0), .rd1(rd1)               // read data
    );
endmodule


// Distributed memory generator RAM 16x8 test

module dist_mem_gen_tb();
    reg clk, we;
    reg [3:0] a;
    reg [7:0] d;
    wire [7:0] spo;

    integer i;
    
    initial begin
        clk <= 0; we <= 0; d <= 8'o21; 
        for (i = 0; i < 15; i=i+1) begin
            a <= i; #5;
        end
        a <= 5;
        #5 we <= 1;
        #5 we <= 0;
        #5 $finish;
    end    
    
    always #1 clk <= ~clk;

    dist_mem_gen dist_mem_gen(
        .clk(clk), .we(we),
        .a(a),
        .d(d),
        .spo(spo)
    );
endmodule



// Block memory generator RAM 16x8 test
module blk_mem_gen_tb (
    output reg clka, ena, wea,
    output reg [7:0] dina,
    output reg [3:0] addra
    );
    
    initial begin
        clka <= 0; ena <= 0; wea <= 0; addra <= 0;
        #5 ena <= 1; 
        #5 wea <= 1;
        #5 addra <= 4'h1; dina <= 4'ha;
        #5 addra <= 4'h2; dina <= 4'hb;
        #5 addra <= 4'h3; dina <= 4'hc;
        #5 wea <= 0; addra <= 1;
        #10 $finish;
    end    
    
    always #1 clka <= ~clka;
endmodule

// write first
module write_first_tb ();
    wire clka, ena, wea;
    wire [7:0] dina;
    wire  [3:0] addra;
    wire [7:0] douta;

    blk_mem_gen_tb blk_mem_gen_tb ( 
        .clka(clka), .ena(ena), .wea(wea),
        .dina(dina),
        .addra(addra)
        );

    blk_mem_gen_w_first blk_mem_gen_w_first(
        .addra(addra),
        .clka(clka),
        .dina(dina),
        .douta(douta),
        .ena(ena),
        .wea(wea)
    );
endmodule

// read first
module read_first_tb ();
    wire clka, ena, wea;
    wire [7:0] dina;
    wire  [3:0] addra;
    wire [7:0] douta;

    blk_mem_gen_tb blk_mem_gen_tb ( 
        .clka(clka), .ena(ena), .wea(wea),
        .dina(dina),
        .addra(addra)
        );

    blk_mem_gen_r_first blk_mem_gen_r_first(
        .addra(addra),
        .clka(clka),
        .dina(dina),
        .douta(douta),
        .ena(ena),
        .wea(wea)
    );
endmodule

// no change
module no_change_tb ();
    wire clka, ena, wea;
    wire [7:0] dina;
    wire  [3:0] addra;
    wire [7:0] douta;

    blk_mem_gen_tb blk_mem_gen_tb ( 
        .clka(clka), .ena(ena), .wea(wea),
        .dina(dina),
        .addra(addra)
        );

    blk_mem_gen_no_change blk_mem_gen_no_change(
        .addra(addra),
        .clka(clka),
        .dina(dina),
        .douta(douta),
        .ena(ena),
        .wea(wea)
    );
endmodule
