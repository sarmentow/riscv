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

		// lui x2, 2
		ins[4] <= 8'b00110111;
		ins[5] <= 8'b00100001;
		ins[6] <= 8'b00000000;
		ins[7] <= 8'b00000000;

		// bge x2, x1, 8
		ins[8] <= 8'b01100011;
		ins[9] <= 8'b01010100;
		ins[10] <= 8'b00010001;
		ins[11] <= 8'b00000000;

		// addi x1, x0, 4
		ins[12] <= 8'b10010011;
		ins[13] <= 8'b00000000;
		ins[14] <= 8'b01000000;
		ins[15] <= 8'b00000000;

		// addi x2, x0, 8
		ins[16] <= 8'b00010011;
		ins[17] <= 8'b00000001;
		ins[18] <= 8'b10000000;
		ins[19] <= 8'b00000000;

		// addi x1, x1, 256
		ins[20] <= 8'b10010011;
		ins[21] <= 8'b10000000;
		ins[22] <= 8'b00000000;
		ins[23] <= 8'b00010000;
	end

	assign ins_out = {ins[address + 3], ins[address + 2], ins[address + 1], ins[address]};
endmodule
