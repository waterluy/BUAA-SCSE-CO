`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:51:11 11/20/2021 
// Design Name: 
// Module Name:    mips 
// Project Name: 
// Target Devices: 
// Tool versions:  ，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，，  
// Description: 第一版流水线CPU
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`default_nettype none

`define ALUout 0
`define MemtoReg 1
`define PCplus8 2

`define lui 5

module mips(
    input wire clk, 
    input wire reset
    );
/*///////// !*stage F*! //////////////////////////////////*/
	wire [31:0] F_PC,F_Instr,F_NPC;
	
	PCreg RegPC (
    .clk(clk), 
    .reset(reset), 
	.stall(stall),
    .F_NPC_i(F_NPC), 
    .F_PC_o(F_PC)//output
    );
	
	PC_NPC NPC (
    .clk(clk), 
    .reset(reset), 
	.F_PC(F_PC),
    .D_PCsel(D_PCsel), 
	.D_PC(D_PC),
	.D_condition(D_condition),
	.D_extImm(D_extImm),
	.D_index(D_index),
	.D_rsValue(D_rsValue1),
    .F_NPC(F_NPC)//output
    );
	
	IM IF_IM (
    .PC(F_PC), 								
    .Instr(F_Instr)//output
    );
	
/*///////// !*stage D*! //////////////////////////////////*/							
	wire [31:0] D_PC, D_Instr;               
	                                        
	D RegD (                          
    .clk(clk),                              
    .reset(reset), 	
	.stall(stall),
	.F_PC_i(F_PC),							
    .F_Instr_i(F_Instr),					
	.D_PC_o(D_PC),//output
	.D_Instr_o(D_Instr)
    );	
	
	wire D_RegWrite,D_MemWrite;						
	wire [3:0] D_RegWDsel, D_RegA3sel, D_PCsel, D_ALUsrc;	
	wire [4:0] D_ALUop;
	wire [4:0] D_rs, D_rt, D_RegA3;	
	wire [25:0] D_index;
	wire [31:0] D_rsValue0, D_rtValue0, D_extImm;
	wire [2:0] Tuse_rs, Tuse_rt, Tnew;
	
	ID ID_CU_GRF (
    .clk(clk), 
    .reset(reset), 
    .W_PC(W_PC), 
    .D_Instr(D_Instr), 
    .W_RegWrite(W_RegWrite), 
    .W_RegA3(W_RegA3), 
    .W_RegWD(W_RegWD), 
	.D_rs(D_rs),//output
	.D_rt(D_rt),
    .D_rsValue(D_rsValue0), 
    .D_rtValue(D_rtValue0), 
    .D_extImm(D_extImm), 
	.D_index(D_index),
    .D_ALUop(D_ALUop), 
    .D_ALUsrc(D_ALUsrc), 
    .D_MemWrite(D_MemWrite), 
    .D_RegWrite(D_RegWrite), 
    .D_RegA3(D_RegA3), 
    .D_RegWDsel(D_RegWDsel), 
    .D_PCsel(D_PCsel),
	.Tuse_rs(Tuse_rs),
	.Tuse_rt(Tuse_rt),//从D级开始的Tuse值
	.Tnew(Tnew)//从E级开始的Tnew值
    );
	
	wire [31:0] D_rsValue1, D_rtValue1;
	
	Forward_EM Fwd_D (//把E、M的数据转发到D  D不需要考虑来自W的转发
    .E_RegWrite(E_RegWrite), 
    .E_RegA3(E_RegA3), 
    .E_RegWD(E_RegWD), 
	.M_RegWrite(M_RegWrite), 
    .M_RegA3(M_RegA3), 
    .M_RegWD(M_RegWD), 
    .D_rs(D_rs), 
    .D_rt(D_rt), 
    .D_rsValue0(D_rsValue0), 
    .D_rtValue0(D_rtValue0), 
    .D_rsValue1(D_rsValue1), //output
    .D_rtValue1(D_rtValue1)
    );
	
	wire [1:0] D_condition;
	
	CMP cmp (
    .A(D_rsValue1), 
    .B(D_rtValue1), 
    .CMPout(D_condition)//output
    );
