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
/*IM[7:2]���� SR[15:10]��Ϊ 6 λ�ж�����λ���ֱ��Ӧ 6 ���ⲿ�жϡ�
��Ӧλ�� 1 ��ʾ�����жϣ��� 0 ��ʾ��ֹ�жϡ�
IE���� SR[0]��Ϊȫ���ж�ʹ�ܡ�
��λ�� 1 ��ʾ�����жϣ��� 0 ��ʾ��ֹ�жϡ�
EXL���� SR[1]��Ϊ�쳣����
��λ�� 1 ��ʾ�ѽ����쳣�����������жϣ��� 0 ��ʾ�����жϡ�
IP[7:2]���� Cause[15:10]��Ϊ 6 λ�������ж�λ���ֱ��Ӧ 6 ���ⲿ�ж�
��Ӧλ�� 1 ��ʾ���жϣ��� 0 ��ʾ���жϡ�*/
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
			ExcCode <= 0;//Ҫ��ʼ��Ϊ0 ������`noneExc;
			EPC <= 32'h3000;
			PRID <= 32'h66667777;
		end
		else if( EXLClr )
		begin
			//IM <= 0;
			EXL <= 0;//�� 0 ��ʾ�����ж�
			//BD <= 0;
			//ExcCode <= `noneExc;
			IP <= HWInt;
			//EPC <= 32'h3000;
		end
		else if(Int)//else if( IE && (EXL==0) && ((IM&HWInt)!=0) )
		begin
			//IM <= 0;//���������ж�
			EXL <= 1;//�ѽ����쳣�����������ж�
			BD <= M_bd;
			ExcCode <= `Int;
			IP <= HWInt;
			EPC <= (M_bd ? (M_PC-4) : M_PC);//��Ҫ�������
		end
		else if(Exc)//else if( (M_ExcCode!=`noneExc) && (EXL==0) )
		begin
			//IM <= 0;//���������ж�
			EXL <= 1;//�ѽ����쳣�����������ж�
			BD <= M_bd;//�Ƿ��ӳٲ�
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
