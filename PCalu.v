`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:42:00 11/11/2021 
// Design Name: 
// Module Name:    PCalu 
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

//PC都按4的整数倍算 				切记！切记！切记！
module PCalu(
    input clk,
    input reset,
    input [3:0] PC_sel,//选择下一条PC的计算方法
	input [31:0] condition,//比较条件
    input [15:0] immediate,
    input [25:0] address,
	input [31:0] rs,
    output [31:0] PC
    );
	
	reg [31:0] NPC;
	wire [31:0] sign_ext,temp;
	assign PC = NPC;
	
	assign sign_ext = {{16{immediate[15]}},immediate};
	assign temp = sign_ext<<2;
	   
	always @( posedge clk )
	begin  
		if( reset )
			NPC <= 32'h0000_3000;
		else
		begin
			case( PC_sel )
				4'b0000: NPC <= NPC + 4;
				4'b0001: 	//beq
				begin
					if( condition )// + 比 移位 的优先级高 切记 ！ 切记 ！
						NPC <= NPC + 4 + (sign_ext<<2);//记得乘4 	// beq
					else
						NPC <= NPC + 4;
				end
				4'b0010: NPC <= {NPC[31:28],address,2'b00};// jal 
				4'b0011: NPC <= rs;// jr不一定跳到$ra hr $rs
				default: NPC <= 32'dx;
			endcase
		end
	end

endmodule