/*  /// 暂停 ///  */
	wire stall, stall_rs, stall_rsE, stall_rsM, stall_rt, stall_rtE, stall_rtM;
	
	assign stall_rsE = (D_rs!=0)&&(D_rs==E_RegA3)&&(Tuse_rs<TnewE);
	assign stall_rsM = (D_rs!=0)&&(D_rs==M_RegA3)&&(Tuse_rs<TnewM);
	assign stall_rs = stall_rsE | stall_rsM;
	assign stall_rtE = (D_rt!=0)&&(D_rt==E_RegA3)&&(Tuse_rt<TnewE);
	assign stall_rtM = (D_rt!=0)&&(D_rt==M_RegA3)&&(Tuse_rt<TnewM);
	assign stall_rt = stall_rtE | stall_rtM;
	assign stall = stall_rs | stall_rt;
	
/*///////// !*stage E*! //////////////////////////////////*/	 														
	wire [31:0] E_PC,E_rsValue0,E_rtValue0,E_extImm;
	wire [3:0] E_RegWDsel,E_ALUsrc;
	wire [4:0] E_rs, E_rt, E_RegA3, E_ALUop;
	wire E_MemWrite, E_RegWrite;
	wire [2:0] TnewE;
	
	E RegE (
    .clk(clk), 
	.reset(reset),
	.stall(stall),
	.D_PC_i(D_PC),
	.D_rs_i(D_rs),
	.D_rt_i(D_rt),
    .D_rsValue_i(D_rsValue1), //接收的是Value0 或 1都可以
    .D_rtValue_i(D_rtValue1), 
    .D_extImm_i(D_extImm), 
    .D_ALUop_i(D_ALUop), 
	.D_ALUsrc_i(D_ALUsrc),
    .D_MemWrite_i(D_MemWrite), 
	.D_RegWrite_i(D_RegWrite),
	.D_RegA3_i(D_RegA3), 
    .D_RegWDsel_i(D_RegWDsel), 
	.Tnew_i(Tnew),
	.E_PC_o(E_PC),//output
	.E_rs_o(E_rs),
	.E_rt_o(E_rt),
    .E_rsValue_o(E_rsValue0), 
    .E_rtValue_o(E_rtValue0), 
    .E_extImm_o(E_extImm), 
    .E_ALUop_o(E_ALUop), 
	.E_ALUsrc_o(E_ALUsrc),
    .E_MemWrite_o(E_MemWrite), 
	.E_RegWrite_o(E_RegWrite),
	.E_RegA3_o(E_RegA3), 
    .E_RegWDsel_o(E_RegWDsel),
	.TnewE_o(TnewE)
    );
	// assign E_clear = 新指令
	wire [31:0] E_rsValue1, E_rtValue1;
	
	Forward_MW Fwd_E (//把M、W的数据转发到E
    .M_RegWrite(M_RegWrite), 
    .M_RegA3(M_RegA3), 
    .M_RegWD(M_RegWD), 
    .W_RegWrite(W_RegWrite), 
    .W_RegA3(W_RegA3), 
    .W_RegWD(W_RegWD), 
    .E_rs(E_rs), 
    .E_rt(E_rt), 
    .E_rsValue0(E_rsValue0), 
    .E_rtValue0(E_rtValue0), 
    .E_rsValue1(E_rsValue1), //output
    .E_rtValue1(E_rtValue1)
    );
	
	wire [31:0] E_ALUout, srcA, srcB;
	assign srcA = E_rsValue1;
	assign srcB = (E_ALUsrc==1) ? E_extImm : E_rtValue1;
	
	ALU EXalu (
    .ALUop(E_ALUop), 
    .srcA(srcA), 
    .srcB(srcB), 
    .ALUout(E_ALUout)
    );
