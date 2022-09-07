`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:28:49 11/20/2021 
// Design Name: 
// Module Name:    PC-NPC 
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

`define normal 0
`define b_beq 1
`define jump 2
`define jreg 3

`define equal 2'b00
`define big 2'b01
`define less 2'b10

module PC_NPC(
    input wire clk,
    input wire reset,
	input wire [31:0] F_PC,
	input wire [3:0] D_PCsel,
	input wire [31:0] D_PC,
	input wire [1:0] D_condition,
	input wire [31:0] D_extImm,
	input wire [25:0] D_index,
	input wire [31:0] D_rsValue,
	output reg [31:0] F_NPC
    );
	
	always @(*)
	begin
			case(D_PCsel)
				`normal:	F_NPC = F_PC + 4;
				`b_beq:	//有条件跳转 beq
				begin
					if(D_condition==`equal)
						F_NPC = D_PC + 4 + (D_extImm<<2);//有延迟槽 此处NPC已经比beq的指令多了4
					else		 // 此处的 F_PC = D_PC + 4
						F_NPC = F_PC + 4;//F_NPC = D_PC + 8;
				end
				`jump:		F_NPC = { F_PC[31:28], D_index, 2'b00 };// j, jal
				`jreg:   	F_NPC = D_rsValue;// jr
				default:  F_NPC = F_PC + 4;
			endcase
	end

endmodule
