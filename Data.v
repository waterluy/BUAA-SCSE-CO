`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:48:43 12/03/2021 
// Design Name: 
// Module Name:    Data 
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
`define lw 30
`define lh 31
`define lhu 32
`define lb 33
`define lbu 34
`define sw 35
`define sh 36
`define sb 37

module Data(
    input wire [31:0] A,
    input wire [31:0] Din,
    input wire [7:0] ALUop,
	input wire [31:0] Win,
    output reg [31:0] Dout,
	output reg [3:0] byteen,
	output reg [31:0] bridge_wdata,
	output wire M_Adel,
	output wire M_Ades
    );
	
	always @(*)
	begin
		case(ALUop)
			`lw:	
			begin
				if( A[1:0] == 2'b00 )
				begin
					Dout = Din;
				end
				else
				begin
					Dout = 32'h77777777;
				end
			end
			`lh:
			begin
				if( A[1:0] == 2'b00 )//取低半字 符号扩展
					Dout = { {16{Din[15]}}, Din[15:0] };
				else if( A[1:0] == 2'b10 )// A[1] == 1 取高半字 符号扩展
					Dout = { {16{Din[31]}}, Din[31:16]};
				else
					Dout = 32'h77777777;
			end
			`lhu:
			begin
				if( A[1:0] == 2'b00 )//取低半字 零扩展
					Dout = { 16'b0, Din[15:0] };
				else if( A[1:0] == 2'b10 )// A[1] == 1 取高半字 零扩展
					Dout = { 16'b0, Din[31:16]};
				else
				begin
					Dout = 32'h77777777;
				end
			end
			`lb:
			begin
				if( A[1:0] == 2'b00 )//取byte0 符号扩展
					Dout = { {24{Din[7]}}, Din[7:0] };
				else if( A[1:0] == 2'b01 )//取byte1 符号扩展
					Dout = { {24{Din[15]}}, Din[15:8] };
				else if( A[1:0] == 2'b10 )//取byte2 符号扩展
					Dout = { {24{Din[23]}}, Din[23:16] };
				else// A[1:0]==2'b11 取byte3 符号扩展
					Dout = { {24{Din[31]}}, Din[31:24] };
			end
			`lbu:
			begin
				if( A[1:0] == 2'b00 )//取byte0 零扩展
				begin
					Dout = { 24'b0, Din[7:0] };
				end
				else if( A[1:0] == 2'b01 )//取byte1 零扩展
				begin
					Dout = { 24'b0, Din[15:8] };
				end
				else if( A[1:0] == 2'b10 )//取byte2 零扩展
				begin
					Dout = { 24'b0, Din[23:16] };
				end
				else// A[1:0]==2'b11 取byte3 零扩展
				begin
					Dout = { 24'b0, Din[31:24] };
				end
			end
			default:	
				Dout = Din;
		endcase
	end
	
	wire L_align, L_timer, L_range;
	
	assign L_align = ( (ALUop==`lw)&&(A[1:0]!=2'b00) ) ||
					 ( ((ALUop==`lh)||(ALUop==`lhu)) && (A[0]==1'b1) );
					 
	assign L_timer = ( ((ALUop==`lh)||(ALUop==`lhu)||(ALUop==`lb)||(ALUop==`lbu)) && 
					   ( ((A>=32'h0000_7F00)&&(A<=32'h0000_7F0B)) ||
						 ((A>=32'h0000_7F10)&&(A<=32'h0000_7F1B)) ) );
					  //计时器 0 寄存器地址	0x0000_7F00 至 0x0000_7F0B	计时器 0 的 3 个寄存器
					//计时器 1 寄存器地址	0x0000_7F10 至 0x0000_7F1B	计时器 1 的 3 个寄存器
	assign L_range = ( ((ALUop==`lw)||(ALUop==`lh)||(ALUop==`lhu)||(ALUop==`lb)||(ALUop==`lbu)) &&
					   (!( ((A>=32'h0000_0000)&&(A<=32'h0000_2FFF)) ||//DM
						   ((A>=32'h0000_7F00)&&(A<=32'h0000_7F0B)) ||//timer0
						   ((A>=32'h0000_7F10)&&(A<=32'h0000_7F1B)) )) );//timer1
						   
	assign M_Adel = L_align | L_timer | L_range;
	
	always @(*)
	begin
		case(ALUop)
			`sw:
			begin
				if( A[1:0] == 2'b00 )
				begin
					bridge_wdata = Win;
					byteen = 4'b1111;
				end
				else
				begin
					bridge_wdata = 32'h77777777;
					byteen = 4'b0000;
				end
			end
			`sh:
			begin
				if( A[1:0] == 2'b00 )//写低半字
				begin
					bridge_wdata = Win;
					byteen = 4'b0011;
				end
				else if( A[1:0] == 2'b10 )// A[1]==1 写高半字
				begin
					bridge_wdata = Win << 16;
					byteen = 4'b1100;
				end
				else
				begin
					bridge_wdata = 32'h77777777;
					byteen = 4'b0000;
				end
			end
			`sb:
			begin
				if( A[1:0] == 2'b00 )// 写byte0
				begin
					bridge_wdata = Win;
					byteen = 4'b0001;
				end
				else if( A[1:0] == 2'b01 )// 写byte1
				begin
					bridge_wdata = Win << 8;
					byteen = 4'b0010;
				end
				else if( A[1:0] == 2'b10 )// 写byte2
				begin
					bridge_wdata = Win << 16;
					byteen = 4'b0100;
				end
				else// A[1:0] == 2'b11 // 写byte3
				begin
					bridge_wdata = Win << 24;
					byteen = 4'b1000;
				end
			end
			default:
			begin
				bridge_wdata = Win;
				byteen = 4'b0000;
			end
		endcase
	end
	
	wire S_align, S_timer, S_count, S_range;
	
	assign S_align = ( (ALUop==`sw)&&(A[1:0]!=2'b00) ) ||
					 ( (ALUop==`sh)&&(A[0]==1'b1) );
					 
	assign S_timer = ( ((ALUop==`sh)||(ALUop==`sb)) && 
					   ( ((A>=32'h0000_7F00)&&(A<=32'h0000_7F0B)) ||
						 ((A>=32'h0000_7F10)&&(A<=32'h0000_7F1B)) ) );
					  //计时器 0 寄存器地址	0x0000_7F00 至 0x0000_7F0B	计时器 0 的 3 个寄存器
					//计时器 1 寄存器地址	0x0000_7F10 至 0x0000_7F1B	计时器 1 的 3 个寄存器
	assign S_count = ((ALUop==`sw)||(ALUop==`sh)||(ALUop==`sb)) &&
					 ((A==32'h0000_7F08)||(A==32'h0000_7F18));
					 
	assign S_range = ( ((ALUop==`sw)||(ALUop==`sh)||(ALUop==`sb)) &&
					   (!( ((A>=32'h0000_0000)&&(A<=32'h0000_2FFF)) ||//DM
						   ((A>=32'h0000_7F00)&&(A<=32'h0000_7F0B)) ||//timer0
						   ((A>=32'h0000_7F10)&&(A<=32'h0000_7F1B)) )) );//timer1
						   
	assign M_Ades = S_align | S_timer | S_count | S_range;

endmodule
