`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:10:18 11/11/2021 
// Design Name: 
// Module Name:    IM 
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
module IM(
    input [31:0] PC,
    output [31:0] Instr,
	output [5:0] op,
	output [4:0] rs,
	output [4:0] rt,
	output [4:0] rd,
	output [4:0] shamt,
	output [5:0] funct,
	output [15:0] immediate,
	output [25:0] address
    );
	
	wire [31:0] im_addr;
	reg [31:0] im[0:1023];
	
	initial  
	begin
		$readmemh("code.txt",im);	//必须加$$$$
	end
	
	assign im_addr = ( (PC - 32'h0000_3000) >> 2 );//重要
	assign Instr = im[im_addr];
	
	assign op = Instr[31:26];
	assign rs = Instr[25:21];
	assign rt = Instr[20:16];
	assign rd = Instr[15:11];
	assign shamt = Instr[10:6];
	assign funct = Instr[5:0];
	assign immediate = Instr[15:0];
	assign address = Instr[25:0];
	
endmodule
