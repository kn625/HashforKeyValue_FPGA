`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: Corning
// 
// Create Date: 2018/01/17 17:01:40
// Design Name: 
// Module Name: HashTop.v
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

module HashTop
	#(	parameter	FIFOWIDTH = 8'd128,
		parameter	KEYHASH_WIDTH1 = 8'd28,
		parameter	KEYHASH_WIDTH2 = 8'd24,
		parameter	KEYHASH_WIDTH3 = 8'd5,
		parameter	KEYHASH_WIDTH = 8'd57
	)
	(
	input wire 								clk,
	input wire								rst,
	
	/************************与上游FIFO交互部分*****************************/
	output wire								oRdKeyClk,
	
	//上游FIFO读空信号
	input wire 								iRdKeyEmpty,
	input wire 								iRdKeyLenEmpty,
	
	//上游FIFO读使能信号，与FIFO中read enable信号对接
	output wire 							oRdKeyFifo_en,
	output wire 							oRdKeyLenFifo_en,	
	
	input wire [FIFOWIDTH-1:0]				iKey,
	input wire [7:0]						iKeyLen,
	
	
	/*************************与下游FIFO交互部分****************************/
	//下游三个读数据的时钟
	input wire 								iRdHashClk,
	
	output wire 							oRdHashEmpty,
	input wire 								iRdHashFifo_en,
	
	//三个Hash值
	output wire [KEYHASH_WIDTH-1:0]			oKeyHashFifo
    );




/*********************与下游FIFO接口信号*********************/
wire [KEYHASH_WIDTH-1 :0]					KeyHash;
wire [KEYHASH_WIDTH1-1:0]					KeyHash_1;
wire [KEYHASH_WIDTH2-1:0]					KeyHash_2;
wire [KEYHASH_WIDTH3-1:0]					KeyHash_3;

wire 										WrHashClk;

wire 										WrHashFifo_en;

//与下游FIFO接口的写满信号
wire 										WrHashFull;


HashFunc	HashFunc(
	.clk(clk),
	.rst(rst),
	
	.oRdKeyClk(oRdKeyClk),
	
	//上游FIFO读空信号
	.iRdKeyEmpty(iRdKeyEmpty),
	.iRdKeyLenEmpty(iRdKeyLenEmpty),
	
	//上游FIFO读使能信号，与FIFO中read enable信号对接
	.oRdKeyFifo_en(oRdKeyFifo_en),
	.oRdKeyLenFifo_en(oRdKeyLenFifo_en),
	
	.iKey(iKey),
	.iKeyLen(iKeyLen),
	
	.oWrHashClk(WrHashClk),
	
	//下游FIFO写满信号
	.iWrHashFull(WrHashFull),
	
	//下游FIFO写使能信号，与FIFO中write enable信号对接
	.oWrHashFifo_en(WrHashFifo_en),
	
	//三个Hash值
	.oKeyHash_1(KeyHash_1),
	.oKeyHash_2(KeyHash_2),
	.oKeyHash_3(KeyHash_3)
	
    );	

	
fifo_generator_0 KeyHash_FIFO_1(
	.rst(rst),        		// input wire rst
	
	.wr_clk(WrHashClk),  		// input wire wr_clk
	
	.rd_clk(iRdHashClk),  		// input wire rd_clk
	
	.din(KeyHash),        	// input wire [127 : 0] din
	
	.wr_en(WrHashFifo_en),    		// input wire wr_en
	
	.rd_en(iRdHashFifo_en),    		// input wire rd_en
	.dout(oKeyHashFifo),      		// output wire [127 : 0] dout
	
	.full(WrHashFull),      		// output wire full
	.empty(oRdHashEmpty)    			// output wire empty
    );

	
assign KeyHash = {KeyHash_1,KeyHash_2,KeyHash_3};
	
endmodule
