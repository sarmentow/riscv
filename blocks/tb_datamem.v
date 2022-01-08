`include "datamem.v"
module tb_datamem;
	reg clk = 0;
	reg write;
	reg [11:0] addr;
	reg [31:0] data;
	reg [2:0] sel = 3'b010;
	wire [31:0] dmem_out, out;

	initial begin
		$dumpfile("datamem.vcd");
		$dumpvars(0, tb_datamem);
		#5 write = 0; addr = 2; data = 640;
		#15
		#5 write = 1;
		#15
		#5 write = 0; addr = 7; data = -1280;
		#15
		#5 write = 1;
		#15
		#5 sel = 3'b000;
		#15
		#5 sel = 3'b001;
		#15
		#5 sel = 3'b010;
		#15
		#5 sel = 3'b100;
		#15
		#5 sel = 3'b101;
		#15
		$finish;
	end

	always begin
		#5 clk = !clk;
	end

	datamem dmem(clk, addr, data, write, dmem_out);
	datamemSizeSel dmem_size_sel(dmem_out, sel, out);
endmodule
