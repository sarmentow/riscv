`include "core.v"
`include "datamem.v"
module core_tb;
	reg clk = 0;
	reg stalled_clk = 0;
	reg stall = 0;
	wire clk_in;

	assign clk_in = stall ? stalled_clk : clk;


	always begin
		#2 clk = !clk;
	end

	always @ (!stall) begin
		stalled_clk = clk;
	end

	initial begin
		$dumpfile("core.vcd");
		$dumpvars(0, core_tb);
		#98 stall = 1;
		#20 stall = 0;	
		#882;
		$finish;
	end

	wire mem_w;
	wire [2:0] mem_w_sel;
	wire [31:0] mem_addr, mem_in_data, mem_out_data;

	core c(clk_in, mem_addr, mem_w, mem_w_sel, mem_in_data, mem_out_data);	
	datamem mem(clk, mem_addr, mem_in_data, mem_w_sel, mem_w, mem_out_data);
	

endmodule
