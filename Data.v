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
    input wire [1:0] A,
    input wire [31:0] Din,
    input wire [7:0] M_ALUop,
	input wire [31:0] Win,
    output reg [31:0] Dout,
	output reg [3:0] m_data_byteen,
	output reg [31:0] m_data_wdata
    );
	
	always @(*)
	begin
		case(M_ALUop)
			`lw:	
				Dout = Din;
			`lh:
			begin
				if( A[1] == 0 )//È¡µÍ°ë×Ö ·ûºÅÀ©Õ¹
				begin
					Dout = { {16{Din[15]}}, Din[15:0] };
				end	
				else// A[1] == 1 È¡¸ß°ë×Ö ·ûºÅÀ©Õ¹
				begin
					Dout = { {16{Din[31]}}, Din[31:16]};
				end
			end
			`lhu:
			begin
				if( A[1] == 0 )//È¡µÍ°ë×Ö ÁãÀ©Õ¹
				begin
					Dout = { 16'b0, Din[15:0] };
				end	
				else// A[1] == 1 È¡¸ß°ë×Ö ÁãÀ©Õ¹
				begin
					Dout = { 16'b0, Din[31:16]};
				end
			end
			`lb:
			begin
				if( A[1:0] == 2'b00 )//È¡byte0 ·ûºÅÀ©Õ¹
				begin
					Dout = { {24{Din[7]}}, Din[7:0] };
				end
				else if( A[1:0] == 2'b01 )//È¡byte1 ·ûºÅÀ©Õ¹
				begin
					Dout = { {24{Din[15]}}, Din[15:8] };
				end
				else if( A[1:0] == 2'b10 )//È¡byte2 ·ûºÅÀ©Õ¹
				begin
					Dout = { {24{Din[23]}}, Din[23:16] };
				end
				else// A[1:0]==2'b11 È¡byte3 ·ûºÅÀ©Õ¹
				begin
					Dout = { {24{Din[31]}}, Din[31:24] };
				end
			end
			`lbu:
			begin
				if( A[1:0] == 2'b00 )//È¡byte0 ÁãÀ©Õ¹
				begin
					Dout = { 24'b0, Din[7:0] };
				end
				else if( A[1:0] == 2'b01 )//È¡byte1 ÁãÀ©Õ¹
				begin
					Dout = { 24'b0, Din[15:8] };
				end
				else if( A[1:0] == 2'b10 )//È¡byte2 ÁãÀ©Õ¹
				begin
					Dout = { 24'b0, Din[23:16] };
				end
				else// A[1:0]==2'b11 È¡byte3 ÁãÀ©Õ¹
				begin
					Dout = { 24'b0, Din[31:24] };
				end
			end
			default:	
				Dout = Din;
		endcase
	end
	
	always @(*)
	begin
		case(M_ALUop)
			`sw:
			begin
				m_data_wdata = Win;
				m_data_byteen = 4'b1111;
			end
			`sh:
			begin
				if( A[1] == 0 )//Ð´µÍ°ë×Ö
				begin
					m_data_wdata = Win;
					m_data_byteen = 4'b0011;
				end
				else// A[1]==1 Ð´¸ß°ë×Ö
				begin
					m_data_wdata = Win << 16;
					m_data_byteen = 4'b1100;
				end
			end
			`sb:
			begin
				if( A[1:0] == 2'b00 )// Ð´byte0
				begin
					m_data_wdata = Win;
					m_data_byteen = 4'b0001;
				end
				else if( A[1:0] == 2'b01 )// Ð´byte1
				begin
					m_data_wdata = Win << 8;
					m_data_byteen = 4'b0010;
				end
				else if( A[1:0] == 2'b10 )// Ð´byte2
				begin
					m_data_wdata = Win << 16;
					m_data_byteen = 4'b0100;
				end
				else// A[1:0] == 2'b11 // Ð´byte3
				begin
					m_data_wdata = Win << 24;
					m_data_byteen = 4'b1000;
				end
			end
			default:
			begin
				m_data_wdata = Win;
				m_data_byteen = 4'b0000;
			end
		endcase
	end

endmodule
