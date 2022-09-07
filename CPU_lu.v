`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:26:23 12/18/2021 
// Design Name: 
// Module Name:    CPU_lu 
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

`default_nettype none

//RegWDsel
`define ALUout 0
`define MemtoReg 1
`define PCplus8 2
`define HI 3
`define LO 4
//PCsel
`define normal 0
`define b_beq 1
`define b_bne 2
`define b_bgez 3
`define b_bgtz 4
`define b_blez 5
`define b_bltz 6
`define jump 7
`define jreg 8
//ALUop
`define lui 23
`define mtc0 39
`define eret 40
`define delay 42
`define illegal 44
//excCode
`define noneExc 31
`define Int 0
`define Adel 4
`define Ades 5
`define RI 10
`define Ov 12

module CPU_lu(
    input wire clk,
    input wire reset,
	input wire [5:0] HWInt,
	output wire [31:0] macroscopic_pc,    // 宏观 PC

    output wire [31:0] i_inst_addr,       // 取指 PC
    input  wire [31:0] i_inst_rdata,      // i_inst_addr 对应的 32 位指令

	input  wire [31:0] CPU_data,          // m_data_addr 对应的 32 位数据
    output wire [31:0] bridge_addr,       // 数据存储器待写入地址
    output wire [31:0] bridge_wdata,      // 数据存储器待写入数据
    output wire [3 :0] bridge_byteen,     // 字节使能信号

    output wire [31:0] m_inst_addr,       // M 级PC

    output wire w_grf_we,                 // grf 写使能信号
    output wire [4 :0] w_grf_addr,        // grf 待写入寄存器编号
    output wire [31:0] w_grf_wdata,       // grf 待写入数据

    output wire [31:0] w_inst_addr        // W 级 PC
    );
/*///////// !*stage F*! //////////////////////////////////*/
	wire [31:0] F_PC,F_Instr,F_NPC;
	
	PCreg RegPC (
    .clk(clk), 
    .reset(reset), 
	.stall(stall),
	.IntReq(IntReq),
    .F_NPC_i(F_NPC), 
    .F_PC_o(F_PC)//output
    );
	
	assign i_inst_addr = F_PC;
	assign F_Instr = i_inst_rdata;
////////  4_Adel ...  Addr exception load ..................................
	wire [4:0] F_excCode;
	assign F_excCode = ( (F_PC[1:0]!=0)||(F_PC<32'h3000)||(F_PC>32'h6ffc) ) ? `Adel : `noneExc;//&&(!IntReq)
	wire F_bd;
	assign F_bd = (D_ALUop==`delay);//F_bd = ( (D_ALUop==`delay)&&(F_excCode!=none) ); ×
////////  4_Adel ...  Addr exception load ..................................
	PC_NPC NPC (
    .clk(clk), 
    .reset(reset), 
	.F_PC(F_PC),
    .D_PCsel(D_PCsel), 
	.D_PC(D_PC),
	.D_cmpReg(D_cmpReg),
	.D_cmpZero(D_cmpZero),
	.D_imm(D_imm),
	.D_index(D_index),
	.D_rsValue(D_rsValue1),
	.EPC(EPC),
	.M_ALUop(M_ALUop),
    .F_NPC(F_NPC)//output
    );
	
