// TODO maybe will need to add a flush signal/clear
module pipeline_register(clk, in, out);
	input clk;
	input [31:0] in;
	output reg [31:0] out;

	// is it important for PC updating?
	initial begin
		out <= 0;
	end

	always @ (posedge clk) begin
		out <= in;
	end
endmodule