/*  /// E 级可转发的数据： ///  */
	wire [31:0] E_RegWD;//lui 和 jal在D级已确定RegWD，在E就可转发
	assign E_RegWD = (E_RegWDsel==`PCplus8) ? (E_PC+8)   : 
					 (E_ALUop==`lui)        ? (E_ALUout) : 32'dx;
	
/*///////// !*stage M*! //////////////////////////////////*/	
	wire [31:0] M_ALUout, M_PC,M_rtValue0;
	wire M_MemWrite,M_RegWrite;
	wire [3:0] M_RegWDsel;
	wire [4:0] M_rt, M_RegA3;
	wire [2:0] TnewM;

	M RegM (
    .clk(clk), 
    .reset(reset), 
	.E_PC_i(E_PC),
    .E_ALUout_i(E_ALUout), 
    .E_MemWrite_i(E_MemWrite), 
	.E_rt_i(E_rt),
	.E_rtValue_i(E_rtValue1),
	.E_RegWrite_i(E_RegWrite),
	.E_RegA3_i(E_RegA3),
    .E_RegWDsel_i(E_RegWDsel),
	.TnewE_i(TnewE),
	.M_PC_o(M_PC),//output
    .M_ALUout_o(M_ALUout), 
    .M_MemWrite_o(M_MemWrite),
	.M_rt_o(M_rt),
	.M_rtValue_o(M_rtValue0),
	.M_RegWrite_o(M_RegWrite),
	.M_RegA3_o(M_RegA3),
    .M_RegWDsel_o(M_RegWDsel),
	.TnewM_o(TnewM)
    );
	
	wire [31:0] M_rtValue1;
	
	Forward_W Fwd_M (//把W的数据转发到M
    .W_RegWrite(W_RegWrite), 
    .W_RegA3(W_RegA3), 
    .W_RegWD(W_RegWD), 
    .M_rt(M_rt), 
    .M_rtValue0(M_rtValue0), 
    .M_rtValue1(M_rtValue1)//output
    );
	
	wire [31:0] M_MemRead;
	
	DM MEM_DM (
    .clk(clk), 
    .reset(reset), 
    .PC(M_PC), 
    .MemWrite(M_MemWrite), 
    .A(M_ALUout), 
    .D(M_rtValue1), 
    .MemRead(M_MemRead)//output
    );
	
/*  /// M 级可转发的数据： ///  */
	wire [31:0] M_RegWD;
	assign M_RegWD = (M_RegWDsel==`PCplus8) ? (M_PC+8) : 
					 (M_RegWDsel==`ALUout)  ? (M_ALUout) : 32'dx;
	
/*///////// !*stage W*! //////////////////////////////////*/
	wire [31:0] W_PC,W_MemRead,W_ALUout;
	wire [3:0] W_RegWDsel;
	wire [4:0] W_RegA3;
	wire W_RegWrite;
	
	W RegW (
    .clk(clk), 
    .reset(reset), 
	.M_PC_i(M_PC),
    .M_MemRead_i(M_MemRead), 
    .M_ALUout_i(M_ALUout), 
	.M_RegWrite_i(M_RegWrite),
	.M_RegA3_i(M_RegA3),
    .M_RegWDsel_i(M_RegWDsel), 
	.W_PC_o(W_PC),//output
    .W_MemRead_o(W_MemRead), 
    .W_ALUout_o(W_ALUout), 
	.W_RegWrite_o(W_RegWrite),
	.W_RegA3_o(W_RegA3),
    .W_RegWDsel_o(W_RegWDsel)
    );
	
/*  ///  W 级可转发的数据： ///  */	
	wire [31:0] W_RegWD;
	MUX16 #(32) WB_RegWD_W (
	.select(W_RegWDsel),
	.in0(W_ALUout),
	.in1(W_MemRead),
	.in2(W_PC+8),
	.out(W_RegWD)//output
	);
	
endmodule
