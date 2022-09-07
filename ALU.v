`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:08:51 11/21/2021 
// Design Name: 
// Module Name:    ALU 
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

`define addu 0
`define subu 1
`define ori 2
`define lw 3
`define sw 4
`define lui 5

module ALU(
	input wire [4:0]  ALUop,
    input wire [31:0] srcA,
    input wire [31:0] srcB,
    output reg [31:0] ALUout
    );

	always @(*) //如果涉及比较大小一定记得加$signed
	begin		//记得阻塞赋值
		case(ALUop)
			`addu:	ALUout = srcA + srcB;
			`subu:  ALUout = srcA - srcB;
			`ori:   ALUout = srcA | srcB;
			`lw:	ALUout = srcA + srcB;
			`sw: 	ALUout = srcA + srcB;
			`lui:	ALUout = (srcB<<16);
			default:	ALUout = 32'dx;
		endcase
	end

endmodule
