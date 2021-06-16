`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.06.2021 18:11:42
// Design Name: 
// Module Name: TOP
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

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.05.2021 22:18:25
// Design Name: 
// Module Name: CPU
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

module TOP (
    input clk, BTN,
    input [7:0] sw,
    output [7:0] led,
    output [2:0] AN,
    output [3:0] D
    );
    wire clk_cpu;
    
    //IO_BUS
    wire [7:0] io_addr;      //led�?�宻eg�?�勫湴锟�???????
    wire [31:0] io_dout;     //�?�撳嚭led�?�宻eg�?�勬暟锟�???????
    wire io_we;            //�?�撳嚭led�?�宻eg�??版�?�?��?殑浣胯兘淇″彿
    wire [31:0] io_din;        //�?�ヨ嚜sw�?�勮緭�??ユ暟锟�?????
    
    //Debug_BUS
    wire [7:0] m_rf_addr;   //瀛樺�??锟�???????(MEM)鎴栧瘎�?�樺櫒锟�???????(RF)�?�勮皟璇曡�?�ｅ湴锟�???????
    wire [31:0] rf_data;    //浠嶳F璇诲彇�?�勬暟锟�?????
    wire [31:0] m_data;    //浠嶮EM璇诲彇�?�勬暟锟�?????

    //PC/IF/ID 娴佹按娈�?�瘎瀛樺�??
    wire [31:0] pc;
    wire [31:0] pcd;
    wire [31:0] ir;
    wire [31:0] pcin;

    //ID/EX 娴佹按娈�?�瘎瀛樺�??
    wire [31:0] pce;
    wire [31:0] a;
    wire [31:0] b;
    wire [31:0] imm;
    wire [4:0] rd;
    wire [31:0] ctrl;

    //EX/MEM 娴佹按娈�?�瘎瀛樺�??
    wire [31:0] y;
    wire [31:0] bm;
    wire [4:0] rdm;
    wire [31:0] ctrlm;

    //MEM/WB 娴佹按娈�?�瘎瀛樺�??
    wire [31:0] yw;
    wire [31:0] mdr;
    wire [4:0] rdw;
    wire [31:0] ctrlw;
  
    pdu pdu(
        .clk(clk),
        .rst(sw[7]),
        
    //ѡ��CPU������ʽ;
        .run(sw[6]), 
        .step(BTN),
        .clk_cpu(clk_cpu),

    //����switch�Ķ˿�
        .valid(sw[5]),
        .in(sw[4:0]),

    //���led��seg�Ķ˿� 
        .check(led[6:5]),  //led6-5:�鿴����
        .out0(led[4:0]),   //led4-0
        .an(AN),     //8�������?
        .seg(D),
        .ready(led[7]),        //led7
    
    //IO_BUS
        .io_addr(io_addr),
        .io_dout(io_dout),
        .io_we(io_we),
        .io_din(io_din),

    //Debug_BUS
        .m_rf_addr(m_rf_addr),
        .rf_data(rf_data),
        .m_data(m_data),

  //������ˮ�߼Ĵ������Խӿ�
        .pcin(pcin), .pc(pc),.pcd(pcd), .pce(pce),
        .ir(ir), .imm(imm), .mdr(mdr),
        .a(a), .b(b), .y(y), .bm(bm), .yw(yw),
        .rd(rd), .rdm(rdm), .rdw(rdw),
        .ctrl(ctrl), .ctrlm(ctrlm), .ctrlw(ctrlw)
    );
    CPU CPU(
        .clk(clk_cpu), 
        .rst(sw[7]),
    
    //IO_BUS
        .io_addr(io_addr),      //led和seg的地�????????
        .io_dout(io_dout),     //输出led和seg的数�????????
        .io_we(io_we),                 //输出led和seg数�?�时的使能信�?�
        .io_din(io_din),        //�?�自sw的输入数�????????
    
    //Debug_BUS
        .m_rf_addr(m_rf_addr),   //存储�????????(MEM)或寄存器�????????(RF)的调试读�?�地�????????
        .rf_data(rf_data),    //从RF读�?�的数�????????
        .m_data(m_data),    //从MEM读�?�的数�????????

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

/*
module TOP(
    input CLK100MHZ, CPU_RESETN,
    input PS2_CLK,
    input PS2_DATA,
    output [6:0]SEG,
    output [7:0]AN
    );
    reg CLK_50MHZ = 0;
    wire clk_out1;
    wire [7:0] keycode;
    
    reg [7:0] m_rf_addr = 0; 
    wire [31:0] m_data;

    reg [3:0] data [7:0];
    wire[31:0] out;

    assign out = { data[7], data[6], data[5], data[4], data[3], data[2], data[1], data[0] };

    always @(posedge CLK100MHZ) CLK_50MHZ<=~CLK_50MHZ;

    reg [31:0] count = 0;
    reg cpu_clk = 0;

    always @(posedge clk_out1) begin
        data[m_rf_addr] <= m_data[3:0];
        
        if(count >= 10_000_000) begin 
            cpu_clk <= ~cpu_clk;
            count <= 0;
        end
        else count <= count + 1;

        if( m_rf_addr >= 7) m_rf_addr <= 0;
        else m_rf_addr <= m_rf_addr + 1;
    end

    clk_wiz_0 clk_wiz_0(
        .clk_in1 (CLK100MHZ),
        .reset (CPU_RESETN),
        .clk_out1 (clk_out1)
        //.locked (locked)
    );

    CPU CPU(
        .clk(cpu_clk), 
        .rst(CPU_RESETN),
        .m_rf_addr(m_rf_addr),  
        .m_data(m_data)
    );

    seg7decimal sevenSeg (
        .x(out),
        .clk(CLK100MHZ),
        .seg(SEG[6:0]),
        .an(AN[7:0])
        //.dp(DP) 
    );    
endmodule


    keyboard keyboard(
        .clk(CLK_50MHZ), //50MHz
        .kclk(PS2_CLK),
        .kdata(PS2_DATA),
        .keycode(keycode)
    );*/