/*///////// !*stage D*! //////////////////////////////////*/							
	wire [31:0] D_PC, D_Instr;               
	wire [4:0] D_excCode0;	
	wire D_bd;
	
	D RegD (                          
    .clk(clk),                              
    .reset(reset), 	
	.stall(stall),
	.IntReq(IntReq),
	.clr_delay(clr_delay),
	.EPC(EPC),
	.F_PC_i(F_PC),							
    .F_Instr_i(F_Instr),
	.F_excCode_i(F_excCode),	
	.F_bd_i(F_bd),
	.D_PC_o(D_PC),//output
	.D_Instr_o(D_Instr),
	.D_excCode_o(D_excCode0),
	.D_bd_o(D_bd)
    );	
	
	wire D_RegWrite,D_ext,D_MemWrite, md, mt, mf;						
	wire [3:0] D_RegWDsel, D_RegA3sel, D_PCsel;	
	wire [7:0] D_ALUop;
	wire [4:0] D_rs, D_rt, D_rd, D_shamt, D_RegA3;
	wire [15:0] D_imm;	
	wire [25:0] D_index;
	wire [31:0] D_rsValue0, D_rtValue0;
	wire [2:0] Tuse_rs, Tuse_rt, Tnew;
	
	ID ID_CU_GRF (
    .clk(clk), 
    .reset(reset), 
    .W_PC(W_PC), 
    .D_Instr(D_Instr), 
    .W_RegWrite(W_RegWrite), 
    .W_RegA3(W_RegA3), 
    .W_RegWD(W_RegWD), 
	.D_rs(D_rs),
	.D_rt(D_rt),
	.D_rd(D_rd),
    .D_rsValue(D_rsValue0), //output
    .D_rtValue(D_rtValue0), 
	.D_imm(D_imm),
	.D_shamt(D_shamt),
	.D_index(D_index),
    .D_ALUop(D_ALUop), 
    .D_MemWrite(D_MemWrite), 
    .D_RegWrite(D_RegWrite), 
    .D_RegA3(D_RegA3), 
    .D_RegWDsel(D_RegWDsel), 
    .D_PCsel(D_PCsel),
	.Tuse_rs(Tuse_rs),
	.Tuse_rt(Tuse_rt),//从D级开始的Tuse值
	.Tnew(Tnew),      //从E级开始的Tnew值
	.md(md),
	.mt(mt),
	.mf(mf)
    );
	
	wire clr_delay;
	assign clr_delay = (D_ALUop==`eret);                              //必须在D级产生clr_delay信号，延迟槽可能是跳转
	
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
	
	wire [1:0] D_cmpReg, D_cmpZero;
	
	CMP cmp (
    .A(D_rsValue1), 
    .B(D_rtValue1), 
    .CMP_reg( D_cmpReg),//output
	.CMP_zero(D_cmpZero)
    );
/*  /// 暂停 ///  */
	wire stall, stall_rs, stall_rsE, stall_rsM, stall_rt, stall_rtE, stall_rtM;
	wire stall_eret;
	assign stall_eret = (D_ALUop==`eret)&&(((E_ALUop==`mtc0)&&(E_rd==14))||((M_ALUop==`mtc0)&&(M_rd==14)));
	wire stall_HL;
	assign stall_HL = (mf&&(D_RegA3!=0)&& (start|| (1<busy) ) ) ||
					  ((md||mt)&& (start|| (1<busy) ) ); 
	assign stall_rsE = (D_rs!=0)&&(D_rs==E_RegA3)&&(Tuse_rs<TnewE);
	assign stall_rsM = (D_rs!=0)&&(D_rs==M_RegA3)&&(Tuse_rs<TnewM);
	assign stall_rs = stall_rsE | stall_rsM;
	assign stall_rtE = (D_rt!=0)&&(D_rt==E_RegA3)&&(Tuse_rt<TnewE);
	assign stall_rtM = (D_rt!=0)&&(D_rt==M_RegA3)&&(Tuse_rt<TnewM);
	assign stall_rt = stall_rtE | stall_rtM;
	assign stall = stall_rs | stall_rt |stall_HL | stall_eret;
////////  10 RI ...  RI ..................................	
	wire [4:0] D_excCode1;
	wire D_RI;
	assign D_RI = (D_ALUop==`illegal);
	assign D_excCode1 = (D_excCode0!=`noneExc) ? D_excCode0 : 
						 D_RI                  ? `RI        : `noneExc;
/*///////// !*stage E*! //////////////////////////////////*/	 														
	wire [31:0] E_PC,E_rsValue0,E_rtValue0;
	wire [15:0] E_imm;
	wire [3:0] E_RegWDsel;
	wire [4:0] E_rs, E_rt, E_rd, E_shamt, E_RegA3;
	wire [7:0] E_ALUop;
	wire E_MemWrite, E_RegWrite;
	wire [2:0] TnewE;
	wire [4:0] E_excCode0;
	wire E_bd;
	
	E RegE (
    .clk(clk), 
	.reset(reset),
	.stall(stall),
	.IntReq(IntReq),
	//.clr_delay(clr_delay),
	//.EPC(EPC),
	.D_PC_i(D_PC),
	.D_rs_i(D_rs),
	.D_rt_i(D_rt),
	.D_rd_i(D_rd),
    .D_rsValue_i(D_rsValue1), //接收的是Value0 或 1都可以
    .D_rtValue_i(D_rtValue1), 
    .D_imm_i(D_imm), 
	.D_shamt_i(D_shamt),
    .D_ALUop_i(D_ALUop), 
    .D_MemWrite_i(D_MemWrite), 
	.D_RegWrite_i(D_RegWrite),
	.D_RegA3_i(D_RegA3), 
    .D_RegWDsel_i(D_RegWDsel), 
	.Tnew_i(Tnew),
	.D_excCode_i(D_excCode1),
	.D_bd_i(D_bd),
	.E_PC_o(E_PC),//output
	.E_rs_o(E_rs),
	.E_rt_o(E_rt),
	.E_rd_o(E_rd),
    .E_rsValue_o(E_rsValue0), 
    .E_rtValue_o(E_rtValue0), 
    .E_imm_o(E_imm), 
	.E_shamt_o(E_shamt),
    .E_ALUop_o(E_ALUop), 
    .E_MemWrite_o(E_MemWrite), 
	.E_RegWrite_o(E_RegWrite),
	.E_RegA3_o(E_RegA3), 
    .E_RegWDsel_o(E_RegWDsel),
	.TnewE_o(TnewE),
	.E_excCode_o(E_excCode0),
	.E_bd_o(E_bd)
    );
	
	/*wire clr_delay;
	assign clr_delay = (E_ALUop==`eret);*/
	
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
	
	wire [31:0] E_ALUout;
	wire E_Ov, E_Adel, E_Ades;
	ALU EXalu (
    .ALUop(E_ALUop), 
    .rs(E_rsValue1), 
    .rt(E_rtValue1),
	.imm(E_imm),
	.shamt(E_shamt),
    .ALUout(E_ALUout),
	.E_Ov(E_Ov),
	.E_Adel(E_Adel),
	.E_Ades(E_Ades)
    );
