`include "datamem.v"
module tb_datamem;
	reg clk = 0;
	reg write;
	reg [11:0] addr;
	reg [31:0] data;
	reg [2:0] sel;
	wire [31:0] dmem_out;

	initial begin
		$dumpfile("datamem.vcd");
		$dumpvars(0, tb_datamem);
		// write byte
		#5 write = 0; addr = 2; data = 8'b11111111; sel = 0;
		#15
		#5 write = 1;
		#15
		// write halfword
		#5 write = 0; addr = 7; data = 16'b1111111111111111; sel = 1;
		#15
		#5 write = 1;
		#15
		#5 write = 0;
		#15
		#5 addr = 10; data = 32'b11111111111111111111111111111111; write = 1;sel = 2;
		#15
		#5 write = 0;
		#15
		$finish;
	end

	always begin
		#5 clk = !clk;
	end

	datamem dmem(clk, addr, data, sel, write, dmem_out);
//	datamemSizeSel dmem_size_sel(dmem_out, sel, out);
endmodule
