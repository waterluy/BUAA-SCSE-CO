`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:46:25 11/11/2021 
// Design Name: 
// Module Name:    DM 
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
module DM(
    input clk,
    input reset,
    input MemWrite,
    input [31:0] MemAddr,
    input [31:0] MemData,
	input [31:0] PC,
    output [31:0] MemRead
    );
	
	reg [31:0] dm[0:32'hffff];///////////
	wire [31:0] dm_addr;
	integer i;
	
	assign dm_addr = (MemAddr >> 2);// MemAddrÓÒÒÆÁ½Î» ×ÖµØÖ·
	assign MemRead = dm[dm_addr];
	
	always @( posedge clk )
	begin
		if( reset )
		begin
			for( i=0; i<=1023; i=i+1 )
				dm[i] <= 0;
		end
		else if( MemWrite )
		begin
			dm[dm_addr] <= MemData;
			$display("@%08h: *%08h <= %08h",PC,MemAddr,MemData);
		end
		else
			;
	end

endmodule