////////  12 Ov ...  overflow ..................................
	wire [4:0] E_excCode1;
	assign E_excCode1 = (E_excCode0!=`noneExc) ? E_excCode0 :
						E_Ov				   ? `Ov        :
						E_Adel                 ? `Adel      :
						E_Ades				   ? `Ades      : `noneExc;
////////  12 Ov ...  overflow ..................................	
	wire [31:0] E_HI, E_LO;
	wire [7:0] busy;
	wire start;
	
	mult_div mult_div (
    .clk(clk), 
    .reset(reset), 
	.IntReq(IntReq),//不需要clr_delay
    .ALUop(E_ALUop), 
    .regA(E_rsValue1), 
    .regB(E_rtValue1), 
    .HI(E_HI), 
    .LO(E_LO),
	.start(start),
	.busy(busy)
    );
	
/*  /// E 级可转发的数据： ///  */
	wire [31:0] E_RegWD;//lui 和 jal jalr在D级已确定RegWD，在E就可转发
	assign E_RegWD = (E_RegWDsel==`PCplus8) ? (E_PC+8)   : 
					 (E_ALUop==`lui)        ? (E_ALUout) : 32'h66666666;
	
/*///////// !*stage M*! //////////////////////////////////*/	
	wire [31:0] M_ALUout, M_PC,M_rtValue0;
	wire M_MemWrite,M_RegWrite;
	wire [3:0] M_RegWDsel;
	wire [4:0] M_rt, M_rd, M_RegA3;
	wire [2:0] TnewM;
	wire [7:0]  M_ALUop;
	wire [31:0] M_HI, M_LO;
	wire [4:0] M_excCode0;
	wire M_bd;

	M RegM (
    .clk(clk), 
    .reset(reset), 
	.IntReq(IntReq),
	//.clr_delay(clr_delay),
	//.EPC(EPC),
	.E_PC_i(E_PC),
    .E_ALUout_i(E_ALUout), 
	.E_HI_i(E_HI),
	.E_LO_i(E_LO),
	.E_ALUop_i(E_ALUop),
    .E_MemWrite_i(E_MemWrite), 
	.E_rt_i(E_rt),
	.E_rd_i(E_rd),
	.E_rtValue_i(E_rtValue1),
	.E_RegWrite_i(E_RegWrite),
	.E_RegA3_i(E_RegA3),
    .E_RegWDsel_i(E_RegWDsel),
	.TnewE_i(TnewE),
	.E_excCode_i(E_excCode1),
	.E_bd_i(E_bd),
	.M_PC_o(M_PC),//output
    .M_ALUout_o(M_ALUout), 
	.M_HI_o(M_HI),
	.M_LO_o(M_LO),
	.M_ALUop_o(M_ALUop),
    .M_MemWrite_o(M_MemWrite),
	.M_rt_o(M_rt),
	.M_rd_o(M_rd),
	.M_rtValue_o(M_rtValue0),
	.M_RegWrite_o(M_RegWrite),
	.M_RegA3_o(M_RegA3),
    .M_RegWDsel_o(M_RegWDsel),
	.TnewM_o(TnewM),
	.M_excCode_o(M_excCode0),
	.M_bd_o(M_bd)
    );
	
	/*wire clr_delay;
	assign clr_delay = (M_ALUop==`eret);*/
	
	wire [31:0] M_rtValue1;
	
	Forward_W Fwd_M (//把W的数据转发到M
    .W_RegWrite(W_RegWrite), 
    .W_RegA3(W_RegA3), 
    .W_RegWD(W_RegWD), 
    .M_rt(M_rt), 
    .M_rtValue0(M_rtValue0), 
    .M_rtValue1(M_rtValue1)//output
    );
	
	assign bridge_addr = M_ALUout;
	assign m_inst_addr = M_PC;
	assign macroscopic_pc = M_PC;

	wire [31:0] M_MemRead;
	wire M_Adel, M_Ades;
	wire [3:0] byteen;
	
	Data Data (
    .A(bridge_addr), 
    .Din(CPU_data),
	.ALUop(M_ALUop),
	.Win(M_rtValue1),
	.Dout(M_MemRead),//output
	.byteen(byteen),
	.bridge_wdata(bridge_wdata),
	.M_Adel(M_Adel),
	.M_Ades(M_Ades)
    );
	assign bridge_byteen = IntReq ? 4'b0000 : byteen;
