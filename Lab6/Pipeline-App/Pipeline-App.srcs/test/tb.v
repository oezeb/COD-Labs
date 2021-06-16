`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.06.2021 14:36:08
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

module Top_test ();
    reg clk, rst;
    wire [6:0] seg;
    wire [7:0] an;

    initial begin
        clk <= 0; rst <= 0;
        #1000 $finish;
    end

    always #1 clk <= ~clk;

    TOP TOP(
        .CLK100MHZ(clk), .CPU_RESETN(rst),
        //.PS2_CLK(),
        //.PS2_DATA(),
        .SEG(seg),
        .AN(an)
        );
endmodule

module CPU_test();
    reg clk, rst;
    
    //IO_BUS
    wire [7:0] io_addr;      //led�?�宻eg�?�勫湴锟�?????????
    wire [31:0] io_dout;     //�?�撳嚭led�?�宻eg�?�勬暟锟�?????????
    wire io_we;            //�?�撳嚭led�?�宻eg�??版�?�?��?殑浣胯兘淇″彿
    reg [31:0] io_din;        //�?�ヨ嚜sw�?�勮緭�??ユ暟锟�?????
    
    //Debug_BUS
    reg [7:0] m_rf_addr;   //瀛樺�??锟�?????????(MEM)鎴栧瘎�?�樺櫒锟�?????????(RF)�?�勮皟璇曡�?�ｅ湴锟�?????????
    wire [31:0] rf_data;    //浠嶳F璇诲彇�?�勬暟锟�?????
    wire [31:0] m_data;    //浠嶮EM璇诲彇�?�勬暟锟�?????

    //PC/IF/ID 娴佹按娈�?�瘎瀛樺�????
    wire [31:0] pc;
    wire [31:0] pcd;
    wire [31:0] ir;
    wire [31:0] pcin;

    //ID/EX 娴佹按娈�?�瘎瀛樺�????
    wire [31:0] pce;
    wire [31:0] a;
    wire [31:0] b;
    wire [31:0] imm;
    wire [4:0] rd;
    wire [31:0] ctrl;

    //EX/MEM 娴佹按娈�?�瘎瀛樺�????
    wire [31:0] y;
    wire [31:0] bm;
    wire [4:0] rdm;
    wire [31:0] ctrlm;

    //MEM/WB 娴佹按娈�?�瘎瀛樺�????
    wire [31:0] yw;
    wire [31:0] mdr;
    wire [4:0] rdw;
    wire [31:0] ctrlw;
    
    initial begin
        clk <= 0; rst <= 1; io_din = 3;
        #1 rst <= 0;
        #_end $finish;
    end
    
    integer cnt = 0;
    integer _end=1000;
    integer __end;
    always@* __end <= _end-10;
    always begin 
        #1 clk <= ~clk;
        cnt <= cnt+1;
        if( cnt >= __end) m_rf_addr = cnt-__end;
    end
    
    CPU CPU(
        .clk(cnt < __end ? clk:0), 
        .rst(rst),
    
    //IO_BUS
        .io_addr(io_addr),      //led和seg的地�??????????
        .io_dout(io_dout),     //输出led和seg的数�??????????
        .io_we(io_we),                 //输出led和seg数�?�时的使能信�?�
        .io_din(io_din),        //�?�自sw的输入数�??????????
    
    //Debug_BUS
        .m_rf_addr(m_rf_addr),   //存储�??????????(MEM)或寄存器�??????????(RF)的调试读�?�地�??????????
        .rf_data(rf_data),    //从RF读�?�的数�??????????
        .m_data(m_data),    //从MEM读�?�的数�??????????

    //PC/IF/ID �?水段寄存器
        .pc(pc),
        .pcd(pcd),
        .ir(ir),
        .pcin(pcin),

    //ID/EX �?水段寄存器
        .pce(pce),
        .a(a),
        .b(b),
        .imm(imm),
        .rd(rd),
        .ctrl(ctrl),

    //EX/MEM �?水段寄存器
        .y(y),
        .bm(bm),
        .rdm(rdm),
        .ctrlm(ctrlm),

    //MEM/WB �?水段寄存器
        .yw(yw),
        .mdr(mdr),
        .rdw(rdw),
        .ctrlw(ctrlw)
    );
endmodule

