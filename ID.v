`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:50:29 11/22/2021 
// Design Name: 
// Module Name:    ID 
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
module ID(
    input wire clk,
    input wire reset,
    input wire [31:0] W_PC,
    input wire [31:0] D_Instr,
    input wire        W_RegWrite,
    input wire [4:0]  W_RegA3,
	input wire [31:0] W_RegWD,
	output wire [4:0]  D_rs,
	output wire [4:0]  D_rt,
	output wire [31:0] D_rsValue,
	output wire [31:0] D_rtValue,
	output wire [31:0] D_extImm,
	output wire [25:0] D_index,
	output wire [4:0]  D_ALUop,
	output wire [3:0]  D_ALUsrc,
	output wire 	   D_MemWrite,
	output wire 	   D_RegWrite,
    output wire [4:0]  D_RegA3,
    output wire [3:0]  D_RegWDsel,
    output wire [3:0]  D_PCsel,
	output wire [2:0]  Tuse_rs,
	output wire [2:0]  Tuse_rt,
	output wire [2:0]  Tnew//从E级开始的Tnew
    );

	wire [4:0] D_rd;							
	wire [15:0] D_immediate;														
	wire D_ext;						
	wire [3:0] D_RegA3sel;																						//													//
														
	Controller Controller (					
    .Instr(D_Instr), 
    .rs(D_rs), //output
    .rt(D_rt), 
    .rd(D_rd), 
    .immediate(D_immediate), 
    .index(D_index), 
    .RegWrite(D_RegWrite), 
    .RegWDsel(D_RegWDsel), 
    .RegA3sel(D_RegA3sel), 
    .PCsel(D_PCsel), 
    .ALUop(D_ALUop), 
    .ALUsrc(D_ALUsrc), 
    .ext(D_ext), 
    .MemWrite(D_MemWrite),
	.Tuse_rs(Tuse_rs),
	.Tuse_rt(Tuse_rt),
	.Tnew(Tnew)
    );
	
	GRF GRF (
    .clk(clk), 
    .reset(reset), 
	.PC(W_PC),
    .A1(D_rs), 
    .A2(D_rt), 
    .A3(W_RegA3), 
    .WD(W_RegWD), 
    .RegWrite(W_RegWrite), 
    .RD1(D_rsValue), //output
    .RD2(D_rtValue)
    );
	
	EXT EXT (
    .ext(D_ext), 
    .data(D_immediate), 
    .ext_data(D_extImm)	//output
    );
	
	MUX16 #(5) mux_RegA3_D(
	.select(D_RegA3sel),
	.in0(D_rd),
	.in1(D_rt),
	.in2(5'd31),//(jal)
	.out(D_RegA3)	//output
	);

endmodule
