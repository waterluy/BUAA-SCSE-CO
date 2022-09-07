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
module D(
    input wire clk,
	input wire reset,
	input wire stall,
	input wire [31:0] F_PC_i,
	input wire [31:0] F_Instr_i,
	output reg [31:0] D_PC_o,
	output reg [31:0] D_Instr_o
    );
	
	always @( posedge clk )
	begin
		if(reset)
		begin
			D_PC_o	  <= 32'h0000_3000;
			D_Instr_o <= 0;
		end
		else if(stall)
		begin
			D_PC_o    <= D_PC_o;
			D_Instr_o <= D_Instr_o;
		end
		else
		begin
			D_PC_o    <= F_PC_i;
			D_Instr_o <= F_Instr_i;
		end
	end
	
endmodule
