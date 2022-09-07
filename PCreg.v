`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:07:17 11/23/2021 
// Design Name: 
// Module Name:    PCreg 
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
module PCreg(
    input wire clk,
    input wire reset,
	input wire stall,
    input wire [31:0] F_NPC_i,
    output reg [31:0] F_PC_o
    );
	
	always @( posedge clk )
	begin
		if(reset)
		begin
			F_PC_o <= 32'h3000;
		end
		else if(stall)
		begin
			F_PC_o <= F_PC_o;//¶³½áPCÖµ
		end
		else
		begin
			F_PC_o <= F_NPC_i;
		end
	end

endmodule
