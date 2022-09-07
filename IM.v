`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:34:28 11/20/2021 
// Design Name: 
// Module Name:    IM 
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
module IM(
    input wire [31:0] PC,
    output wire [31:0] Instr
    );
	 
	wire [31:0] im_addr;
	reg [31:0] im[0:32'hffff];
	
	initial	$readmemh("code.txt",im);
	
	assign im_addr = ((PC - 32'h0000_3000)>>2); 
	assign Instr = im[im_addr];

endmodule
