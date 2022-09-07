`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:51:41 11/21/2021 
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

//RegWDsel
`define ALUout 0
`define MemtoReg 1
`define PCplus8 2

//RegA3sel
`define rd 0
`define rt 1
`define ra 2

//PCsel
`define normal 0
`define b_beq 1
`define jump 2
`define jreg 3

//ALUop  ori,lw,sw,beq,lui,j,jal,jr;
`define addu 0
`define subu 1
`define ori 2
`define lw 3
`define sw 4
`define lui 5

module Controller(
    input wire [31:0] Instr,
	output wire [4:0] rs,
	output wire [4:0] rt,
	output wire [4:0] rd,
	output wire [15:0] immediate,
	output wire [25:0] index,
	output reg RegWrite,
	output reg [3:0] RegWDsel,
	output reg [3:0] RegA3sel,
	output reg [3:0] PCsel,
	output reg [4:0] ALUop,
	output reg [3:0] ALUsrc,
	output reg ext,
	output reg MemWrite,
	output reg [2:0] Tuse_rs,
	output reg [2:0] Tuse_rt,
	output reg [2:0] Tnew//从E级开始的Tnew
    );
	
	wire [5:0] op,funct;
	wire [4:0] shamt;
	
	assign op = Instr[31:26];
	assign rs = Instr[25:21];
	assign rt = Instr[20:16];
	assign rd = Instr[15:11];
	assign shamt = Instr[10:6];
	assign funct = Instr[5:0];
	assign immediate = Instr[15:0];
	assign index = Instr[25:0];

	wire addu,subu,ori,lw,sw,beq,lui,j,jal,jr;
	
	assign addu = ( (op==0) & (funct==6'b100001) );
	assign subu = ( (op==0) & (funct==6'b100011) );
	assign ori = ( op==6'b001101 );
	assign lw = ( op==6'b100011 );
	assign sw = ( op==6'b101011 );
	assign beq = ( op==6'b000100 ); 
	assign lui = ( op==6'b001111 );
	assign j = ( op==6'b000010 );
	assign jal = ( op==6'b000011 );
	assign jr = ( (op==0) & (funct==6'b001000) );
	
	always @(*)//组合逻辑用阻塞赋值=
	begin
		if(addu)
		begin
			RegWrite = 1;
			RegWDsel = `ALUout;// ALUout
			RegA3sel = `rd;
			PCsel 	 = `normal;
			ALUop	 = `addu;
			ALUsrc   = 0; //srcB = rt
			ext		 = 0;
			MemWrite = 0;
			Tuse_rs  = 1;
			Tuse_rt  = 1;
			Tnew     = 1;
		end
		else if(subu)
		begin
			RegWrite = 1;
			RegWDsel = `ALUout;// ALUout
			RegA3sel = `rd;
			PCsel 	 = `normal;
			ALUop	 = `subu;
			ALUsrc   = 0; //srcB = rt
			ext		 = 0;
			MemWrite = 0;
			Tuse_rs  = 1;
			Tuse_rt  = 1;
			Tnew     = 1;
		end
		else if(ori)
		begin
			RegWrite = 1;
			RegWDsel = `ALUout;// ALUout
			RegA3sel = `rt;
			PCsel 	 = `normal;
			ALUop	 = `ori;
			ALUsrc   = 1; //srcB = imm
			ext		 = 0;
			MemWrite = 0;
			Tuse_rs  = 1;
			Tuse_rt  = 5;//不用rt
			Tnew     = 1;
		end
		else if(lw)
		begin
			RegWrite = 1;
			RegWDsel = `MemtoReg;// ALUout
			RegA3sel = `rt;
			PCsel 	 = `normal;
			ALUop	 = `lw;
			ALUsrc   = 1; //srcB = imm
			ext		 = 1;
			MemWrite = 0;
			Tuse_rs  = 1;
			Tuse_rt  = 5;//不用rt
			Tnew     = 2;
		end
		else if(sw)
		begin
			RegWrite = 0;
			RegWDsel = 0;
			RegA3sel = 0;
			PCsel 	 = `normal;
			ALUop	 = `sw;
			ALUsrc   = 1; //srcB = imm
			ext		 = 1;
			MemWrite = 1;
			Tuse_rs  = 1;
			Tuse_rt  = 2;
			Tnew     = 0;/// 0
		end
		else if(beq)
		begin
			RegWrite = 0;
			RegWDsel = 0;
			RegA3sel = 0;
			PCsel 	 = `b_beq;
			ALUop	 = 5'b11111;
			ALUsrc   = 0; //srcB = rt
			ext		 = 1;//beq要符号扩展/////////////////////////
			MemWrite = 0;
			Tuse_rs  = 0;
			Tuse_rt  = 0;
			Tnew     = 0;
		end
		else if(lui)
		begin
			RegWrite = 1;
			RegWDsel = `ALUout;// ALUout
			RegA3sel = `rt;
			PCsel 	 = `normal;
			ALUop	 = `lui;
			ALUsrc   = 1; //srcB = imm
			ext		 = 0;
			MemWrite = 0;
			Tuse_rs  = 5;
			Tuse_rt  = 5;
			Tnew     = 0;
		end
		else if(j)
		begin
			RegWrite = 0;
			RegWDsel = 0;// ALUout
			RegA3sel = 0;
			PCsel 	 = `jump;
			ALUop	 = 5'b11111;
			ALUsrc   = 0; //srcB = rt
			ext		 = 0;
			MemWrite = 0;
			Tuse_rs  = 5;
			Tuse_rt  = 5;
			Tnew     = 0;
		end
		else if(jal)
		begin
			RegWrite = 1;
			RegWDsel = `PCplus8;// ALUout
			RegA3sel = `ra;
			PCsel 	 = `jump;
			ALUop	 = 5'b11111;
			ALUsrc   = 0; // srcB = rt
			ext		 = 0;
			MemWrite = 0;
			Tuse_rs  = 5;
			Tuse_rt  = 5;
			Tnew     = 0;
		end
		else if(jr)
		begin
			RegWrite = 0;
			RegWDsel = 0;// ALUout
			RegA3sel = 0;
			PCsel 	 = `jreg;
			ALUop	 = 5'b11111;
			ALUsrc   = 0;
			ext		 = 0;
			MemWrite = 0;
			Tuse_rs  = 0;
			Tuse_rt  = 5;
			Tnew     = 0;
		end
		else//必须有最后 的else
		begin
			RegWrite = 0;	
			MemWrite = 0;
			PCsel 	 = `normal;
			Tuse_rs  = 5;
			Tuse_rt  = 5;
			Tnew     = 0;
		end
	end

endmodule
