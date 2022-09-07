`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:24:39 11/21/2021 
// Design Name: 
// Module Name:    D 
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
//excCode
`define noneExc 31
`define Int 0
`define Adel 4
`define Ades 5
`define RI 10
`define Ov 12
//ALUop
`define nop 43

module D(
    input wire clk,
	input wire reset,
	input wire stall,
	input wire IntReq,
	input wire clr_delay,
	input wire [31:0] EPC,
	input wire [31:0] F_PC_i,
	input wire [31:0] F_Instr_i,
	input wire [4:0]  F_excCode_i,
	input wire 		  F_bd_i,
	output reg [31:0] D_PC_o,
	output reg [31:0] D_Instr_o,
	output reg [4:0]  D_excCode_o,
	output reg        D_bd_o
    );
	
	always @( posedge clk )
	begin
		if(reset)
		begin
			D_PC_o	    <= 32'h0000_3000;
			D_Instr_o   <= 0;
			D_excCode_o <= `noneExc;
			D_bd_o	    <= 0;
		end
		else if(IntReq)
		begin
			D_PC_o	    <= 32'h0000_4180;
			D_Instr_o   <= 0;
			D_excCode_o <= `noneExc;
			D_bd_o	    <= 0;
		end
		else if(stall)
		begin
			D_PC_o      <= D_PC_o;
			D_Instr_o   <= D_Instr_o;
			D_excCode_o <= D_excCode_o;
			D_bd_o	    <= D_bd_o;
		end
		else if(clr_delay)//注意clr_delay优先级比stall低
		begin
			D_PC_o	    <= EPC;
			D_Instr_o   <= 0;
			D_excCode_o <= `noneExc;
			D_bd_o	    <= 0;
		end
		else
		begin
			D_PC_o      <= F_PC_i;
			D_Instr_o   <= F_Instr_i;
			D_excCode_o <= F_excCode_i;
			D_bd_o	    <= F_bd_i;
		end
	end
	
endmodule
