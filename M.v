`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:41:29 11/21/2021 
// Design Name: 
// Module Name:    M 
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
`define nop 43
//excCode
`define noneExc 31
`define Int 0
`define Adel 4
`define Ades 5
`define RI 10
`define Ov 12
module M(
    input wire clk,
    input wire reset,
	input wire IntReq,
	//input wire clr_delay,
	//input wire [31:0] EPC,
	input wire [31:0] E_PC_i,
    input wire [31:0] E_ALUout_i,
	input wire [31:0] E_HI_i,
	input wire [31:0] E_LO_i,
	input wire [7:0]  E_ALUop_i,
    input wire 		  E_MemWrite_i,
	input wire [4:0]  E_rt_i,
	input wire [4:0]  E_rd_i,
	input wire [31:0] E_rtValue_i,
	input wire 		  E_RegWrite_i,
	input wire [4:0]  E_RegA3_i,
	input wire [3:0]  E_RegWDsel_i,
	input wire [2:0]  TnewE_i,
	input wire [4:0]  E_excCode_i,
	input wire        E_bd_i,
	output reg [31:0] M_PC_o,
	output reg [31:0] M_ALUout_o,
	output reg [31:0] M_HI_o,
	output reg [31:0] M_LO_o,
	output reg [7:0]  M_ALUop_o,
	output reg 		  M_MemWrite_o,
	output reg [4:0]  M_rt_o,
	output reg [4:0]  M_rd_o,
	output reg [31:0] M_rtValue_o,
	output reg 		  M_RegWrite_o,
	output reg [4:0]  M_RegA3_o,
	output reg [3:0]  M_RegWDsel_o,
	output reg [2:0]  TnewM_o,
	output reg [4:0]  M_excCode_o,
	output reg        M_bd_o
    );

	always @( posedge clk )
	begin
		if(reset|IntReq)
		begin
			M_PC_o		 <= (IntReq    ? 32'h0000_4180 : 32'h3000);
			M_MemWrite_o <= 0;
			M_RegWrite_o <= 0;
			TnewM_o      <= 0;
			M_ALUop_o	 <= `nop;
			M_excCode_o  <= `noneExc;
			M_bd_o		 <= 0;	
		end
		else
		begin
			M_PC_o			<= E_PC_i;
			M_ALUout_o		<= E_ALUout_i;
			M_HI_o			<= E_HI_i;
			M_LO_o			<= E_LO_i;
			M_ALUop_o		<= E_ALUop_i;
			M_MemWrite_o	<= E_MemWrite_i;
			M_rt_o			<= E_rt_i;
			M_rd_o			<= E_rd_i;
			M_rtValue_o		<= E_rtValue_i;
			M_RegWrite_o	<= E_RegWrite_i;
			M_RegA3_o		<= E_RegA3_i;
			M_RegWDsel_o	<= E_RegWDsel_i;
			TnewM_o			<= ( ($signed(TnewE_i-1)>$signed(0)) ? (TnewE_i-1) : 0 );
			M_excCode_o		<= E_excCode_i;
			M_bd_o			<= E_bd_i;
		end
	end

endmodule
