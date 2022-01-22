module control(opcode, opcode1, opcode2, opcode3, opcode4, ins4_rd, ins3_rd, ins2_rs1, ins2_rs2,  branch_comp, pc_next_address_sel, regfile_data_source_sel, dmem_write, regfile_write, alu_forward_sel_rs1, alu_forward_sel_rs2);
	input [6:0] opcode, opcode1, opcode2, opcode3, opcode4;
	input [4:0] ins4_rd, ins3_rd, ins2_rs1, ins2_rs2;
	input branch_comp;

	output [1:0] pc_next_address_sel;
	// 5 possible outputs for regfile; So 3 bits to select
	output [2:0] regfile_data_source_sel;
	output dmem_write, regfile_write;
	// 3 possible selections; Either rs1 depends on val from ins3 or ins4 or
	// doesn't depend on any; So 2 bits to select
	output [1:0] alu_forward_sel_rs1, alu_forward_sel_rs2;

	// pc + 4, jal, jalr, branch
	// 0     , 1  , 2   , 3
	assign pc_next_address_sel = opcode2 == 7'b0110011 ? 0 : // r-type add, sub
		                         opcode2 == 7'b0010011 ? 0 : // i-type addi, subi
								 opcode2 == 7'b0000011 ? 0 : // loads
								 opcode2 == 7'b0100011 ? 0 : // stores
								 opcode2 == 7'b0110111 ? 0 : // lui
								 opcode2 == 7'b0010111 ? 0 : // auipc
								 opcode2 == 7'b1100111 ? 1 : // jal
								 opcode2 == 7'b1100111 ? 2 : // jalr
								 opcode2 == 7'b1100011 && branch_comp ? 3 : 0; // branches

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

	assign dmem_write = opcode3 == 7'b0100011 ? 1 : 0; // stores
	
	assign regfile_write = opcode4 == 7'b0110011 ? 1 : // r-type add, sub
		                   opcode4 == 7'b0010011 ? 1 : // i-type addi, subi
						   opcode4 == 7'b0000011 ? 1 : // loads
						   opcode4 == 7'b0100011 ? 0 : // stores
						   opcode4 == 7'b0110111 ? 1 : // lui
						   opcode4 == 7'b0010111 ? 1 : // auipc
						   opcode4 == 7'b1100111 ? 1 : // jal
						   opcode4 == 7'b1100011 ? 1 : 0; // jalr

	assign alu_forward_sel_rs1 = ins3_rd == ins2_rs1 && (opcode2 == 7'b0110011 || opcode2 ==  7'b0010011) && (opcode3 == 7'b0110011 || opcode3 ==  7'b0010011) ? 1 : 
	                             ins4_rd == ins2_rs1 && (opcode2 == 7'b0110011 || opcode2 ==  7'b0010011) && (opcode4 == 7'b0110011 || opcode4 ==  7'b0010011) ? 2 : 0;

	assign alu_forward_sel_rs2 = opcode2 == 7'b0010011 ? 1 : // immediate
	                             (ins3_rd == ins2_rs2 && opcode2 == 7'b0110011) ? 2 : // R-type
								 (ins4_rd == ins2_rs2 && opcode2 == 7'b0110011) ? 3 : 0; // same

endmodule
