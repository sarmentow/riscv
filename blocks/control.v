module control(opcode, branch_comp, pc_next_address_sel, regfile_data_source_sel, imm_alu_sel, dmem_write, regfile_write);
	input [6:0] opcode;
	input branch_comp;

	// 5 possible outputs for regfile
	output [1:0] pc_next_address_sel;
	output [2:0] regfile_data_source_sel;
	output imm_alu_sel, dmem_write, regfile_write;

	// pc + 4, jal, jalr, branch
	// 0     , 1  , 2   , 3
	assign pc_next_address_sel = opcode == 7'b0110011 ? 0 : // r-type add, sub
		                         opcode == 7'b0010011 ? 0 : // i-type addi, subi
								 opcode == 7'b0000011 ? 0 : // loads
								 opcode == 7'b0100011 ? 0 : // stores
								 opcode == 7'b0110111 ? 0 : // lui
								 opcode == 7'b0010111 ? 0 : // auipc
								 opcode == 7'b1100111 ? 1 : // jal
								 opcode == 7'b1100011 ? 2 : // jalr
								 opcode == 7'b1100011 ? branch_comp : 0; // branches

	// alu, dmem out, pc + 4, lui, auipc
	// 0  , 1       , 2     , 3  , 4
	assign regfile_data_source_sel = opcode == 7'b0110011 ? 0 : // r-type add, sub
		                             opcode == 7'b0010011 ? 0 : // i-type addi, subi
								     opcode == 7'b0000011 ? 1 : // loads
								     opcode == 7'b0100011 ? 0 : // stores
								     opcode == 7'b0110111 ? 3 : // lui
								     opcode == 7'b0010111 ? 4 : // auipc
								     opcode == 7'b1100111 ? 2 : // jal
								     opcode == 7'b1100011 ? 2 : // jalr
								     opcode == 7'b1100011 ? 0 : 0; // branches

	// rs2, imm
	// 0  , 1
	assign imm_alu_sel = opcode == 7'b0010011 ? 1 : 0;

	assign dmem_write = opcode == 7'b0100011 ? 1 : 0; // stores
	
	assign regfile_write = opcode == 7'b0110011 ? 1 : // r-type add, sub
		                   opcode == 7'b0010011 ? 1 : // i-type addi, subi
						   opcode == 7'b0000011 ? 1 : // loads
						   opcode == 7'b0100011 ? 0 : // stores
						   opcode == 7'b0110111 ? 1 : // lui
						   opcode == 7'b0010111 ? 1 : // auipc
						   opcode == 7'b1100111 ? 1 : // jal
						   opcode == 7'b1100011 ? 1 : 0; // jalr
endmodule
