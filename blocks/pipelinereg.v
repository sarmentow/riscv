// TODO maybe will need to add a flush signal/clear
module pipeline_register(clk, in, clear, out);
	input clk, clear;
	input [31:0] in;
	output reg [31:0] out;

	// is it important for PC updating?
	initial begin
		out <= 32'b00000000000000000000000000010011;
	end

	always @ (posedge clk) begin
		out <= in;
	end

	always @ (posedge clear) begin
		// Nop
		out <= 32'b00000000000000000000000000010011;
	end

endmodule
