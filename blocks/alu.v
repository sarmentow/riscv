//`include "mux.v" <- must comment to avoid conflict with control muxes in core.v
`include "mulh.v"
`include "mulhu.v"

module add_or_sub(a, b, op, out);
	input [31:0] a, b;
	input op;
	output [31:0] out;
	wire [31:0] adder_res, sub_res;

	assign adder_res = a + b;
	assign sub_res = a - b;
	assign out = op ? sub_res : adder_res;
endmodule

module srl_or_sra(a, b, op, out);
	input [31:0] a, b;
	input op;
	output [31:0] out;
	wire [31:0] srl_res, sra_res;

	assign srl_res = a >> b;
	assign sra_res = a >>> b;
	assign out = op ? sra_res : srl_res;

endmodule

module alu(a, b, op, out);
	/* op is funct3 + funct7
	   out value is selected based on funct3 only
	   result gets computed based on flag in funct7 */ 
	input [31:0]a, b; 
	input [9:0]op;
	output [31:0]out;
	reg [31:0]zero = 0;
	wire [31:0]add_or_sub_res, and_res, or_res, xor_res, srl_or_sra_res, sll_res, slt_res, mul_res, mulhu_res, mulh_res, sltu_res;

	assign and_res = a&b;
	assign or_res = a|b;
	assign xor_res = a^b;
	assign sll_res = a<<b;
	assign slt_res = $signed(a) < $signed(b) ? 1 : 0;
	assign sltu_res = $unsigned(a) < $unsigned(b) ? 1 : 0;
	assign mul_res = a*b;

	// add, sub, sll, slt, sltu, xor, srl, sra, or, and

	add_or_sub add_or_sub_circ(a, b, op[8], add_or_sub_res);	
	srl_or_sra srl_or_sra_circ(a, b, op[8], srl_or_sra_res);
	mulh mulh_circ(a, b, mulh_res);
	mulhu mulhu_circ(a, b, mulhu_res);
	mux8 mux_ops(add_or_sub_res, sll_res, slt_res, sltu_res, xor_res, srl_or_sra_res, or_res, and_res, op[2:0], out);
	
endmodule
