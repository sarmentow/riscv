`include "alu.v"
`include "regfile.v"
module core(clk, ins);
	input[31:0] ins;
	input clk;
	wire [31:0] alu_res, a, b, rs2;
	wire write;

	// Temporary
	assign write = (ins[6:0] == 7'b0110011 ? 1'b1 : 
	ins[6:0] == 7'b0010011 ? 1'b1 : 0);
	assign b = ins[5] ? rs2 : ins[31:20];

	regfile registers(clk, ins[19:15], ins[24:20], ins[11:7], write, alu_res, a, rs2);
	alu alunit(a, b, {ins[31:25],ins[14:12]}, alu_res);

endmodule
