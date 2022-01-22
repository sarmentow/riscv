module insmem(address, ins_out);
	input [31:0] address;
	output [31:0] ins_out;

	// twenty 32 bit instruction capacity = 80 1 byte pieces of
	// instruction
	reg [7:0] ins [79:0];

	initial begin
		// bge x2, x1, 28
		ins[0] <= 8'b01100011;
		ins[1] <= 8'b01011110;
		ins[2] <= 8'b00010001;
		ins[3] <= 8'b00000000;

		// addi x1, x0, 10
		ins[4] <= 8'b10010011;
		ins[5] <= 8'b00000000;
		ins[6] <= 8'b10100000;
		ins[7] <= 8'b00000000;

		// addi x2, x0, 20
		ins[8] <= 8'b00010011;
		ins[9] <= 8'b00000001;
		ins[10] <= 8'b01000000;
		ins[11] <= 8'b00000001;

		// addi x1, x0, 15
		ins[12] <= 8'b10010011;
		ins[13] <= 8'b00000000;
		ins[14] <= 8'b11110000;
		ins[15] <= 8'b00000000;

		// addi x2, x0, 4
		ins[16] <= 8'b00010011;
		ins[17] <= 8'b00000001;
		ins[18] <= 8'b01000000;
		ins[19] <= 8'b00000000;

		// add x3, x2, x1
		ins[20] <= 8'b10110011;
		ins[21] <= 8'b00000001;
		ins[22] <= 8'b00010001;
		ins[23] <= 8'b00000000;

		// add x3, x3, x1
		ins[24] <= 8'b10110011;
		ins[25] <= 8'b10000001;
		ins[26] <= 8'b00010001;
		ins[27] <= 8'b00000000;

		// addi x3, x1, 7
		ins[28] <= 8'b10010011;
		ins[29] <= 8'b10000001;
		ins[30] <= 8'b01110000;
		ins[31] <= 8'b00000000;

		// addi x3, x3, 14
		ins[32] <= 8'b10010011;
		ins[33] <= 8'b10000001;
		ins[34] <= 8'b11100001;
		ins[35] <= 8'b00000000;
	end

	assign ins_out = {ins[address + 3], ins[address + 2], ins[address + 1], ins[address]};
endmodule
