
module datamem(clk, addr, data, write_sel, write, out);
	input [31:0] addr;
	input [31:0] data;
	output reg [31:0] out;
	input [2:0] write_sel;
	input clk, write;
	reg [7:0] memory [16383:0];

	integer i;
	
	initial begin
		// Testing code
		// Only dump the first 200 bytes of memory for shorter compile time
		$dumpfile("core.vcd");
		for (i = 0; i < 200; i = i + 1) begin
			memory[i] <= 0;
			$dumpvars(0, memory[i]);
		end
	end

	always @ (posedge clk) begin
		if (write) begin
			if (write_sel == 3'b000 && addr <= 16383) begin
				memory[addr] <= data[7:0];	
			end else if (write_sel == 3'b001 && addr < 16383) begin
				memory[addr] <= data[7:0];
				memory[addr + 1] <= data[15:8];

			end else if (write_sel == 3'b010 && addr < 16383 - 2) begin
				memory[addr] <= data[7:0];
				memory[addr + 1] <= data[15:8];
				memory[addr + 2] <= data[23:16];
				memory[addr + 3] <= data[31:24];
			end
		end
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

