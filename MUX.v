`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:57:00 11/20/2021 
// Design Name: 
// Module Name:    MUX 
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

`default_nettype none

module MUX16 #( parameter width=32 )
	(
    input wire [3:0] select,
    input wire [width-1:0] in0,
    input wire [width-1:0] in1,
	input wire [width-1:0] in2,
	input wire [width-1:0] in3,
	input wire [width-1:0] in4,
	input wire [width-1:0] in5,
	input wire [width-1:0] in6,
	input wire [width-1:0] in7,
	input wire [width-1:0] in8,
	input wire [width-1:0] in9,
	input wire [width-1:0] in10,
	input wire [width-1:0] in11,
	input wire [width-1:0] in12,
	input wire [width-1:0] in13,
	input wire [width-1:0] in14,
	input wire [width-1:0] in15,
    output reg [width-1:0] out
    );
	
	always @(*)
	begin
		case(select)
			0:	out = in0;
			1:	out = in1;
			2:	out = in2;
			3:	out = in3;
			4:	out = in4;
			5:	out = in5;
			6:	out = in6;
			7:	out = in7;
			8:	out = in8;
			9:	out = in9;
			10:	out = in10;
			11:	out = in11;
			12:	out = in12;
			13:	out = in13;
			14:	out = in14;
			15:	out = in15;
			default: out = 32'h66666666;
		endcase
	end

endmodule

/*
	input wire [width-1:0] in3,
	input wire [width-1:0] in4,
	input wire [width-1:0] in5,
	input wire [width-1:0] in6,
	input wire [width-1:0] in7,
	input wire [width-1:0] in8,
	input wire [width-1:0] in9,
	input wire [width-1:0] in10,
	input wire [width-1:0] in11,
	input wire [width-1:0] in12,
	input wire [width-1:0] in13,
	input wire [width-1:0] in14,
	input wire [width-1:0] in15,
	
			3:	out = in3;
			4:	out = in4;
			5:	out = in5;
			6:	out = in6;
			7:	out = in7;
			8:	out = in8;
			9:	out = in9;
			10:	out = in10;
			11:	out = in11;
			12:	out = in12;
			13:	out = in13;
			14:	out = in14;
			15:	out = in15;
*/
