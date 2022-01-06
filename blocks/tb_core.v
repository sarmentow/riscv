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

		#5 ins = 32'b00000000000100001000000010010011;
		#100;
		$finish;
	end

	core c(clk, ins);	

endmodule
