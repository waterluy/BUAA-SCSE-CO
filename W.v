`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:03:07 11/21/2021 
// Design Name: 
// Module Name:    M_W 
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
module W(
    input wire clk,
    input wire reset,
	input wire IntReq,
	input wire [31:0] M_PC_i,
	input wire [7:0]  M_ALUop_i,
    input wire [31:0] M_MemRead_i,
    input wire [31:0] M_ALUout_i,
	input wire [31:0] M_HI_i,
	input wire [31:0] M_LO_i,
	input wire [31:0] M_CP0out_i,
	input wire 		  M_RegWrite_i,
	input wire [4:0]  M_RegA3_i,
	input wire [3:0]  M_RegWDsel_i,	
	output reg [31:0] W_PC_o,
	output reg [7:0]  W_ALUop_o,
    output reg [31:0] W_MemRead_o,
    output reg [31:0] W_ALUout_o,
	output reg [31:0] W_HI_o,
	output reg [31:0] W_LO_o,
	output reg [31:0] W_CP0out_o,
	output reg 		  W_RegWrite_o,
	output reg [4:0]  W_RegA3_o,
	output reg [3:0]  W_RegWDsel_o
    );
 
	always @( posedge clk )
	begin
		if(reset|IntReq)
		begin
			W_PC_o		 <= 32'h3000;
			W_RegWrite_o <= 0;
		end
		else
		begin
			W_PC_o		 <= M_PC_i;
			W_ALUop_o	 <= M_ALUop_i;
			W_MemRead_o	 <= M_MemRead_i;
			W_ALUout_o	 <= M_ALUout_i;
			W_HI_o		 <= M_HI_i;
			W_LO_o	 	 <= M_LO_i;		
			W_CP0out_o	 <= M_CP0out_i;		
			W_RegWrite_o <= M_RegWrite_i;
			W_RegA3_o	 <= M_RegA3_i;
			W_RegWDsel_o <= M_RegWDsel_i;
		end
	end

endmodule
