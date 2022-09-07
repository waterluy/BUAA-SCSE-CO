`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:40:44 11/22/2021 
// Design Name: 
// Module Name:    IF 
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
module IF(
    input wire clk,
    input wire reset,
	input wire [3:0] D_PCsel,
	input wire [1:0] condition,
	input wire [31:0] D_extImm,
	input wire [25:0] D_index,
	output wire [31:0] F_PC,
	output wire [31:0] F_Instr
    );
	
	PC_NPC instance_PC (
    .clk(clk), 
    .reset(reset), 
    .PC_sel(D_PCsel), 
	.condition(condition),
    .PC(F_PC)//output
    );
	
	IM instance_IM (
    .PC(F_PC), 								
    .Instr(F_Instr)//output
    );	


endmodule
