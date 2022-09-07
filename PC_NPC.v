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
`define b_bne 2
`define b_bgez 3
`define b_bgtz 4
`define b_blez 5
`define b_bltz 6
`define jump 7
`define jreg 8

`define equal 2'b00
`define big 2'b01
`define less 2'b10

module PC_NPC(
    input wire clk,
    input wire reset,
	input wire [31:0] F_PC,
	input wire [3:0] D_PCsel,
	input wire [31:0] D_PC,
	input wire [1:0] D_cmpReg,
	input wire [1:0] D_cmpZero,
	input wire [15:0] D_imm,
	input wire [25:0] D_index,
	input wire [31:0] D_rsValue,
	output reg [31:0] F_NPC
    );
	
	wire [31:0] sign_imm;
	assign sign_imm = { {16{D_imm[15]}}, D_imm }; 
	
	always @(*)
	begin
			case(D_PCsel)
				`normal:	F_NPC = F_PC + 4;
				`b_beq:	//有条件跳转 beq
				begin
					if(D_cmpReg==`equal)
						F_NPC = D_PC + 4 + (sign_imm<<2);//有延迟槽 此处NPC已经比beq的指令多了4
					else		 // 此处的 F_PC = D_PC + 4
						F_NPC = F_PC + 4;//F_NPC = D_PC + 8;
				end
				`b_bne:
				begin
					if(D_cmpReg!==`equal)
						F_NPC = D_PC + 4 + (sign_imm<<2);
					else		 
						F_NPC = F_PC + 4;
				end
				`b_bgez:// rs >= 0
				begin
					if(D_cmpZero!=`less)
						F_NPC = D_PC + 4 + (sign_imm<<2);
					else		 
						F_NPC = F_PC + 4;
				end
				`b_bgtz:// rs > 0
				begin
					if(D_cmpZero==`big)
						F_NPC = D_PC + 4 + (sign_imm<<2);
					else		 
						F_NPC = F_PC + 4;
				end
				`b_blez:// rs <= 0
				begin
					if(D_cmpZero!=`big)
						F_NPC = D_PC + 4 + (sign_imm<<2);
					else		 
						F_NPC = F_PC + 4;
				end
				`b_bltz:// rs < 0
				begin
					if(D_cmpZero==`less)
						F_NPC = D_PC + 4 + (sign_imm<<2);
					else		 
						F_NPC = F_PC + 4;
				end
				`jump:		F_NPC = { F_PC[31:28], D_index, 2'b00 };// j, jal
				`jreg:   	F_NPC = D_rsValue;// jr jalr rs
				default:  F_NPC = F_PC + 4;
			endcase
	end

endmodule
