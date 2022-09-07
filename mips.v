`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:44:47 11/11/2021 
// Design Name: 
// Module Name:    mips 
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

module mips(
    input clk,
    input reset
    );
	
	//PCalu
	wire [31:0] PC;
	wire [31:0] rs_value;
	wire [31:0] condition;
	//IM
	wire [31:0] Instr;
	wire [5:0] op;
	wire [4:0] rs;
	wire [4:0] rt;
	wire [4:0] rd; 
	wire [4:0] shamt;
	wire [5:0] funct;
	wire [15:0] immediate;
	wire [25:0] address;
	//Controller
	wire [2:0] GRF_WD_sel;
    wire MemWrite;
    wire [3:0] ALUcontrol;
    wire ALUsrc;
    wire [2:0] RegDst;//  3'b000 rt; 3'b001 rd; 3'b010 $31
    wire RegWrite;
    wire [3:0] PC_sel;
	//GRF
	wire [4:0] A1;
	wire [4:0] A2;
	wire [4:0] A3;
	wire [31:0] WD;
	wire [31:0] RD1;
	wire [31:0] RD2;
	//ALU
	wire [31:0] srcA;
	wire [31:0] srcB;
	wire [31:0] ALUresult;
	//DM
	wire [31:0] MemAddr;
	wire [31:0] MemData;
	wire [31:0] MemRead;
	
	
	assign condition = ALUresult;
	assign rs_value = RD1;
	
	PCalu instance_PCalu (
    .clk(clk), 
    .reset(reset), 
    .PC_sel(PC_sel), 
	.condition(condition),
    .immediate(immediate), 
    .address(address), 
    .rs(rs_value), 
    .PC(PC)
    );
	
	
	IM instance_IM (
    .PC(PC), 
    .Instr(Instr), 
    .op(op), 
    .rs(rs), 
    .rt(rt), 
    .rd(rd), 
    .shamt(shamt), 
    .funct(funct), 
    .immediate(immediate), 
    .address(address)
    );
	
	
	Controller instance_Controller (
    .op(op), 
    .funct(funct), 
    .GRF_WD_sel(GRF_WD_sel), 
    .MemWrite(MemWrite), 
    .ALUcontrol(ALUcontrol), 
    .ALUsrc(ALUsrc), 
    .RegDst(RegDst), 
    .RegWrite(RegWrite), 
    .PC_sel(PC_sel)
    );
	
	
	assign A1 = rs;
	assign A2 = rt;
	assign A3 = ( (RegDst==`rd) ? rd    : 
				  (RegDst==`ra) ? 5'd31 :  rt );
	assign WD = ( (GRF_WD_sel==`MemtoReg) ? MemRead : 
				  (GRF_WD_sel==`PCplus4)  ? (PC+4)  : ALUresult);
	
	GRF instance_GRF (
    .clk(clk), 
    .reset(reset), 
    .RegWrite(RegWrite), 
    .A1(A1), // rs
    .A2(A2), // rt
    .A3(A3), // rt 或 rd
    .WD(WD), 
    .PC(PC), 
    .RD1(RD1), 
    .RD2(RD2)
    );
	
	
	assign srcA = RD1;
	assign srcB = ( ALUsrc ? {{16{immediate[15]}},immediate} : RD2 );//符号扩展
	
	ALU instance_ALU (
    .ALUcontrol(ALUcontrol), 
    .srcA(srcA), 
    .srcB(srcB), 
    .ALUresult(ALUresult)
    );
	
	
	assign MemAddr = ALUresult;
	assign MemData = RD2;
	
	DM instance_DM (
    .clk(clk), 
    .reset(reset), 
    .MemWrite(MemWrite), 
    .MemAddr(MemAddr), 
    .MemData(MemData), 
    .PC(PC), 
    .MemRead(MemRead)
    );

endmodule

/*
module MUX8
    #(parameter WIDTH=32) //定义的是时候这样
	(
	output reg [WIDTH - 1:0] out, 
	input [3:0] sel,
	input [WIDTH - 1:0] in0,
	input [WIDTH - 1:0] in1,
	input [WIDTH - 1:0] in2,
	input [WIDTH - 1:0] in3,
	input [WIDTH - 1:0] in4,
	input [WIDTH - 1:0] in5,
	input [WIDTH - 1:0] in6,
	input [WIDTH - 1:0] in7
    );

	always @(*) begin
		case(sel)
			0: out = in0;
			1: out = in1;
			2: out = in2;
			3: out = in3;
			4: out = in4;
			5: out = in5;
			6: out = in6;
			7: out = in7;
		endcase
	end

endmodule

MUX8 #(5) RegAdd3Mux(//这样使用
	.out(RegAdd3),
	.sel(RegAdd3Sel),
	.in0(rt),
	.in1(rd),
	.in2(5'd31)
	);
*/
