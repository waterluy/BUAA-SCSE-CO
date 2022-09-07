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
`define mfc0 38
`define mtc0 39
`define eret 40
`define mf 41
`define delay 42
`define nop 43
`define illegal 44

module ALU(
	input wire [7:0]  ALUop,
    input wire [31:0] rs,//rs
    input wire [31:0] rt,//rt
	input wire [15:0] imm,
	input wire [4:0]  shamt,
    output reg [31:0] ALUout,
	output reg E_Ov,
	output reg E_Adel,
	output reg E_Ades
    );
	
	wire [31:0] sign_imm, zero_imm;
	
	assign sign_imm = { {16{imm[15]}}, imm };
	assign zero_imm = { 16'd0, imm };

	always @(*) //如果涉及比较大小一定记得加$signed
	begin		//记得阻塞赋值
		case(ALUop)
		//双寄存器计算 13
			`addu:	ALUout = rs + rt;
			`subu:  ALUout = rs - rt;
			`add:	ALUout = rs + rt;
			`sub:	ALUout = rs - rt;
			`sllv:	ALUout = rt << rs[4:0];//只取低五位！！！
			`srlv:	ALUout = rt >> rs[4:0];
			`srav:	ALUout = $signed(rt) >>> rs[4:0];//必须加$signed
			`and0:	ALUout = rs & rt;
			`or0:	ALUout = rs | rt;
			`nor0:  ALUout = ~(rs | rt);
			`xor0:	ALUout = rs ^ rt;
			`slt:	ALUout = ( $signed(rs) < $signed(rt) );
			`sltu:	ALUout = ( rs < rt );
		//寄存器imm计算	7
			`ori:   ALUout = rs | zero_imm;
			`andi:	ALUout = rs & zero_imm;
			`xori:	ALUout = rs ^ zero_imm;
			`slti:	ALUout = ( $signed(rs) < $signed(sign_imm) );
			`sltiu:	ALUout = ( rs < sign_imm );
			`addi:	ALUout = rs + sign_imm;
			`addiu:	ALUout = rs + sign_imm;
		//寄存器shamt计算		
			`sll:	ALUout = rt << shamt;
			`srl:	ALUout = rt >> shamt;
			`sra:	ALUout = $signed(rt) >>> shamt;
		//lui	
			`lui:	ALUout = (zero_imm << 16);//不能直接用16位的imm
		//读写内存	
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
	
	reg [32:0] temp;
	always @(*)
	begin
		if(ALUop==`add)
		begin
			temp = {rs[31],rs} + {rt[31],rt};
			if( temp[32]!=temp[31] )
			begin
				E_Ov = 1;
				E_Adel = 0;
				E_Ades = 0;
			end
			else
			begin
				E_Ov = 0;
				E_Adel = 0;
				E_Ades = 0;
			end
		end
		else if(ALUop==`addi)
		begin
			temp = {rs[31],rs} + {sign_imm[31],sign_imm};
			if( temp[32]!=temp[31] )
			begin
				E_Ov = 1;
				E_Adel = 0;
				E_Ades = 0;
			end
			else
			begin
				E_Ov = 0;
				E_Adel = 0;
				E_Ades = 0;
			end
		end
		else if(ALUop==`sub)
		begin
			temp = {rs[31],rs} - {rt[31],rt};
			if( temp[32]!=temp[31] )
			begin
				E_Ov = 1;
				E_Adel = 0;
				E_Ades = 0;
			end
			else
			begin
				E_Ov = 0;
				E_Adel = 0;
				E_Ades = 0;
			end
		end
		else if((ALUop==`lw)||(ALUop==`lh)||(ALUop==`lhu)||(ALUop==`lb)||(ALUop==`lbu))
		begin
			temp = {rs[31],rs} + {sign_imm[31],sign_imm};
			if( temp[32]!=temp[31] )
			begin
				E_Ov = 0;
				E_Adel = 1;
				E_Ades = 0;
			end
			else
			begin
				E_Ov = 0;
				E_Adel = 0;
				E_Ades = 0;
			end
		end
		else if((ALUop==`sw)||(ALUop==`sh)||(ALUop==`sb))
		begin
			temp = {rs[31],rs} + {sign_imm[31],sign_imm};
			if( temp[32]!=temp[31] )
			begin
				E_Ov = 0;
				E_Adel = 0;
				E_Ades = 1;
			end
			else
			begin
				E_Ov = 0;
				E_Adel = 0;
				E_Ades = 0;
			end
		end
		else
		begin
			E_Ov = 0;
			E_Adel = 0;
			E_Ades = 0;
		end
	end

endmodule
// sra : out = (rt >> shamt)|(({32{rt[31]}}) << (32-shamt));
// nor : out = (rs | rt) ^ 32'hffffffff;
