`include "regfile.v"
module regfile_tb;
	reg clk = 0;
	reg[4:0] addr1, addr2, addrWrite;
	reg write = 0;
	reg[31:0] dataWrite;
	wire[31:0] rs1, rs2;

	initial begin
		$monitor("%d", rs1);
		#5 addr1 = 4;
		#20
		#5 addrWrite = 4; dataWrite = 32; write =1;
		#20 write = 0;
	end

	always begin
		#5 clk = !clk;
	end

	regfile rf(clk, addr1, addr2, addrWrite, write, dataWrite, rs1, rs2);
endmodule
