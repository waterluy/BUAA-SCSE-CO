`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:13:10 12/06/2021 
// Design Name: 
// Module Name:    mult_div 
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

`define mult 24
`define multu 25
`define div 26
`define divu 27
`define mthi 28
`define mtlo 29

`define s0 0
`define s1 1
`define s2 2
`define s3 3
`define s4 4

module mult_div(
	input wire clk,
	input wire reset,
    input wire [7:0] ALUop,
    input wire [31:0] regA,//rs
    input wire [31:0] regB,//rt
    output reg [31:0] HI,
    output reg [31:0] LO,
	output wire start,
	output reg [7:0]  busy //busy表示还需要忙几个周期
    );
	
	reg [63:0] mult;
	reg [31:0] hi, lo;
	
	always @(*)
	begin
		case(ALUop)
			`mult:
			begin
				mult = $signed(regA) * $signed(regB);
				lo = mult[31:0];
				hi = mult[63:32];
			end
			`multu:
			begin
				mult = regA * regB;
				lo = mult[31:0];
				hi = mult[63:32];
			end
			`div:
			begin
				lo = $signed(regA) / $signed(regB);//商
				hi = $signed(regA) % $signed(regB);//余数
			end
			`divu:
			begin
				lo = regA / regB;//商
				hi = regA % regB;//余数
			end
			`mtlo:
				lo = regA; //rs
			`mthi:
				hi = regA; //rs
			default:
			begin
				lo = lo;
				hi = hi;
			end
		endcase
	end
	
// 乘除部件 内置HI LO  ////////////////////////////////////////////////////////////
	
	reg [7:0] status;
	//wire start; 
	assign start = ((ALUop==`mult) | (ALUop==`multu) | (ALUop==`div) | (ALUop==`divu)) ? 1 : 0;
	always @(posedge clk)
	begin
		if(reset)
		begin
			LO <= 32'd0;
			HI <= 32'd0;
			busy <= 0;
			status <= `s0;
		end
		else 
		begin
			case(status)
				`s0:
				begin
					if( (ALUop==`mult) | (ALUop==`multu) )
					begin
						busy <= 5;
						status <= `s1;
					end
					else if( (ALUop==`div) | (ALUop==`divu) )
					begin
						busy <= 10;
						status <= `s2;
					end	
					else if( ALUop==`mtlo )
					begin
						LO <= lo;
						busy <= 0;
						status <= `s0;
					end
					else if( ALUop==`mthi )
					begin
						HI <= hi;
						busy <= 0;
						status <= `s0;
					end
					else
					begin
						busy <= 0;
						status <= `s0;
					end
				end
				`s1:// mult、multu
				begin
					if( busy>1 )
					begin
						busy <= busy - 1;
						status <= `s1;
					end
					else
					begin
						busy <= 0;
						status <= `s0;
						LO <= lo;
						HI <= hi;
					end
				end	
				`s2:
				begin
					if( busy>1 )
					begin
						busy <= busy - 1;
						status <= `s2;
					end
					else
					begin
						busy <= 0;
						status <= `s0;
						LO <= lo;
						HI <= hi;
					end
				end
				default:	status <= `s0;
			endcase
		end
	end

endmodule
