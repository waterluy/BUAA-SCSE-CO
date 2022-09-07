`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:28:21 11/20/2021 
// Design Name: 
// Module Name:    EXT 
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
module EXT(
    input wire ext,
	input wire [15:0] data,
	output reg [31:0] ext_data
    );
	
	always @(*)
	begin
		case(ext)
			0:	ext_data = {16'd0,data};	// 0 ¡„¿©’π
			1:	ext_data = {{16{data[15]}},data};	// 1 ∑˚∫≈¿©’π
			default:	ext_data = 32'dx;	
		endcase
	end

endmodule
