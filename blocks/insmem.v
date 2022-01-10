module insmem(address, ins_out);
	input [31:0] address;
	output [31:0] ins_out;

	// twenty 32 bit instruction capacity = 80 1 byte pieces of
	// instruction
	reg [7:0] ins [79:0];
	
	initial begin
		// addi x1, x0, 5; => x1 = 5
		// 00000000 01010000 00000000 10010011
		ins[0] <= 8'b10010011;
		ins[1] <= 8'b00000000;
		ins[2] <= 8'b01010000;
		ins[3] <= 8'b00000000;

		// addi x2, x0, 9; => x2 = 9
		// 00000000 10010000 00000001 00010011
		ins[0] <= 8'b00010011;
		ins[1] <= 8'b00000001;
		ins[2] <= 8'b10010000;
		ins[3] <= 8'b00000000;

		// add x1, x1, x2; => x1 = 14
		// 00000000 00100000 10000000 10110011
		ins[0] <= 8'b10110011;
		ins[1] <= 8'b10000000;
		ins[2] <= 8'b00100000;
		ins[3] <= 8'b00000000;

		// sw x1 0(x2);	=> DMEM[9] = 14;
		// 0100011
		ins[0] <= ;
		ins[1] <= ;
		ins[2] <= ;
		ins[3] <= ;

	end

	assign ins_out = {ins[address + 3], ins[address + 2], ins[address + 1], ins[address]};

endmodule
