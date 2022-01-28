`include "core.v"
module core_tb;
	reg[31:0] ins;
	reg clk = 0;


	always begin
		#2 clk = !clk;
	end

	initial begin
		$dumpfile("core.vcd");
		$dumpvars(0, core_tb);
		#1000;
		$finish;
	end

	core c(clk);	

endmodule
