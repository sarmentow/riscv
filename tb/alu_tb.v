`include "alu.v"
module alu_tb;
	reg [31:0]a, b;
	reg [3:0]op;
	wire[31:0]out;
	initial begin
		$monitor("%h %h %h %h", op, a, b, out);
		#5 op = 0; a=131297; b=23928;
		#5 op = 0; a=12938; b=9031239;
		#5 op = 0; a=-12398; b=-293182938;
		#5 op = 0; a=230808; b=1023909;
		#5 op = 0; a=103922; b=29389;
		#5 op = 0; a=239089; b=90898;
		#5 op = 0; a=-2381938989; b=3801238102983;
		#5 op = 0; a=1238; b=20139;
		#5 $finish;
	end

	alu alu_test(a, b, op, out);

endmodule
