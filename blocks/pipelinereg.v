module pipeline_register(clk, in, clear, out);
	input clk, clear;
	input [31:0] in;
	output reg [31:0] out;

	// TODO I need to fix this problem where nops make it so that
	// control forwards values from the alu when you're trying to load
	// immediates because x0 is an operand of a nop.
	initial begin
		out <= 32'b0;
	end

	always @ (posedge clk) begin
		if (clear) begin
			out <= 32'b00000000000000000000000000010011;
		end else begin
			out <= in;
		end 
	end


endmodule