/*  /// M 级可转发的数据： ///  */
	wire [31:0] M_RegWD;
	assign M_RegWD = (M_RegWDsel==`PCplus8) ? (M_PC+8)   : 
					 (M_RegWDsel==`ALUout)  ? (M_ALUout) : 
					 (M_RegWDsel==`HI)      ? (M_HI)     :
					 (M_RegWDsel==`LO)      ? (M_LO)     : 32'h66666666;
////////  4_Adel 5_Ades...  Addr exception load/store ..................................
	wire [4:0] M_excCode1;
	assign M_excCode1 = (M_excCode0!=`noneExc) ? M_excCode0 :
						 M_Adel                ? `Adel      :
						 M_Ades                ? `Ades      : `noneExc;
////////  4_Adel 5_Ades...  Addr exception load/store ..................................	
	wire CP0_WE, IntReq, EXLClr;
	assign EXLClr = (M_ALUop==`eret);
	assign CP0_WE = (M_ALUop==`mtc0);
	wire [31:0] M_CP0out, EPC;
	
	CP0 CP0 (
    .clk(clk), 
    .reset(reset), 
    .WE(CP0_WE), 
    .EXLClr(EXLClr), 
    .Aread(M_rd), 
    .Awrite(M_rd), 
    .Din(M_rtValue1), 
    .M_PC(M_PC), 
	.M_bd(M_bd),
    .M_ExcCode(M_excCode1), 
    .HWInt(HWInt), 
    .IntReq(IntReq), //output
    .EPC(EPC), 
    .Dout(M_CP0out)
    );									

/*///////// !*stage W*! //////////////////////////////////*///////////////
	wire [31:0] W_PC, W_MemRead, W_ALUout, W_CP0out;
	wire [3:0] W_RegWDsel;
	wire [4:0] W_RegA3;
	wire W_RegWrite;
	wire [31:0] W_HI, W_LO;
	wire [7:0]  W_ALUop;
	
	W RegW (
    .clk(clk), 
    .reset(reset), 
	.IntReq(IntReq),
	.M_PC_i(M_PC),
	.M_ALUop_i(M_ALUop),
    .M_MemRead_i(M_MemRead), 
    .M_ALUout_i(M_ALUout), 
	.M_HI_i(M_HI),
	.M_LO_i(M_LO),
	.M_CP0out_i(M_CP0out),
	.M_RegWrite_i(M_RegWrite),
	.M_RegA3_i(M_RegA3),
    .M_RegWDsel_i(M_RegWDsel), 
	.W_PC_o(W_PC),//output
	.W_ALUop_o(W_ALUop),
    .W_MemRead_o(W_MemRead), 
    .W_ALUout_o(W_ALUout), 
	.W_HI_o(W_HI),
	.W_LO_o(W_LO),
	.W_CP0out_o(W_CP0out),
	.W_RegWrite_o(W_RegWrite),
	.W_RegA3_o(W_RegA3),
    .W_RegWDsel_o(W_RegWDsel)
    );
	
/*  ///  W 级可以转发的数据： ///  */	
	wire [31:0] W_RegWD;
	MUX16 #(32) WB_RegWD_W (
	.select(W_RegWDsel),
	.in0(W_ALUout),
	.in1(W_MemRead),
	.in2(W_PC+8),
	.in3(W_HI),
	.in4(W_LO),
	.in5(W_CP0out),
	.out(W_RegWD)//output
	);
	
	assign w_grf_we = W_RegWrite;
	assign w_grf_addr = W_RegA3;
	assign w_grf_wdata = W_RegWD;
	assign w_inst_addr = W_PC;

endmodule
