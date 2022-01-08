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

		// addi x1, x1, 1; -> x1 = 1
		#5 ins = 32'b00000000000100001000000010010011;
		#20;
		// lw x1, 0(x0); -> x1 = 0
		#5 ins = 32'b00000000000000000000000010010011;
		#100;
		$finish;
	end

	core c(clk, ins);	

endmodule
