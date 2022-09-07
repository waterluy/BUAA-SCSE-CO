`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:22:39 12/17/2021 
// Design Name: 
// Module Name:    CP0 
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
//excCode
`define noneExc 31
`define Int 0
`define Adel 4
`define Ades 5
`define RI 10
`define Ov 12

module CP0(
	input wire clk,
    input wire reset,
	input wire WE,
    input wire EXLClr,
    input wire [4:0] Aread,
    input wire [4:0] Awrite,
    input wire [31:0] Din,
    input wire [31:0] M_PC,
	input wire M_bd,
    input wire [4:0] M_ExcCode,
    input wire [5:0] HWInt,
    output wire IntReq,
    output reg [31:0] EPC,
    output wire [31:0] Dout
    );
/*IM[7:2]，即 SR[15:10]，为 6 位中断屏蔽位，分别对应 6 个外部中断。
相应位置 1 表示允许中断，置 0 表示禁止中断。
IE，即 SR[0]，为全局中断使能。
该位置 1 表示允许中断，置 0 表示禁止中断。
EXL，即 SR[1]，为异常级。
该位置 1 表示已进入异常，不再允许中断，置 0 表示允许中断。
IP[7:2]，即 Cause[15:10]，为 6 位待决的中断位，分别对应 6 个外部中断
相应位置 1 表示有中断，置 0 表示无中断。*/
	reg [4:0] ExcCode;
	reg [5:0] IM, IP;
	reg EXL, IE, BD;
	reg [31:0] PRID;
	assign Dout = (WE&&(Aread==Awrite)) ? Din :
				  (Aread==12) ? {16'b0, IM, 8'b0, EXL, IE}           ://SR
				  (Aread==13) ? {BD, 15'd0, IP, 3'd0, ExcCode, 2'b0} ://Cause      
				  (Aread==14) ? EPC     : //EPC
				  (Aread==15) ? PRID    : //PRID
										  32'h66667777;
	wire Int;
	wire Exc;
	assign Int = ( IE && (EXL==0) && ((IM&HWInt)!=0) );
	assign Exc = ( (M_ExcCode!=`noneExc) && (EXL==0) && (!Int));
										  
	assign IntReq = ( IE && (EXL==0) && ((IM&HWInt)!=0) )||( (M_ExcCode!=`noneExc) && (EXL==0) );
///////////////////////////////////////////////////////////////////////
	always @( posedge clk )
	begin
		if(reset)
		begin
			IM <= 6'b111111;
			EXL <= 0;
			IE <= 1;
			BD <= 0;
			IP <= 0;
			ExcCode <= 0;//要初始化为0 不能是`noneExc;
			EPC <= 32'h3000;
			PRID <= 32'h66667777;
		end
		else if( EXLClr )
		begin
			//IM <= 0;
			EXL <= 0;//置 0 表示允许中断
			//BD <= 0;
			//ExcCode <= `noneExc;
			IP <= HWInt;
			//EPC <= 32'h3000;
		end
		else if(Int)//else if( IE && (EXL==0) && ((IM&HWInt)!=0) )
		begin
			//IM <= 0;//屏蔽所有中断
			EXL <= 1;//已进入异常，不再允许中断
			BD <= M_bd;
			ExcCode <= `Int;
			IP <= HWInt;
			EPC <= (M_bd ? (M_PC-4) : M_PC);//不要刻意对齐
		end
		else if(Exc)//else if( (M_ExcCode!=`noneExc) && (EXL==0) )
		begin
			//IM <= 0;//屏蔽所有中断
			EXL <= 1;//已进入异常，不再允许中断
			BD <= M_bd;//是否延迟槽
			ExcCode <= M_ExcCode;
			IP <= HWInt;
			EPC <= (M_bd ? (M_PC-4) : M_PC);
		end
		else if(WE)
		begin
			case(Awrite)
				5'd12://SR
				begin
					{IM, EXL, IE} <= {Din[15:10], Din[1], Din[0]};
					IP <= HWInt;
				end
				5'd13:
				begin
					{BD, IP, ExcCode} <= {Din[31], Din[15:10], Din[6:2]};
				end 
				5'd14:
				begin
					EPC <= Din;
					IP <= HWInt;
				end
				5'd15:
				begin
					PRID <= Din;
					IP <= HWInt;
				end
				default: IP <= HWInt;
			endcase
		end
		else 
			IP <= HWInt;
	end

endmodule
