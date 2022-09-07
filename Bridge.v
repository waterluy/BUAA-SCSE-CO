`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:41:45 12/18/2021 
// Design Name: 
// Module Name:    Bridge 
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
module Bridge(
	input wire [31:0] bridge_wdata,
	input wire [31:0] bridge_addr,
	input wire [3:0]  bridge_byteen,
	input wire [31:0] DM_data,
	input wire [31:0] Timer0_data,
	input wire [31:0] Timer1_data,
	output wire [31:0] CPU_data, //¸øCPUµÄdata
	output wire [3:0] m_data_byteen,
	output wire Timer0_WE,
	output wire Timer1_WE,
	output wire [31:0] Addr,
	output wire [31:0] Wdata
    );
	
	wire HitDM, HitTimer0, HitTimer1;
	assign HitDM = ((bridge_addr>=32'h0000_0000)&(bridge_addr<=32'h0000_2fff));
	assign HitTimer0 = ( (bridge_addr>=32'h0000_7f00)&(bridge_addr<=32'h0000_7f0b) );
	assign HitTimer1 = ( (bridge_addr>=32'h0000_7f10)&(bridge_addr<=32'h0000_7f1b) );
	
	assign m_data_byteen = (HitDM ? bridge_byteen : 4'b0000);
	assign Timer0_WE = (HitTimer0 & (bridge_byteen==4'b1111));
	assign Timer1_WE = (HitTimer1 & (bridge_byteen==4'b1111));
	
	assign CPU_data = (HitDM     ? DM_data :
					   HitTimer0 ? Timer0_data :
					   HitTimer1 ? Timer1_data : 32'haaaa_aaaa);
					   
	assign Addr = bridge_addr;
	
	assign Wdata = bridge_wdata;
	
endmodule
