module insmem(address, ins_out);
	input [31:0] address;
	output [31:0] ins_out;

	// twenty 32 bit instruction capacity = 80 1 byte pieces of
	// instruction
	reg [7:0] ins [79:0];

	initial begin
		// addi x1, x0, 55
		ins[0] <= 8'b10010011;
		ins[1] <= 8'b00000000;
		ins[2] <= 8'b01110000;
		ins[3] <= 8'b00000011;

		// addi x0, x0, 0
		ins[4] <= 8'b00010011;
		ins[5] <= 8'b00000000;
		ins[6] <= 8'b00000000;
		ins[7] <= 8'b00000000;

		// addi x0, x0, 0
		ins[8] <= 8'b00010011;
		ins[9] <= 8'b00000000;
		ins[10] <= 8'b00000000;
		ins[11] <= 8'b00000000;

		// addi x0, x0, 0
		ins[12] <= 8'b00010011;
		ins[13] <= 8'b00000000;
		ins[14] <= 8'b00000000;
		ins[15] <= 8'b00000000;

		// addi x1, x1, 4
		ins[16] <= 8'b10010011;
		ins[17] <= 8'b10000000;
		ins[18] <= 8'b01000000;
		ins[19] <= 8'b00000000;
	end

	assign ins_out = {ins[address + 3], ins[address + 2], ins[address + 1], ins[address]};
endmodule
