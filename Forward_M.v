`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:07:12 11/22/2021 
// Design Name: 
// Module Name:    Forward_M 
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
module Forward_EM(
	input wire E_RegWrite,
    input wire [4:0] E_RegA3,
	input wire [31:0] E_RegWD,
	input wire M_RegWrite,
    input wire [4:0] M_RegA3,
	input wire [31:0] M_RegWD,
    input wire [4:0] D_rs,
    input wire [4:0] D_rt,
    input wire [31:0] D_rsValue0,
    input wire [31:0] D_rtValue0,
	output reg [31:0] D_rsValue1,
    output reg [31:0] D_rtValue1
    );
	//D级需要接收来自E级和M级的转发
	always @(*)
	begin
		if( E_RegWrite && (E_RegA3!=0) && (D_rs==E_RegA3) )
			D_rsValue1 = E_RegWD;
		else if( M_RegWrite && (M_RegA3!=0) && (D_rs==M_RegA3) )
			D_rsValue1 = M_RegWD;
		else
			D_rsValue1 = D_rsValue0;
	end
	
	always @(*)
	begin
		if( E_RegWrite && (E_RegA3!=0) && (D_rt==E_RegA3) )
			D_rtValue1 = E_RegWD;
		else if( M_RegWrite && (M_RegA3!=0) && (D_rt==M_RegA3) )
			D_rtValue1 = M_RegWD;
		else
			D_rtValue1 = D_rtValue0;
	end
    
endmodule
