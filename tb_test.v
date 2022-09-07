`timescale 1ns/1ps

module cscore_mips(
		input wire clk,
		input wire reset,
		input wire interrupt,
		output wire [31:0] macroscopic_pc,

		input wire [31:0] i_inst_rdata,
		output wire [31:0] i_inst_addr,

		input wire [31:0] m_data_rdata,
		output wire [31:0] m_data_addr,
		output wire [31:0] m_data_wdata,
		output wire [3:0] m_data_byteen,

		output wire [31:0] m_inst_addr,

		output wire w_grf_we,
		output wire [4:0] w_grf_addr,
		output wire [31:0] w_grf_wdata,

		output wire [31:0] w_inst_addr
	);

	reg [31:0] pc;
	reg [31:0] count;
	reg [31:0] delay;
	reg [31:0] old_pc;
	reg [31:0] write_addr;
	reg [3:0] byte_enabled;

	assign i_inst_addr = 0;
	assign m_data_wdata = 0;
	assign m_inst_addr = 0;
	assign w_grf_we = 0;
	assign w_grf_addr = 0;
	assign w_grf_wdata = 0;
	assign w_inst_addr = 0;

	assign macroscopic_pc = pc;
	assign m_data_addr = write_addr;
	assign m_data_byteen = byte_enabled;

	always @(posedge clk) begin
		if (reset) begin
			count <= 0;
			delay <= 0;
			old_pc <= 0;
			pc <= 32'h3000;
			pc <= 32'h3000;
			byte_enabled <= 0;
		end
		else begin
			write_addr <= 0;
			byte_enabled <= 0;
			pc <= (pc < 32'h4000 && pc > 32'h30a0) ? 32'h3000 : pc + 4;
			if (interrupt) begin
				write_addr <= 32'h7F20;
				byte_enabled <= 1;
				old_pc <= pc;
				delay <= 2;
			end
			if (delay) begin
				if (delay == 1) begin
					pc <= 32'h4180;
					count <= 5;
				end
				delay <= delay - 1;
			end
			if (count) begin
				if (count == 1) begin
					pc <= old_pc;
				end
				count <= count - 1;
			end
		end
	end

endmodule
