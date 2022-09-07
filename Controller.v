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
`define HI 3
`define LO 4
`define CP0 5

//RegA3sel
`define rd 0
`define rt 1
`define ra 2
`define zero 3

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
`define jeret 9

//ALUop  ori,lw,sw,beq,lui,j,jal,jr;
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


module Controller(
    input wire [31:0] Instr,
	output wire [4:0] rs,
	output wire [4:0] rt,
	output wire [4:0] rd,
	output wire [15:0] immediate,
	output wire [4:0] shamt,
	output wire [25:0] index,
	output wire RegWrite,
	output wire [3:0] RegWDsel,
	output wire [3:0] RegA3sel,
	output wire [3:0] PCsel,
	output wire [7:0] ALUop,
	output wire MemWrite,
	output wire [2:0] Tuse_rs,
	output wire [2:0] Tuse_rt,
	output wire [2:0] Tnew,    //从E级开始的Tnew
	output wire md,
	output wire mt,
	output wire mf
    );
	
	wire [5:0] op,funct;
	
	assign op = Instr[31:26];
	assign rs = Instr[25:21];
	assign rt = Instr[20:16];
	assign rd = Instr[15:11];
	assign shamt = Instr[10:6];
	assign funct = Instr[5:0];
	assign immediate = Instr[15:0];
	assign index = Instr[25:0];
