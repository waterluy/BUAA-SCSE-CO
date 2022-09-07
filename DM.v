`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:00:07 11/21/2021 
// Design Name: 
// Module Name:    DM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module DM(
	input wire clk,
    input wire reset,
	input wire [31:0] PC,
	input wire MemWrite,
    input wire [31:0] A,
    input wire [31:0] D,
    output wire [31:0] MemRead
    );
	
	reg [31:0] dm[0:3072];
	wire [31:0] dm_addr;
	assign dm_addr = (A>>2);	
	//sw/lw指令的imm都是字节偏移量 直接相加后 需 右移2位！！！
	assign MemRead = dm[dm_addr];
	
	integer i;
	
	always @( posedge clk )
	begin
		if(reset)
		begin
			for( i=0; i<3072; i=i+1 )
				dm[i] <= 32'd0;
		end	
		else if(MemWrite)
		begin
			dm[dm_addr] <= D;
			$display("%d@%08h: *%08h <= %08h", $time, PC, A, D);
		end
	end

endmodule
