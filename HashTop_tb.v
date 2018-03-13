`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ICT
// Engineer: Corning
// 
// Create Date: 2017/12/29 10:27:42
// Design Name: 
// Module Name: HashTop_tb
// Project Name: HashTable
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


module HashTop_tb;



localparam	FIFOWIDTH 		= 8'd128;
//localparam	KEYHASH_WIDTH1 	= 8'd28;
//localparam	KEYHASH_WIDTH2 	= 8'd24;
//localparam	KEYHASH_WIDTH3 	= 8'd5;
localparam	KEYHASH_WIDTH 	= 8'd57;


reg 						clk;
reg 						rst;

/*****************输入部分********************/
//上游输入
wire 						iRdKeyClk;
wire 						iRdKeyFifo_en;
wire 						iRdKeyLenFifo_en;

//下游输入
wire 						iRdHashEmpty;
wire [KEYHASH_WIDTH-1:0]	iKeyHashFifo;

/********************输出部分*******************/
//上游输出
wire [FIFOWIDTH-1:0]		oKey;
wire [7:0]					oKeyLen;
reg 						oRdKeyEmpty;
reg 						oRdKeyLenEmpty;

//下游输出
wire 						oRdHashFifo_en;
reg 						oRdHashClk;


HashTop HashTop(
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
	
	
	/*************************与下游FIFO交互部分****************************/
	.iRdHashClk(oRdHashClk),
	
	.oRdHashEmpty(iRdHashEmpty),
	
	.iRdHashFifo_en(oRdHashFifo_en),
	
	//三个Hash值
	.oKeyHashFifo(iKeyHashFifo)
	);


/***********************时钟复位********************/
initial begin
    rst = 0;
    clk = 0;
	oRdHashClk = 0;
	//oRdHashFifo_en = 1;
    #5 rst = 1;
    #100 rst = 0;
    forever begin
        #10 clk <= ~clk;
		#13	oRdHashClk <= ~oRdHashClk;
    end   
end

assign oRdHashFifo_en = !iRdHashEmpty;

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
