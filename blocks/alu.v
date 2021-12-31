`include "mux.v"
`include "mulh.v"
`include "mulhu.v"

module alu(a, b, op, out);
	input [31:0]a, b; 
	input [3:0]op;
	output [31:0]out;
	reg [31:0]zero = 0;
	wire [31:0]adder_res, and_res, or_res, xor_res, srl_res,
		sra_res, sll_res, slt_res, mul_res, mulhu_res,
		sub_res, mulh_res;

	assign adder_res = a+b;
	assign and_res = a&b;
	assign or_res = a|b;
	assign xor_res = a^b;
	assign srl_res = a>>b;
	assign sra_res = a>>>b;
	assign sll_res = a<<b;
	assign slt_res = (a < b ? 1 : 0);
	assign mul_res = a*b;
	assign sub_res = a-b;

	// Missing mulhu_res, mulh_res
	
	
	mulh mulh_circ(a, b, mulh_res);
	mulhu mulhu_circ(a, b, mulhu_res);
	mux16 mux_ops(adder_res, and_res, or_res, xor_res, srl_res, 			
				sra_res,
				sll_res, 
				slt_res,
				zero, // no op 8
				zero, // no op 9
				mul_res,
				mulhu_res,
				sub_res,
				b,
				mulh_res,
				zero, // no op 15
				op, 
				out);
	
endmodule
