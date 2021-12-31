module mulh(a, b, out);
	input [31:0]a, b;
	output [31:0] out;
	
	wire [63:0]extended_a, extended_b, full_result;

	assign extended_a = { {32{a[31]}}, a };
	assign extended_b = { {32{b[31]}}, b };
	assign full_result = extended_a * extended_b;


	assign out[31:0] = full_result[63:31];
endmodule
