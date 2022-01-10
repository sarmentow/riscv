// limit size to 10 or 20 instructions for now
// TODO increase size of PC (all of the 32 bit address space?)
module pc(next_address, clk, w, out);
	input [31:0] next_address;
	input clk, w;
	output reg [31:0] out;
	
	initial begin
		out = 0;
	end
	
	always @ (posedge clk) begin
		if (w) begin
			out <= next_address;	
		end 
	end
	
endmodule
