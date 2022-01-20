module control(opcode, opcode1, opcode2, opcode3, opcode4, branch_comp, pc_next_address_sel, regfile_data_source_sel, imm_alu_sel, dmem_write, regfile_write);
	input [6:0] opcode, opcode1, opcode2, opcode3, opcode4;
	input branch_comp;

	// 5 possible outputs for regfile
	output [1:0] pc_next_address_sel;
	output [2:0] regfile_data_source_sel;
	output imm_alu_sel, dmem_write, regfile_write;

	// pc + 4, jal, jalr, branch
	// 0     , 1  , 2   , 3
	assign pc_next_address_sel = opcode2 == 7'b0110011 ? 0 : // r-type add, sub
		                         opcode2 == 7'b0010011 ? 0 : // i-type addi, subi
								 opcode2 == 7'b0000011 ? 0 : // loads
								 opcode2 == 7'b0100011 ? 0 : // stores
								 opcode2 == 7'b0110111 ? 0 : // lui
								 opcode2 == 7'b0010111 ? 0 : // auipc
								 opcode2 == 7'b1100111 ? 1 : // jal
								 opcode2 == 7'b1100011 ? 2 : // jalr
								 opcode2 == 7'b1100011 ? branch_comp : 0; // branches

	// alu, dmem out, pc + 4, lui, auipc
	// 0  , 1       , 2     , 3  , 4
	assign regfile_data_source_sel = opcode4 == 7'b0110011 ? 0 : // r-type add, sub
		                             opcode4 == 7'b0010011 ? 0 : // i-type addi, subi
								     opcode4 == 7'b0000011 ? 1 : // loads
								     opcode4 == 7'b0100011 ? 0 : // stores
								     opcode4 == 7'b0110111 ? 3 : // lui
								     opcode4 == 7'b0010111 ? 4 : // auipc
								     opcode4 == 7'b1100111 ? 2 : // jal
								     opcode4 == 7'b1100011 ? 2 : // jalr
								     opcode4 == 7'b1100011 ? 0 : 0; // branches

	// rs2, imm
	// 0  , 1
	assign imm_alu_sel = opcode2 == 7'b0010011 ? 1 : 0;

	assign dmem_write = opcode3 == 7'b0100011 ? 1 : 0; // stores
	
	assign regfile_write = opcode4 == 7'b0110011 ? 1 : // r-type add, sub
		                   opcode4 == 7'b0010011 ? 1 : // i-type addi, subi
						   opcode4 == 7'b0000011 ? 1 : // loads
						   opcode4 == 7'b0100011 ? 0 : // stores
						   opcode4 == 7'b0110111 ? 1 : // lui
						   opcode4 == 7'b0010111 ? 1 : // auipc
						   opcode4 == 7'b1100111 ? 1 : // jal
						   opcode4 == 7'b1100011 ? 1 : 0; // jalr
endmodule
