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
`define add 2
`define sub 3
`define sllv 4
`define srlv 5
`define srav 6
`define and0 7
`define or0 8
`define nor0 9
`define xor0 10
`define slt 11
`define sltu 12
`define ori 13
`define andi 14
`define xori 15
`define slti 16
`define sltiu 17
`define addi 18
`define addiu 19
`define sll 20
`define srl 21
`define sra 22
`define lui 23
`define mult 24
`define multu 25
`define div 26
`define divu 27
`define mthi 28
`define mtlo 29
`define lw 30
`define lh 31
`define lhu 32
`define lb 33
`define lbu 34
`define sw 35
`define sh 36
`define sb 37

module ALU(
	input wire [7:0]  ALUop,
    input wire [31:0] rs,//rs
    input wire [31:0] rt,//rt
	input wire [15:0] imm,
	input wire [4:0]  shamt,
    output reg [31:0] ALUout
    );
	
	wire [31:0] sign_imm, zero_imm;
	
	assign sign_imm = { {16{imm[15]}}, imm };
	assign zero_imm = { 16'd0, imm };

	always @(*) //����漰�Ƚϴ�Сһ���ǵü�$signed
	begin		//�ǵ�������ֵ
		case(ALUop)
		//˫�Ĵ������� 13
			`addu:	ALUout = rs + rt;
			`subu:  ALUout = rs - rt;
			`add:	ALUout = rs + rt;
			`sub:	ALUout = rs - rt;
			`sllv:	ALUout = rt << rs[4:0];//ֻȡ����λ������
			`srlv:	ALUout = rt >> rs[4:0];
			`srav:	ALUout = $signed(rt) >>> rs[4:0];//�����$signed
			`and0:	ALUout = rs & rt;
			`or0:	ALUout = rs | rt;
			`nor0:  ALUout = ~(rs | rt);
			`xor0:	ALUout = rs ^ rt;
			`slt:	ALUout = ( $signed(rs) < $signed(rt) );
			`sltu:	ALUout = ( rs < rt );
		//�Ĵ���imm����	7
			`ori:   ALUout = rs | zero_imm;
			`andi:	ALUout = rs & zero_imm;
			`xori:	ALUout = rs ^ zero_imm;
			`slti:	ALUout = ( $signed(rs) < $signed(sign_imm) );
			`sltiu:	ALUout = ( rs < sign_imm );
			`addi:	ALUout = rs + sign_imm;
			`addiu:	ALUout = rs + sign_imm;
		//�Ĵ���shamt����		
			`sll:	ALUout = rt << shamt;
			`srl:	ALUout = rt >> shamt;
			`sra:	ALUout = $signed(rt) >>> shamt;
		//lui	
			`lui:	ALUout = (zero_imm << 16);//����ֱ����16λ��imm
		//��д�ڴ�	
			`lw:	ALUout = rs + sign_imm;
			`lh:	ALUout = rs + sign_imm;
			`lhu:	ALUout = rs + sign_imm;
			`lb:	ALUout = rs + sign_imm;
			`lbu:	ALUout = rs + sign_imm;
			`sw:	ALUout = rs + sign_imm;
			`sh:	ALUout = rs + sign_imm;
			`sb:	ALUout = rs + sign_imm;
			default:	ALUout = 32'h66666666;
		endcase
	end	

endmodule
// sra : out = (rt >> shamt)|(({32{rt[31]}}) << (32-shamt));
// nor : out = (rs | rt) ^ 32'hffffffff;
