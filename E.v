`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:53:27 11/21/2021 
// Design Name: 
// Module Name:    E 
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
module E(
	input wire 			clk,
	input wire			reset,
	input wire			stall,
	input wire			IntReq,
	//input wire			clr_delay,
	//input wire [31:0]   EPC,
	input wire [31:0]	D_PC_i,
	input wire [4:0]  	D_rs_i,
	input wire [4:0]  	D_rt_i,
	input wire [4:0]  	D_rd_i,
    input wire [31:0] 	D_rsValue_i,
    input wire [31:0] 	D_rtValue_i,
	input wire [15:0] 	D_imm_i,
	input wire [4:0]  	D_shamt_i,
	input wire [7:0]  	D_ALUop_i,
	input wire 			D_MemWrite_i,
	input wire 			D_RegWrite_i,
	input wire [4:0]  	D_RegA3_i,
	input wire [3:0]	D_RegWDsel_i,
	input wire [2:0]    Tnew_i,
	input wire [4:0]    D_excCode_i,
	input wire          D_bd_i,
	output reg [31:0]	E_PC_o,
	output reg [4:0] 	E_rs_o,
	output reg [4:0] 	E_rt_o,
	output reg [4:0] 	E_rd_o,
    output reg [31:0] 	E_rsValue_o,
    output reg [31:0] 	E_rtValue_o,
	output reg [15:0] 	E_imm_o,
	output reg [4:0] 	E_shamt_o,
	output reg [7:0] 	E_ALUop_o,
	output reg 			E_MemWrite_o,
	output reg     		E_RegWrite_o,
	output reg [4:0] 	E_RegA3_o,
	output reg [3:0]	E_RegWDsel_o,
	output reg [2:0]    TnewE_o,
	output reg [4:0]    E_excCode_o,
	output reg          E_bd_o
    );

	always @( posedge clk )
	begin
		if(reset|IntReq)//if(reset|IntReq|clr_delay)
		begin
			E_PC_o			<= (IntReq    ? 32'h0000_4180 : 32'h3000);
			E_MemWrite_o	<= 0;
			E_RegWrite_o	<= 0;
			TnewE_o			<= 0;
			E_ALUop_o 		<= `nop;
			E_excCode_o	    <= `noneExc;
			E_bd_o			<= 0;
		end
		else if(stall)//ע�����ȼ�
		begin
			E_PC_o			<= D_PC_i;//////////!!!!һ�����ǧ��Ҫ����
			E_MemWrite_o	<= 0;
			E_RegWrite_o	<= 0;
			TnewE_o			<= 0;
			E_ALUop_o 		<= `nop;
			E_excCode_o	    <= `noneExc;/////////���������ܱ��֣�Ҫ���excCode,�������ǰ�����쳣
			E_bd_o			<= D_bd_i;//////////!!!!һ�����ǧ��Ҫ����
		end
		else
		begin
			E_PC_o			<= D_PC_i;
			E_rs_o			<= D_rs_i;
			E_rt_o			<= D_rt_i;
			E_rd_o			<= D_rd_i;
			E_rsValue_o 	<= D_rsValue_i;
			E_rtValue_o 	<= D_rtValue_i;
			E_imm_o 		<= D_imm_i;
			E_shamt_o		<= D_shamt_i;
			E_ALUop_o 		<= D_ALUop_i;
			E_MemWrite_o	<= D_MemWrite_i;
			E_RegWrite_o	<= D_RegWrite_i;
			E_RegA3_o	 	<= D_RegA3_i;
			E_RegWDsel_o	<= D_RegWDsel_i;
			TnewE_o			<= Tnew_i;
			E_excCode_o	    <= D_excCode_i;
			E_bd_o			<= D_bd_i;
		end
	end

endmodule
