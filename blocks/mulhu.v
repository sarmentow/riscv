module mulhu(a, b, out);
	input [31:0]a, b;
	output [31:0] out;
	
	wire [63:0]extended_a, extended_b, full_result;

	assign extended_a = { {32{1'b0}}, a };
	assign extended_b = { {32{1'b0}}, b };
	assign full_result = extended_a * extended_b;


	assign out[31:0] = full_result[63:31];
endmodule
