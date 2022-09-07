`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:24:41 11/11/2021 
// Design Name: 
// Module Name:    Controller 
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
`define rt 3'b000
`define rd 3'b001
`define ra 3'b010

`define Aluresult 3'b000
`define MemtoReg 3'b001
`define PCplus4 3'b010

module Controller(
    input [5:0] op,
    input [5:0] funct,
    output [2:0] GRF_WD_sel,
    output MemWrite,
    output [3:0] ALUcontrol,
    output ALUsrc,
    output [2:0] RegDst,
    output RegWrite,
    output [3:0] PC_sel
    );
	
	wire addu,subu,ori,lw,sw,beq,lui,jal,jr;
	
	assign addu = ( (op==0) & (funct==6'b100001) );
	assign subu = ( (op==0) & (funct==6'b100011) );
	assign ori = ( op==6'b001101 );
	assign lw = ( op==6'b100011 );
	assign sw = ( op==6'b101011 );
	assign beq = ( op==6'b000100 ); 
	assign lui = ( op==6'b001111 );
	assign jal = ( op==6'b000011 );
	assign jr = ( (op==0) & (funct==6'b001000) );

	assign GRF_WD_sel = ( lw  ? `MemtoReg : 
						  jal ? `PCplus4  : `Aluresult );//选择往寄存器存的是ALU计算结果3'b000 还是从内存取出来的数3'b001 PC+4 3'b010
	assign MemWrite = ( sw );
	assign ALUcontrol = ( addu    ? 4'b0001 :
						  subu    ? 4'b0010 :
						  ori     ? 4'b0011 :
						  (lw|sw) ? 4'b0100 :
						  beq     ? 4'b0101 :
						  lui     ? 4'b0110 : 4'b0000 );
	assign ALUsrc = ( ori | lw | sw | lui );//选择ALU第二个操作数是(rt)0 还是immediate1			  
	assign RegDst = ( ( addu | subu ) ? `rd :
					     jal          ? `ra : `rt );//选择要存的目的寄存器是rt0 还是rd1
	assign RegWrite = ( addu | subu | ori | lw | lui | jal );
	assign PC_sel = ( beq ? 4'b0001 : 
					  jal ? 4'b0010 : 
					  jr  ? 4'b0011 : 4'b0000 );

endmodule

/*
记录下 指令对应的控制信号如何取值

`define addu 1
`define subu 2
`define ori  3
`define lw   4
`define beq  5
`define lui  6
`define jal  7
`define jr   8

`define Aluresult 3'b000
`define MemtoReg 3'b001
`define PCplus4 3'b010

`define rt 3'b000
`define rd 3'b001
`define ra 3'b010

module Controller(
    input [5:0] op,
    input [5:0] funct,
    output [2:0] GRF_WD_sel,
    output MemWrite,
    output [3:0] ALUcontrol,
    output ALUsrc,
    output [2:0] RegDst,
    output RegWrite,
    output [3:0] PC_sel
    );
	
	wire [9:0] operation;
	
	always @(*)
	begin
		case(op)
			0:
			begin
				case(funct)
					6'b100001:	operation <= `addu;
					6'b100011:  operation <= `subu;
					6'b001000:	operation <= `jr;
					default:	operation <= 0;
				endcase	
			end
			6'b001101:	operation <= `ori;
			6'b100011:  operation <= `lw;
			6'b101011:  operation <= `sw;
			6'b000100:	operation <= `beq;
			6'b001111:	operation <= `lui;
			6'b000011:	operation <= `jal;
			default:	operation <= 0;
		endcase
	end
	
	always @(*)
	begin
		case(operation)
			`addu:
			begin
				GRF_WD_sel <= `Aluresult;
				MemWrite <= 0;
				ALUcontrol <= 4'b0001;
				ALUsrc <= 0;
				RegDst <= `rd;
				RegWrite <= 1;
				PC_sel <= 4'b0000;
			end
			`subu:
			begin
				GRF_WD_sel <= `Aluresult;
				MemWrite <= 0;
				ALUcontrol <= 4'b0010;
				ALUsrc <= 0;
				RegDst <= `rd;
				RegWrite <= 1;
				PC_sel <= 4'b0000;
			end
			`ori:
			begin
				GRF_WD_sel <= `Aluresult;
				MemWrite <= 0;
				ALUcontrol <= 4'b0011;
				ALUsrc <= 1;
				RegDst <= `rt;
				RegWrite <= 1;
				PC_sel <= 4'b0000;
			end
			default: 
		endcase
	end

endmodule

*/
