`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:10:21 11/11/2021 
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
//`default_nettype none

/*addu    ? 4'b0001 :
subu    ? 4'b0010 :
ori     ? 4'b0011 :
(lw|sw) ? 4'b0100 :
beq     ? 4'b0101 :
ui     ? 4'b0110 : 4'b0000*/

`define addu 4'b0001
`define subu 4'b0010
`define ori 4'b0011
`define lwsw 4'b0100
`define beq 4'b0101
`define lui 4'b0110

module ALU(
    input [3:0] ALUcontrol,
    input [31:0] srcA,
    input [31:0] srcB,
    output [31:0] ALUresult
    );
	
	reg [31:0] temp;
	
	assign ALUresult = temp;
	
	always @(*)
	begin//srcB是经过 符号 扩展的立即数
		case(ALUcontrol)
			`addu:	
				temp <= srcA + srcB;
			`subu:
				temp <= srcA - srcB;
			`ori://ori的srcB是经过符号扩展的16位immediate
				temp <= ( srcA | ((srcB<<16)>>16) );//!!切记处理srcB用移位把它变成无符号数
			`lwsw:
				temp <= srcA + srcB;
			`beq:
				temp <= (srcA==srcB)?1:0;
			`lui:
				temp <= (srcB << 16);
			default:
				temp <= 32'dx; //
		endcase
	end

endmodule
