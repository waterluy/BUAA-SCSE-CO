`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:36:35 11/20/2021 
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
	input wire clk,
	input wire reset,
	input wire [31:0] PC,
    input wire [4:0] A1,
    input wire [4:0] A2,
    input wire [4:0] A3,
    input wire [31:0] WD,
    input wire RegWrite,
    output wire [31:0] RD1,
    output wire [31:0] RD2
    );
	
	reg [31:0] grf[0:31];
	// GRF内部转发 必须有
	assign RD1 = (RegWrite&(A1!=0)&(A1==A3)) ? WD : grf[A1];
	assign RD2 = (RegWrite&(A2!=0)&(A2==A3)) ? WD : grf[A2];
	
	integer i;
	
	always @( posedge clk )
	begin
		if(reset)
		begin
			for( i=0; (i<32); i=i+1 )
				grf[i] <= 32'd0;
		end
		else if(RegWrite)
		begin
			if( A3!=0 )
			begin
				grf[A3] <= WD;
				//$display("%d@%08h: $%d <= %08h", $time, PC, A3, WD);
			end
			else
			begin
				grf[0] <= 32'd0;
			end
		end
		else
		begin
			grf[0] <= 32'd0;
		end
	end
endmodule
