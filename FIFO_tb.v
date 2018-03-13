`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/01/18 10:54:02
// Design Name: 
// Module Name: FIFO_tb
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


module FIFO_tb;


reg rst;
reg rd_clk;
reg wr_clk;
reg rd_en;
reg wr_en;
reg [127:0] din;

wire [127:0] dout;
wire full;
wire empty;

fifo_generator_0 KeyHash_FIFO(
	.rst(rst),        		// input wire rst
	
	.wr_clk(wr_clk),  		// input wire wr_clk
	
	.rd_clk(rd_clk),  		// input wire rd_clk
	
	.din(din),        	// input wire [127 : 0] din
	
	.wr_en(wr_en),    		// input wire wr_en
	
	.rd_en(rd_en),    		// input wire rd_en
	.dout(dout),      		// output wire [127 : 0] dout
	.full(full),      		// output wire full
	.empty(empty)    			// output wire empty
    );

/***********************时钟复位********************/
initial begin
    rst = 0;
    wr_clk = 0;
    rd_clk = 0;
    #5 rst = 1;
    #100 rst = 0;
    forever begin
        #10 wr_clk = ~wr_clk;
            rd_clk = ~rd_clk;
    end   
end


/***********************写FIFO(Based on First word fall through)**********************/



reg [127:0]	mem [0:9];
reg [1:0]state_w;
reg [3:0]i;

initial $readmemh("D:\\memKey.txt", mem);

always @(posedge wr_clk, posedge rst)begin
	if(rst)begin
		wr_en <= 1'b0;
		din <= 128'd0;
		i <= 0;
		state_w <= 0;
	end
	else if(!full)begin
		case(state_w)
		2'd0:begin
			wr_en <= 1;
			din <= mem[i];
			i <= i+1;
			state_w <= state_w+1;
		end
		2'd1:begin
			if(i == 4'd10)begin
				wr_en <= 1'b0;
				state_w = state_w+1;
			end
			else begin
				din <= mem[i];
				i <= i+1;
			end
		end
		default:begin		
			
		end
		endcase
	end

end

/***********************读FIFO(Based on First word fall through)**********************/
reg [127:0]			mem_o [0:9];
reg [2:0]			state_r;
reg [3:0]			o;
always @(posedge rd_clk , posedge rst)begin
	if(rst)begin
		rd_en <= 0;
		o <= 0;
		state_r <= 0;
	end
	else if(!empty)begin
		case(state_r)
		3'd0:begin
			rd_en <= 0;
			state_r <= state_r+1;
			//mem_o[o] <= dout;
			//o <= o+1;
		end
		3'd1:if(wr_en == 0)begin
			rd_en <= 1'b1;
			state_r = state_r+1;
		end
		3'd2:begin
			if(o == 4'd10)begin
				rd_en <= 1'b0;
				state_r = state_r+1;
			end
			else begin
				mem_o[o] <= dout;
				o <= o+1;
			end
		end
		default:begin
			rd_en <= 1'b0;
			state_r = 0;
		end
		endcase
	end
end


endmodule
