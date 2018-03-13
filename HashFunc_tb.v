`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/27 16:16:50
// Design Name: 
// Module Name: PiplineDataFetch_tb
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


module HashFunc_tb;


localparam	FIFOWIDTH = 8'd128;
localparam	KEYHASH_WIDTH1 = 8'd28;
localparam	KEYHASH_WIDTH2 = 8'd24;
localparam	KEYHASH_WIDTH3 = 8'd5;


reg clk;
reg rst;

wire iRdKeyClk;
wire iWrHashClk;

reg oRdKeyEmpty;
reg oRdKeyLenEmpty;
wire [FIFOWIDTH-1:0]oKey;
wire [7:0]oKeyLen;

wire iRdKeyFifo_en;
wire iRdKeyLenFifo_en;

wire iWrHashFifo_en;
reg oWrHashFull;

wire [KEYHASH_WIDTH1-1:0]iKeyHash_1;
wire [KEYHASH_WIDTH2-1:0]iKeyHash_2;
wire [KEYHASH_WIDTH3-1:0]iKeyHash_3;

HashFunc	U(
	.clk(clk),
	.rst(rst),

	/************************与上游FIFO交互部分*****************************/
	
	.oRdKeyClk(iRdKeyClk),
	
	//上游FIFO读空信号
	.iRdKeyEmpty(oRdKeyEmpty),
	.iRdKeyLenEmpty(oRdKeyLenEmpty),

	//上游FIFO读使能信号，与FIFO中read enable信号对接
	.oRdKeyFifo_en(iRdKeyFifo_en),
	.oRdKeyLenFifo_en(iRdKeyLenFifo_en),
	
	
	
	
	
	.iKey(oKey),
	.iKeyLen(oKeyLen),
	
	
	.oWrHashClk(iWrHashClk),
	.iWrHashFull(oWrHashFull),
	.oWrHashFifo_en(iWrHashFifo_en),
	

	.oKeyHash_1(iKeyHash_1),
	.oKeyHash_2(iKeyHash_2),
	.oKeyHash_3(iKeyHash_3)
    );
	

/***********************时钟复位********************/
initial begin
    rst = 0;
    clk = 0;
	//oKeyLen = 8'h40;
	oWrHashFull = 0;
    #5 rst = 1;
    #100 rst = 0;
    forever begin
        #10 clk = ~clk;
    end   
end





/*********************模仿FIFO数据输出***********************/
reg [3:0]i_key;
reg [3:0]i_keyLen;
reg [7:0]			memKeyLen	[0:3];
reg [FIFOWIDTH-1:0]	memKey 		[0:9];
reg enable;
initial $readmemh("D:\\memKey.txt", memKey);
initial $readmemh("D:\\memKeyLen.txt", memKeyLen);

always @(posedge rst or posedge clk)begin
	if(rst)begin
		i_key <= 0;
		i_keyLen <= 0;
		oRdKeyEmpty <= 0;
		oRdKeyLenEmpty <= 0;
		enable <= 1;
	end
	else if(enable)begin
		if(iRdKeyFifo_en)begin
			i_key <= i_key+1;
		end
		if(iRdKeyLenFifo_en)begin
			i_keyLen <= i_keyLen+1;
		end
		if(i_keyLen == 3)begin
			enable <= 0;
			oRdKeyEmpty <= 1;
			oRdKeyLenEmpty <= 1;
			
		end
	end
end


assign oKey = memKey[i_key];
assign oKeyLen = memKeyLen[i_keyLen];

endmodule
