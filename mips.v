`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:51:11 11/20/2021 
// Design Name: 
// Module Name:    mips 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 第一版流水线CPU
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`default_nettype none

module mips(
    input wire clk,                       // 时钟信号
    input wire reset,                     // 同步复位信号
    input wire interrupt,                 // 外部中断信号
    output wire [31:0] macroscopic_pc,    // 宏观 PC

    output wire [31:0] i_inst_addr,       // 取指 PC
    input  wire [31:0] i_inst_rdata,      // i_inst_addr 对应的 32 位指令

    output wire [31:0] m_data_addr,       // 数据存储器待写入地址
    input  wire [31:0] m_data_rdata,      // m_data_addr 对应的 32 位数据
    output wire [31:0] m_data_wdata,      // 数据存储器待写入数据
    output wire [3 :0] m_data_byteen,     // 字节使能信号

    output wire [31:0] m_inst_addr,       // M 级PC

    output wire w_grf_we,                 // grf 写使能信号
    output wire [4 :0] w_grf_addr,        // grf 待写入寄存器编号
    output wire [31:0] w_grf_wdata,       // grf 待写入数据

    output wire [31:0] w_inst_addr        // W 级 PC
	);
	
	wire [31:0] Addr, Wdata, CPU_data;
	wire Timer0_WE, Timer1_WE;
	wire [3:0] m_data_byteen0;
	
	Bridge Bridge (
	.bridge_wdata(bridge_wdata),
    .bridge_addr(bridge_addr), 
    .bridge_byteen(bridge_byteen), 
    .DM_data(m_data_rdata), 
    .Timer0_data(Timer0_data), 
    .Timer1_data(Timer1_data), 
    .CPU_data(CPU_data), //output
    .m_data_byteen(m_data_byteen0), 
    .Timer0_WE(Timer0_WE), 
    .Timer1_WE(Timer1_WE),
	.Addr(Addr),
	.Wdata(Wdata)
    );
	
	assign m_data_addr = (interrupt) ? 32'h7F20 : Addr;
	assign m_data_wdata = (interrupt) ? 32'h9999_9999 : Wdata;
	assign m_data_byteen = (interrupt) ? 4'b1111 : m_data_byteen0;
	
	wire [31:0] bridge_wdata, bridge_addr;
	wire [3:0] bridge_byteen;
	
	CPU_lu CPU ( 
    .clk(clk), 
    .reset(reset), 
    .HWInt(HWInt), 
    .macroscopic_pc(macroscopic_pc), 
    .i_inst_addr(i_inst_addr), 
    .i_inst_rdata(i_inst_rdata), 
	.CPU_data(CPU_data), 
    .bridge_addr(bridge_addr), 
    .bridge_wdata(bridge_wdata), 
    .bridge_byteen(bridge_byteen), 
    .m_inst_addr(m_inst_addr), 
    .w_grf_we(w_grf_we), 
    .w_grf_addr(w_grf_addr), 
    .w_grf_wdata(w_grf_wdata), 
    .w_inst_addr(w_inst_addr)
    );
	
	wire IRQ0, IRQ1;
	wire [31:0] Timer0_data, Timer1_data;
	
	TC timer0 (
    .clk(clk), 
    .reset(reset), 
    .Addr(Addr[31:2]), 
    .WE(Timer0_WE), 
    .Din(Wdata), 
    .Dout(Timer0_data), //output
    .IRQ(IRQ0)
    );
	
	TC timer1 (
    .clk(clk), 
    .reset(reset), 
    .Addr(Addr[31:2]), 
    .WE(Timer1_WE), 
    .Din(Wdata), 
    .Dout(Timer1_data), //output
    .IRQ(IRQ1)
    );
	
	wire [5:0] HWInt;
	assign HWInt = {3'b0, interrupt, IRQ1, IRQ0};

endmodule
