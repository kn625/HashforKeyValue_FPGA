`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/29 11:25:36
// Design Name: 
// Module Name: HashFunc.v
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


module HashFunc

	#(	parameter	FIFOWIDTH = 8'd128,
		parameter	KEYHASH_WIDTH1 = 8'd28,
		parameter	KEYHASH_WIDTH2 = 8'd24,
		parameter	KEYHASH_WIDTH3 = 8'd5
	)
	(
	input wire 							clk,
	input wire							rst,
	
	/************************与上游FIFO交互部分*****************************/
	output wire							oRdKeyClk,
	
	//上游FIFO读空信号
	input wire 							iRdKeyEmpty,
	input wire 							iRdKeyLenEmpty,
	
	//上游FIFO读使能信号，与FIFO中read enable信号对接
	output reg 							oRdKeyFifo_en,
	output reg 							oRdKeyLenFifo_en,
	
	input wire [FIFOWIDTH-1:0]			iKey,
	input wire [7:0]					iKeyLen,
	
	
	/*************************与下游FIFO交互部分****************************/
	output wire 						oWrHashClk,
	
	input wire 							iWrHashFull,
	output reg 							oWrHashFifo_en,
   
	//三个Hash值
	output reg [KEYHASH_WIDTH1-1:0]					oKeyHash_1,
	output reg [KEYHASH_WIDTH2-1:0]					oKeyHash_2,
	output reg [KEYHASH_WIDTH3-1:0]					oKeyHash_3
    );




localparam S_INIT 		=	3'd0;
localparam S_WAIT		= 	3'd1;//数据等待有效状态
localparam S_CALC		= 	3'd2;//数据模二计算状态
localparam S_PROCESS 	= 	3'd3;//数据处理输出状态
localparam S_DEFAULT 	= 	3'd4;//默认状态








/**************************状态转移码***************************/
reg [2:0]state_cur;
reg [5:0]									KeyCnt;
always @(posedge rst or posedge clk)begin
	if(rst)begin
		state_cur <= 0;
	end
	else begin
		case(state_cur)
		S_INIT:if(!iRdKeyLenEmpty)begin
			state_cur <= S_WAIT;
		end
		S_WAIT:if(!iRdKeyEmpty)begin
			if(KeyCnt == 1)begin
				state_cur <= S_PROCESS;
			end
			else begin
				state_cur <= S_CALC;
			end
		end
		S_CALC:if(!iRdKeyEmpty)begin
			if(KeyCnt == 1)begin
				state_cur <= S_PROCESS;
			end
		end
		S_PROCESS:if(!iWrHashFull)begin
			state_cur <= S_INIT;
		end
		default:begin
			state_cur <= S_INIT;
		end
		endcase
	end
end


/************************输出译码****************************/
reg [FIFOWIDTH-1:0]							tempStore;
reg [(FIFOWIDTH<<1)-1:0]					KeyBuffer;
/*
reg [KEYHASH_WIDTH1-1:0]					oKeyHash_1;
reg [KEYHASH_WIDTH2-1:0]					oKeyHash_2;
reg [KEYHASH_WIDTH3-1:0]					oKeyHash_3;
*/

always @(posedge rst or posedge clk)begin
	if(rst)begin
		tempStore <= 0;
		KeyCnt <= 0;
		oRdKeyFifo_en <= 0;
		oRdKeyLenFifo_en <= 0;
		oWrHashFifo_en <= 0;
		oKeyHash_1 <= 0;
		oKeyHash_2 <= 0;
		oKeyHash_3 <= 0;
		KeyBuffer <= 0;
	end
	else if(state_cur == S_INIT)begin
		tempStore <= 0;
		oWrHashFifo_en <= 0;
		oKeyHash_1 <= 0;
		oKeyHash_2 <= 0;
		oKeyHash_3 <= 0;
		KeyBuffer <= 0;
		if(!iRdKeyEmpty)begin
			oRdKeyFifo_en <= 1;
			if(iKeyLen&8'h0F)begin
				KeyCnt <= (iKeyLen >> 4)+1;
			end
			else begin
				KeyCnt <= (iKeyLen >> 4);
			end
		end
	end
	else if(state_cur == S_WAIT)begin//为接下来产生输出信号做数据准备
		tempStore <= iKey;
		KeyBuffer <= {128'b0,iKey};
		if(KeyCnt == 1)begin
			oRdKeyFifo_en <= 0;
			oRdKeyLenFifo_en <= 1;
		end
		else begin
			KeyCnt <= KeyCnt-1;
		end
	end
	else if(state_cur == S_CALC)begin
		if(KeyCnt == 1)begin
			oRdKeyLenFifo_en <= 1;
			oRdKeyFifo_en <= 0;
		end
		tempStore <= tempStore^iKey;
		KeyBuffer <= {KeyBuffer[127:0],iKey};
		KeyCnt <= KeyCnt-1;
	end
	else if(state_cur == S_PROCESS)begin
		oRdKeyLenFifo_en <= 0;
		oWrHashFifo_en <= 1;
		KeyCnt <= 0;
		oKeyHash_1 <= tempStore[27:0]^tempStore[55:28]^tempStore[83:56]^tempStore[112:84]^{13'b0,tempStore[127:113]};
		oKeyHash_2 <= tempStore[23:0]^tempStore[47:24]^tempStore[71:48]^tempStore[95:72]^tempStore[120:96]^{16'b0,tempStore[127:121]};
		oKeyHash_3 <= tempStore[4:0]^tempStore[9:5]^tempStore[14:10]^tempStore[19:15]^tempStore[24:20]^tempStore[30:25]^tempStore[34:31]^tempStore[40:35]^tempStore[45:41]^tempStore[50:46]^tempStore[55:51]^tempStore[60:56]^tempStore[65:61]^tempStore[70:66]^tempStore[75:71]^tempStore[80:76]^tempStore[85:81]^tempStore[90:86]^tempStore[95:91]^tempStore[100:96]^tempStore[105:101]^tempStore[110:106]^tempStore[115:111]^tempStore[120:116]^tempStore[125:121]^{3'b0,tempStore[127:126]};
	end
	else begin
		//oDataVal = 0;
		oWrHashFifo_en <= 0;
		oKeyHash_1 <= 0;
		oRdKeyFifo_en <= 0;
		oRdKeyLenFifo_en <= 0;
	end

end

assign oRdKeyClk 	= clk;
assign oWrHashClk 	= clk;
assign oHashData	= {oKeyHash_1,oKeyHash_2,oKeyHash_3,71'b0};



endmodule
