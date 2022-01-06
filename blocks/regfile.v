module regfile(clk, addr1, addr2, addrWrite, write, dataWrite, rs1, rs2);
	input clk, write;
	input [31:0] dataWrite;
	input [4:0] addr1, addr2, addrWrite;
	output reg[31:0] rs1, rs2;

	reg[31:0] registers[31:0]; // 32-bit registers x 32

	integer i;
	initial begin
		$dumpfile("core.vcd");
		for (i = 0; i < 32; i = i + 1) begin
			registers[i] <= 0;
			$dumpvars(0, registers[i]);
		end
	end

	always @ (posedge clk) begin
		if (write && addrWrite != 5'b00000)
			registers[addrWrite] <= dataWrite;
		rs1 <= registers[addr1];
		rs2 <= registers[addr2];
	end



endmodule
