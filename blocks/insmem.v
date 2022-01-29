module insmem(address, ins_out);
	input [31:0] address;
	output [31:0] ins_out;

	// 100 32 bit instruction capacity = 400 1 byte pieces of
	// instruction
	reg [7:0] ins [399:0];

	integer i;
	initial begin
		for (i = 0; i < 400; i = i + 1) begin
			ins[i] = 32'b0;
		end
		// lui x1, 1
		ins[0] <= 8'b10110111;
		ins[1] <= 8'b00010000;
		ins[2] <= 8'b00000000;
		ins[3] <= 8'b00000000;

		// addi x3, x1, 0
		ins[4] <= 8'b10010011;
		ins[5] <= 8'b10000001;
		ins[6] <= 8'b00000000;
		ins[7] <= 8'b00000000;
	end

	assign ins_out = {ins[address + 3], ins[address + 2], ins[address + 1], ins[address]};
endmodule
