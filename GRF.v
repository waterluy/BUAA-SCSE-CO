`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:25:15 11/11/2021 
// Design Name: 
// Module Name:    GRF 
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
module GRF(
    input clk,
    input reset,
    input RegWrite,
    input [4:0] A1,	//rs
    input [4:0] A2,   //rt
    input [4:0] A3,
    input [31:0] WD,  
	input [31:0] PC,
    output [31:0] RD1,	//rs
    output [31:0] RD2	//rt
    );
	
	reg [31:0] grf[31:0];
	integer i;
	
	assign RD1 = ( A1==0 ) ? 0 : grf[A1];	//×¢Òâ0ºÅ¼Ä´æÆ÷ÓÀÔ¶Îª0
	assign RD2 = ( A2==0 ) ? 0 : grf[A2];
	
	always @( posedge clk )
	begin
		if( reset )
		begin
			for( i=0; i<=31; i=i+1 )
				grf[i] <= 0;
		end
		else if( RegWrite )
		begin
			if( A3!=0 )
			begin
				grf[A3] <= WD;
				$display("@%08h: $%d <= %08h", PC, A3, WD);
			end
		end
		else
			grf[0] <= 32'd0;
	end

endmodule
