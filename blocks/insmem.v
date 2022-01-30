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
		// addi x1, x0, 8
		ins[0] <= 8'b10010011;
		ins[1] <= 8'b00000000;
		ins[2] <= 8'b10000000;
		ins[3] <= 8'b00000000;

		// sw x1, 0(x0)
		ins[4] <= 8'b00100011;
		ins[5] <= 8'b00100000;
		ins[6] <= 8'b00010000;
		ins[7] <= 8'b00000000;

		// addi x1, x0, 92
		ins[8] <= 8'b10010011;
		ins[9] <= 8'b00000000;
		ins[10] <= 8'b11000000;
		ins[11] <= 8'b00000101;

		// sw x1, 4(x0)
		ins[12] <= 8'b00100011;
		ins[13] <= 8'b00100010;
		ins[14] <= 8'b00010000;
		ins[15] <= 8'b00000000;

		// lw x2, 0(x0)
		ins[16] <= 8'b00000011;
		ins[17] <= 8'b00100001;
		ins[18] <= 8'b00000000;
		ins[19] <= 8'b00000000;

		// lw x3, 4(x0)
		ins[20] <= 8'b10000011;
		ins[21] <= 8'b00100001;
		ins[22] <= 8'b01000000;
		ins[23] <= 8'b00000000;

		// bge x3, x2, 16
		ins[24] <= 8'b01100011;
		ins[25] <= 8'b11011000;
		ins[26] <= 8'b00100001;
		ins[27] <= 8'b00000000;

		// addi x1, x0, 1
		ins[28] <= 8'b10010011;
		ins[29] <= 8'b00000000;
		ins[30] <= 8'b00010000;
		ins[31] <= 8'b00000000;

		// addi x2, x0, 1
		ins[32] <= 8'b00010011;
		ins[33] <= 8'b00000001;
		ins[34] <= 8'b00010000;
		ins[35] <= 8'b00000000;

		// addi x3, x0, 1
		ins[36] <= 8'b10010011;
		ins[37] <= 8'b00000001;
		ins[38] <= 8'b00010000;
		ins[39] <= 8'b00000000;

		// addi x0, x0, 0
		ins[40] <= 8'b00010011;
		ins[41] <= 8'b00000000;
		ins[42] <= 8'b00000000;
		ins[43] <= 8'b00000000;
	end

	assign ins_out = {ins[address + 3], ins[address + 2], ins[address + 1], ins[address]};
endmodule
