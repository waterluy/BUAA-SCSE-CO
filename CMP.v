`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:47:58 11/22/2021 
// Design Name: 
// Module Name:    CMP 
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
`define equal 2'b00
`define big 2'b01
`define less 2'b10
module CMP(
    input wire [31:0] A,
    input wire [31:0] B,
    output reg [1:0] CMPout
    );
	
	always @(*)	// 记得加$signed()
	begin		// 记得阻塞赋值 
		if( A==B )
			CMPout = `equal;
		else if( ($signed(A))>($signed(B)) )
			CMPout = `big;
		else
			CMPout = `less;
	end

endmodule
