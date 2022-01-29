module control(opcode, opcode1, opcode2, opcode3, opcode4, ins4_rd, ins3_rd, ins2_rs1, ins2_rs2,  ins3_rs2, branch_comp, pc_next_address_sel, regfile_data_source_sel, dmem_write, regfile_write, alu_forward_sel_rs1, alu_forward_sel_rs2, brancher_forward_sel_rs1, brancher_forward_sel_rs2, stall_decode, dmem_store_data_forward_sel);
	input [6:0] opcode, opcode1, opcode2, opcode3, opcode4;
	input [4:0] ins4_rd, ins3_rd, ins2_rs1, ins2_rs2, ins3_rs2;
	input branch_comp;

	output [1:0] pc_next_address_sel;
	// 5 possible outputs for regfile; So 3 bits to select
	output [2:0] regfile_data_source_sel;
	output dmem_write, regfile_write, stall_decode;
	// 3 possible selections; Either rs1 depends on val from ins3 or ins4 or
	// doesn't depend on any; So 2 bits to select
	output [2:0] alu_forward_sel_rs1, alu_forward_sel_rs2, brancher_forward_sel_rs1, brancher_forward_sel_rs2;
	output dmem_store_data_forward_sel;

	// pc + 4, jal, jalr, branch
	// 0     , 1  , 2   , 3
	assign pc_next_address_sel = opcode2 == 7'b0110011 ? 0 : // r-type add, sub
		                         opcode2 == 7'b0010011 ? 0 : // i-type addi, subi
								 opcode2 == 7'b0000011 ? 0 : // loads
								 opcode2 == 7'b0100011 ? 0 : // stores
								 opcode2 == 7'b0110111 ? 0 : // lui
								 opcode2 == 7'b0010111 ? 0 : // auipc
								 opcode2 == 7'b1101111 ? 1 : // jal
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

	assign alu_forward_sel_rs1 = ins2_rs1 == 0  && (opcode2 ==  7'b0110011 || opcode2 == 7'b0010011) ? 0 :
		                         ins3_rd == ins2_rs1 && (opcode2 == 7'b0110011 || opcode2 ==  7'b0010011) && (opcode3 == 7'b0110011 || opcode3 ==  7'b0010011) ? 1 : 
	                             ins4_rd == ins2_rs1 && (opcode2 == 7'b0110011 || opcode2 ==  7'b0010011) && (opcode4 == 7'b0110011 || opcode4 ==  7'b0010011) ? 2 :
								 (opcode3 == 7'b0110111 && ins2_rs1 == ins3_rd) ? 3 : 
								 opcode3 == 7'b0010111 && ins2_rs1 == ins3_rd ? 4 : 0;

							 // after I'm finished with adding the logic
							 // related to lui, also do it with auipc
	assign alu_forward_sel_rs2 = ins2_rs2 == 0 && opcode2 == 7'b0110011 ? 0 :
		                         opcode2 == 7'b0010011 ? 1 : // immediate
	                             (ins3_rd == ins2_rs2 && opcode2 == 7'b0110011) ? 2 : // R-type
								 (ins4_rd == ins2_rs2 && opcode2 == 7'b0110011) ? 3 : 
								 opcode3 == 7'b0110111 && ins2_rs2 == ins3_rd ? 4 : 
								 opcode3 == 7'b0010111 && ins2_rs2 == ins3_rd ? 5 : 0; // same


	// 1 is take alu_out3
	// 2 is take alu_out4
	// 3 is take dmem_out4
	// 0 is regular behaviour
	assign brancher_forward_sel_rs1 = opcode2 == 7'b1100011 && (ins3_rd == ins2_rs1) && (opcode3 == 7'b0110011 || opcode3 == 7'b0010011) ? 1 : 
		                              opcode2 == 7'b1100011 && ins4_rd == ins2_rs1 && (opcode4 == 7'b0110011 || opcode4 == 7'b0010011) ? 2 : 
									  opcode2 == 7'b1100011 && ins3_rd == ins2_rs1 && opcode3 == 7'b0000011 ? 3 : 
								      opcode2 == 7'b1100011 && opcode3 == 7'b0110111 && ins3_rd == ins2_rs1 ? 4 : 
									  opcode2 == 7'b1100011 && opcode3 == 7'b0010111 && ins3_rd == ins2_rs1 ? 5 : 0;

	assign brancher_forward_sel_rs2 = opcode2 == 7'b1100011 && (ins3_rd == ins2_rs2) && (opcode3 == 7'b0110011 || opcode3 == 7'b0010011) ? 1 : 
		                              opcode2 == 7'b1100011 && ins4_rd == ins2_rs2 && (opcode4 == 7'b0110011 || opcode4 == 7'b0010011) ? 2 : 
									  opcode2 == 7'b1100011 && ins3_rd == ins2_rs2 && opcode3 == 7'b0000011 ? 3 :
								      opcode2 == 7'b1100011 && opcode3 == 7'b0110111 && ins3_rd == ins2_rs2 ? 4 : 
									  opcode2 == 7'b1100011 && opcode3 == 7'b0010111 && ins3_rd == ins2_rs2 ? 5 : 0;

	assign stall_decode = opcode2 == 7'b1101111 || opcode2 == 7'b1100111 || branch_comp ? 1 : 0;

	// if the instruction at t - 1 (i.e. at the next pipeline stage) is of
	// U/R/I-type (because they can alter regfile results) and my rs2 (which
	// corresponds to what's feeding the data bus in store instructions) is
	// equal to the instruction at t - 1's rd, then forward;
	assign dmem_store_data_forward_sel = (opcode4 == 7'b0110111 || opcode4 == 7'b0010111 || opcode4 == 7'b0010011 || opcode4 == 7'b0110011) && ins4_rd == ins3_rs2 && opcode3 == 7'b0100011 ? 1 : 0;

endmodule
