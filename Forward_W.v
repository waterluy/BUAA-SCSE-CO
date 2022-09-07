`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:30:34 11/22/2021 
// Design Name: 
// Module Name:    Forward_W 
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
module Forward_W(
    input wire W_RegWrite,
    input wire [4:0] W_RegA3,
    input wire [31:0] W_RegWD,
    input wire [4:0] M_rt,
    input wire [31:0] M_rtValue0,
    output reg [31:0] M_rtValue1
    );
	
	always @(*)
	begin
		if( W_RegWrite && (W_RegA3!=0) && (M_rt==W_RegA3) )
			M_rtValue1 = W_RegWD;
		else
			M_rtValue1 = M_rtValue0;
	end

endmodule
