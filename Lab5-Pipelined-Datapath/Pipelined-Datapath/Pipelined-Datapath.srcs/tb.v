`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2021 21:38:00
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

module TOP_test ();
    reg clk, BTN;
    reg [7:0] sw;
    wire [7:0] led;
    wire [2:0] AN;
    wire [3:0] D;
    
    initial begin
        clk <= 0; sw <= 8'hff;
        #2 sw[7] <= 0; sw[5:0] <= 6'b100001;
        #80 $finish;
    end
    integer count=0;
    always begin 
        #1 clk <= ~clk;
        count = count+1;
        if(count == 27)
        count = 0;
    end

    TOP TOP (
        .clk(clk), .BTN(BTN),
        .sw(sw),
        .led(led),
        .AN(AN),
        .D(D)
    );
endmodule

module CPU_test();
    reg clk, rst;
    
    //IO_BUS
    wire [7:0] io_addr;      //led鍜宻eg鐨勫湴锟�????????
    wire [31:0] io_dout;     //杈撳嚭led鍜宻eg鐨勬暟锟�????????
    wire io_we;            //杈撳嚭led鍜宻eg鏁版嵁鏃剁殑浣胯兘淇″彿
    reg [31:0] io_din;        //鏉ヨ嚜sw鐨勮緭鍏ユ暟锟�?????
    
    //Debug_BUS
    reg [7:0] m_rf_addr;   //瀛樺偍锟�????????(MEM)鎴栧瘎�?�樺櫒锟�????????(RF)鐨勮皟璇曡鍙ｅ湴锟�????????
    wire [31:0] rf_data;    //浠嶳F璇诲彇鐨勬暟锟�?????
    wire [31:0] m_data;    //浠嶮EM璇诲彇鐨勬暟锟�?????

    //PC/IF/ID 娴佹按娈靛瘎瀛樺�???
    wire [31:0] pc;
    wire [31:0] pcd;
    wire [31:0] ir;
    wire [31:0] pcin;

    //ID/EX 娴佹按娈靛瘎瀛樺�???
    wire [31:0] pce;
    wire [31:0] a;
    wire [31:0] b;
    wire [31:0] imm;
    wire [4:0] rd;
    wire [31:0] ctrl;

    //EX/MEM 娴佹按娈靛瘎瀛樺�???
    wire [31:0] y;
    wire [31:0] bm;
    wire [4:0] rdm;
    wire [31:0] ctrlm;

    //MEM/WB 娴佹按娈靛瘎瀛樺�???
    wire [31:0] yw;
    wire [31:0] mdr;
    wire [4:0] rdw;
    wire [31:0] ctrlw;
    
    initial begin
        clk <= 0; rst <= 1; m_rf_addr <= 1; io_din = 3;
        #2 rst <= 0;
        #60 $finish;
    end
    integer count=0;
    always begin 
        #1 clk <= ~clk;
        count = count+1;
        if(count == 27)
        count = 0;
    end

    CPU CPU(
        .clk(clk), 
        .rst(rst),
    
    //IO_BUS
        .io_addr(io_addr),      //led和seg的地�?????????
        .io_dout(io_dout),     //输出led和seg的数�?????????
        .io_we(io_we),                 //输出led和seg数据时的使能信号
        .io_din(io_din),        //来自sw的输入数�?????????
    
    //Debug_BUS
        .m_rf_addr(m_rf_addr),   //存储�?????????(MEM)或寄存器�?????????(RF)的调试读口地�?????????
        .rf_data(rf_data),    //从RF读取的数�?????????
        .m_data(m_data),    //从MEM读取的数�?????????

    //PC/IF/ID 流水段寄存器
        .pc(pc),
        .pcd(pcd),
        .ir(ir),
        .pcin(pcin),

    //ID/EX 流水段寄存器
        .pce(pce),
        .a(a),
        .b(b),
        .imm(imm),
        .rd(rd),
        .ctrl(ctrl),

    //EX/MEM 流水段寄存器
        .y(y),
        .bm(bm),
        .rdm(rdm),
        .ctrlm(ctrlm),

    //MEM/WB 流水段寄存器
        .yw(yw),
        .mdr(mdr),
        .rdw(rdw),
        .ctrlw(ctrlw)
    );
endmodule
