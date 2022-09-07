`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:01:19 11/22/2021 
// Design Name: 
// Module Name:    Forward_E 
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
module Forward_MW(
    input wire M_RegWrite,
    input wire [4:0] M_RegA3,
	input wire [31:0] M_RegWD,
	input wire W_RegWrite,
    input wire [4:0] W_RegA3,
	input wire [31:0] W_RegWD,
    input wire [4:0] E_rs,
    input wire [4:0] E_rt,
    input wire [31:0] E_rsValue0,
    input wire [31:0] E_rtValue0,
	output reg [31:0] E_rsValue1,
    output reg [31:0] E_rtValue1
    );

	always @(*)
	begin
		if( M_RegWrite && (M_RegA3!=0) && (E_rs==M_RegA3) )
			E_rsValue1 = M_RegWD;
		else if( W_RegWrite && (W_RegA3!=0) && (E_rs==W_RegA3) )
			E_rsValue1 = W_RegWD;
		else
			E_rsValue1 = E_rsValue0;
			
		if( M_RegWrite && (M_RegA3!=0) && (E_rt==M_RegA3) )
			E_rtValue1 = M_RegWD;
		else if( W_RegWrite && (W_RegA3!=0) && (E_rt==W_RegA3) )
			E_rtValue1 = W_RegWD;
		else
			E_rtValue1 = E_rtValue0;
	end 

endmodule
