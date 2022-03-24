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
		$readmemb("program.bin", ins);
	end

	assign ins_out = {ins[address + 3], ins[address + 2], ins[address + 1], ins[address]};
endmodule
