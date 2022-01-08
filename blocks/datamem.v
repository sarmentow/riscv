// Byte addressable
module datamem(clk, addr, data, write, out);
	input [31:0] addr;
	input [31:0] data;
	output reg [31:0] out;
	input clk, write;
	reg [7:0] memory [16383:0];

	integer i;
	
	initial begin
		$dumpfile("core.vcd");
		for (i = 0; i < 200; i = i + 1) begin
			memory[i] <= 0;
			$dumpvars(0, memory[i]);
		end
	end

	// TODO logic for store byte, half word ....
	always @ (posedge clk) begin
		if (write && addr < 16383 - 2) 
			memory[addr] <= data[7:0];
			memory[addr + 1] <= data[15:8];
			memory[addr + 2] <= data[23:16];
			memory[addr + 3] <= data[31:24];
		out <= {memory[addr + 3], memory[addr + 2], memory[addr + 1], memory[addr]};
	end
endmodule

module datamemSizeSel (dmem_out, sel, out);
	input [31:0] dmem_out;	
	input [2:0] sel; 
	output [31:0] out;
	wire [7:0] lb, lbu;
	wire [15:0] lh, lhu; 
	assign lb = {dmem_out[7:0], 24'b0} >>> 24; 
	assign lh = {dmem_out[15:0], 16'b0} >>> 16;
	assign lbu = dmem_out[7:0];
	assign lhu = dmem_out[15:0]; 
	assign out = sel == 3'b000 ? lb :
		     sel == 3'b001 ? lh :
		     sel == 3'b010 ? dmem_out :
		     sel == 3'b100 ? lbu :
		     sel == 3'b101 ? lhu : dmem_out; 
endmodule