//////////////////////////////////////////////////
	wire addu,subu,add,sub,sllv,srlv,srav,and0,or0,nor0,xor0,slt,sltu;
	assign addu = ( (op==0) & (funct==6'b100001) );
	assign subu = ( (op==0) & (funct==6'b100011) );
	assign add  = ( (op==0) & (funct==6'b100000) );
	assign sub  = ( (op==0) & (funct==6'b100010) );
	assign sllv = ( (op==0) & (funct==6'b000100) );
	assign srlv = ( (op==0) & (funct==6'b000110) );
	assign srav = ( (op==0) & (funct==6'b000111) );
	assign and0 = ( (op==0) & (funct==6'b100100) );
	assign or0  = ( (op==0) & (funct==6'b100101) );
	assign nor0 = ( (op==0) & (funct==6'b100111) );
	assign xor0 = ( (op==0) & (funct==6'b100110) );
	assign slt  = ( (op==0) & (funct==6'b101010) );
	assign sltu = ( (op==0) & (funct==6'b101011) );
	
	wire calcR;// 双寄存器
	assign calcR = addu | subu | add | sub | sllv | srlv | srav
					| and0 | or0 | nor0 | xor0 | slt | sltu;
/////////////////////////////////////////////////					
	wire addi,addiu,slti,sltiu,andi,ori,xori;
	assign addi = ( op==6'b001000 );
	assign addiu= ( op==6'b001001 );
	assign slti = ( op==6'b001010 );
	assign sltiu= ( op==6'b001011 );
	assign andi = ( op==6'b001100 );
	assign ori  = ( op==6'b001101 );
	assign xori = ( op==6'b001110 );
	
	wire calcI;// 寄存器和imm计算
	assign calcI = addi | addiu | slti | sltiu | andi | ori | xori;
//////////////////////////////////////////////////	
	wire sll,srl,sra;
	assign sll = ( (op==0) & (funct==0) & (Instr!=0) );
	assign srl = ( (op==0) & (funct==6'b000010) );
	assign sra = ( (op==0) & (funct==6'b000011) );
	
	wire calcS;// 寄存器和shamt计算
	assign calcS = sll | srl | sra;
///////////////////////////////////////////////////	
	wire lui;// lui
	assign lui = ( op==6'b001111 );
///////////////////////////////////////////////////	
	wire sw,sh,sb;
	assign sw = ( op==6'b101011 );
	assign sh = ( op==6'b101001 );
	assign sb = ( op==6'b101000 );
	
	wire store;// store
	assign store = sw | sh | sb;
//////////////////////////////////////////////////
	wire lw,lh,lhu,lb,lbu;
	assign lw  = ( op==6'b100011 );
	assign lh  = ( op==6'b100001 );
	assign lhu = ( op==6'b100101 );
	assign lb  = ( op==6'b100000 );
	assign lbu = ( op==6'b100100 );
	
	wire load;// load
	assign load = lw | lh | lhu | lb | lbu;
////////////////////////////////////////////////
	wire mfhi,mflo,mult,multu,div,divu,mthi,mtlo;
	assign mfhi = ( (op==0) & (funct==6'b010000) );
	assign mflo = ( (op==0) & (funct==6'b010010) );
	assign mult = ( (op==0) & (funct==6'b011000) );
	assign multu= ( (op==0) & (funct==6'b011001) );
	assign div  = ( (op==0) & (funct==6'b011010) );
	assign divu = ( (op==0) & (funct==6'b011011) );
	assign mthi = ( (op==0) & (funct==6'b010001) );
	assign mtlo = ( (op==0) & (funct==6'b010011) );
	
	assign mf = mfhi | mflo;
	assign md = mult | multu | div | divu;
	assign mt = mthi | mtlo;
////////////////////////////////////////////////
	wire beq,bne,bgez,bgtz,blez,bltz;
	assign beq  = ( op==6'b000100 ); 
	assign bne  = ( op==6'b000101 );
	assign bgez = ( (op==6'b000001) & (rt==5'b00001) );//rt=00001
	assign bgtz = ( op==6'b000111 );//rt=00000
	assign blez = ( op==6'b000110 );//rt=00000
	assign bltz = ( (op==6'b000001) & (rt==5'b00000) );//rt=00000
	
	wire branch;/////b
	assign branch = beq | bne | bgez | bgtz | blez | bltz;
////////////////////////////////////////////////	
	wire j,jal,jr,jalr;
	assign j    = ( op==6'b000010 );
	assign jal  = ( op==6'b000011 );
	assign jr   = ( (op==0) & (funct==6'b001000) );
	assign jalr = ( (op==0) & (funct==6'b001001) );
////////////////////////////////////////////////////////
	wire mfc0, mtc0, eret;
	assign mfc0 = ( (op==6'b010000) & (rs==5'b00000) );
	assign mtc0 = ( (op==6'b010000) & (rs==5'b00100) );
	assign eret = ( (op==6'b010000) & (funct==6'b011000) );
////////////////////////////////////////////////////////
	assign RegWrite = calcR | calcI | calcS | lui | load | jal | jalr | mf | mfc0; 
	
	assign RegWDsel = (calcR | calcI | calcS | lui) ? `ALUout   :
					  load                          ? `MemtoReg :
					  (jal | jalr)                  ? `PCplus8  :
					  mfhi                          ? `HI       :
					  mflo                          ? `LO       :
					  mfc0                          ? `CP0      : 4'dx;
					  
	assign RegA3sel = (calcR | calcS | mf | jalr) ? `rd :
					  (calcI | lui | load | mfc0) ? `rt :
					  jal                         ? `ra : `zero;
					  
	assign MemWrite = store;	
	
	assign PCsel    = beq  ? `b_beq  :
					  bne  ? `b_bne  :
					  bgez ? `b_bgez :
					  bgtz ? `b_bgtz :
					  blez ? `b_blez :
					  bltz ? `b_bltz :
					  (j|jal)   ? `jump :
					  (jr|jalr) ? `jreg : 
					  eret      ? `jeret : `normal;//默认为normal
					  
	assign Tuse_rs = (calcR | calcI | load | store | md | mt) ? 1 : 
					 (branch | jr | jalr) ? 0 : 5;//默认为5
					 
	assign Tuse_rt = (calcR | calcS | md) ? 1 :
					 (store | mtc0) ? 2 :
					 (beq | bne) ? 0 : 5;//默认为5
					 
	assign Tnew = (calcR | calcI | calcS | mf) ? 1 :
				  (load | mfc0) ? 2 : 0 ;

	assign ALUop = addu ? `addu :
				   subu ? `subu :
				   add  ? `add  :
				   sub  ? `sub  :
				   sllv ? `sllv :
				   srlv ? `srlv :
				   srav ? `srav :
				   and0 ? `and0 :
				   or0  ? `or0  :
				   nor0 ? `nor0 :
				   xor0 ? `xor0 :
				   slt  ? `slt  :
				   sltu ? `sltu ://13 calcR
				   ori  ? `ori  :
				   andi ? `andi :
				   xori ? `xori :
				   slti ? `slti :
				   sltiu? `sltiu:
				   addi ? `addi :
				   addiu? `addiu://7 calcI
				   sll  ? `sll  :
				   srl  ? `srl  :
				   sra  ? `sra  ://3 calcS
				   lui  ? `lui  ://lui
				   mult ? `mult :
				   multu? `multu:
				   div  ? `div  :
				   divu ? `divu ://4 md
				   mtlo ? `mtlo :
				   mthi ? `mthi ://2 mt
				   lw   ? `lw   :
				   lh   ? `lh   : 
				   lhu  ? `lhu  :
				   lb   ? `lb   :
				   lbu  ? `lbu  ://5 load
				   sw   ? `sw   :
				   sh   ? `sh   :
				   sb   ? `sb   ://3 store 
				   mfc0 ? `mfc0 :
				   mtc0 ? `mtc0 :
				   eret ? `eret ://3
				   (mflo | mfhi) ? `mf ://2 mf
				   (branch | j | jr | jal | jalr) ? `delay :// 10
				   ((op==0)&&(funct==0)) ? `nop ://1
												   `illegal;
	   

endmodule
