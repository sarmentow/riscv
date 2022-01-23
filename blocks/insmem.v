module insmem(address, ins_out);
	input [31:0] address;
	output [31:0] ins_out;

	// 100 32 bit instruction capacity = 400 1 byte pieces of
	// instruction
	reg [7:0] ins [399:0];

	initial begin
		// jal x0, 8
		ins[0] <= 8'b01101111;
		ins[1] <= 8'b00000000;
		ins[2] <= 8'b10000000;
		ins[3] <= 8'b00000000;

		// addi x1, x0, 10
		ins[4] <= 8'b10010011;
		ins[5] <= 8'b00000000;
		ins[6] <= 8'b10100000;
		ins[7] <= 8'b00000000;

		// addi x2, x0, 15
		ins[8] <= 8'b00010011;
		ins[9] <= 8'b00000001;
		ins[10] <= 8'b11110000;
		ins[11] <= 8'b00000000;

		// addi x1, x1, 4
		ins[12] <= 8'b10010011;
		ins[13] <= 8'b10000000;
		ins[14] <= 8'b01000000;
		ins[15] <= 8'b00000000;

		// jal x0, -8
		ins[16] <= 8'b01101111;
		ins[17] <= 8'b11110000;
		ins[18] <= 8'b10011111;
		ins[19] <= 8'b11111111;
	end

	assign ins_out = {ins[address + 3], ins[address + 2], ins[address + 1], ins[address]};
endmodule
