`include "core.v"
module core_tb;
	reg[31:0] ins;
	reg clk = 0;


	always begin
		#5 clk = !clk;
	end

	initial begin
		$dumpfile("core.vcd");
		$dumpvars(0, core_tb);
		#200;
		$finish;
	end

	core c(clk);	

endmodule
