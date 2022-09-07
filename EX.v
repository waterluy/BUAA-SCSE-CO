`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:07:40 11/22/2021 
// Design Name: 
// Module Name:    EX 
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
module EX(
	input wire [4:0]  E_rs,////
	input wire [4:0]  E_rt,////
	input wire [4:0]  M_RegA3,////
	input wire [31:0] M_ALUout,////
	input wire [4:0]  W_RegA3,////
    input wire [31:0] E_rsValue,
    input wire [31:0] E_rtValue,
	input wire [31:0] E_extImm,
	input wire [4:0]  E_ALUop,
	input wire [3:0]  E_ALUsrc,
	output wire [31:0] E_ALUout
    );
	
	wire [31:0] srcA,srcB;
	assign srcA = E_rsValue;
	assign srcB = (E_ALUsrc==1) ? E_extImm : E_rtValue;
	
	ALU EXalu (
    .ALUop(E_ALUop), 
    .srcA(srcA), 
    .srcB(srcB), 
    .ALUout(E_ALUout)
    );

endmodule
