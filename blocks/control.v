module control(opcode, opcode1, opcode2, opcode3, opcode4, ins4_rd, ins3_rd, ins2_rs1, ins2_rs2,  ins3_rs2, ins1_rs1, ins1_rs2, branch_comp, stall_load_use, load_forward_sel_rs1, load_forward_sel_rs2, pc_next_address_sel, regfile_data_source_sel, dmem_write, regfile_write, alu_forward_sel_rs1, alu_forward_sel_rs2, brancher_forward_sel_rs1, brancher_forward_sel_rs2, stall_decode, dmem_store_data_forward_sel);
// TODO see if adding ECALL and other special instructions breaks the current
// forwarding logic
	input [6:0] opcode, opcode1, opcode2, opcode3, opcode4;
	input [4:0] ins4_rd, ins3_rd, ins2_rs1, ins2_rs2, ins3_rs2, ins1_rs1, ins1_rs2;
	input branch_comp, stall_load_use;

	output [2:0] pc_next_address_sel;
	// 5 possible outputs for regfile; So 3 bits to select
	output [2:0] regfile_data_source_sel;
	output dmem_write, regfile_write, stall_decode;
	// 3 possible selections; Either rs1 depends on val from ins3 or ins4 or
	// doesn't depend on any; So 2 bits to select
	output [2:0] alu_forward_sel_rs1, alu_forward_sel_rs2, brancher_forward_sel_rs1, brancher_forward_sel_rs2;
	output dmem_store_data_forward_sel, load_forward_sel_rs1, load_forward_sel_rs2;

	// utility wires to avoid repeating myself
	wire ins1_has_rs2, ins1_has_rs1, ins2_has_rs2, ins2_has_rs1, ins4_has_rd;
	assign ins1_has_rs2 = (opcode1 == 7'b1100011 || opcode1 == 7'b0100011 || opcode1 == 7'b0110011);

	assign ins1_has_rs1 = (opcode1 == 7'b1100111 || opcode1 == 7'b1100011 ||
						   opcode1 == 7'b0000011 || opcode1 == 7'b0100011 ||
						   opcode1 == 7'b0010011 || opcode1 == 7'b0110011 ||
						   opcode1 == 7'b0001111);

	assign ins2_has_rs2 = (opcode1 == 7'b1100011 || opcode1 == 7'b0100011 || opcode1 == 7'b0110011);

	assign ins2_has_rs1 = (opcode1 == 7'b1100111 || opcode1 == 7'b1100011 ||
						   opcode1 == 7'b0000011 || opcode1 == 7'b0100011 ||
						   opcode1 == 7'b0010011 || opcode1 == 7'b0110011 ||
						   opcode1 == 7'b0001111);

	assign ins4_has_rd = (opcode4 == 7'b0110111 || opcode4 == 7'b0010111 ||
						  opcode4 == 7'b1101111 || opcode4 == 7'b1100111 ||
						  opcode4 == 7'b0000011 || opcode4 == 7'b0010011 ||
						  opcode4 == 7'b0010011 || opcode4 == 7'b0110011);

	assign ins3_has_rd = (opcode3 == 7'b0110111 || opcode3 == 7'b0010111 ||
						  opcode3 == 7'b1101111 || opcode3 == 7'b1100111 ||
						  opcode3 == 7'b0000011 || opcode3 == 7'b0010011 ||
						  opcode3 == 7'b0010011 || opcode3 == 7'b0110011);


	// pc + 4, jal, jalr, branch
	// 0     , 1  , 2   , 3
	assign pc_next_address_sel = stall_load_use ? 4 :
		                         opcode2 == 7'b0110011 ? 0 : // r-type add, sub
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
						   opcode4 == 7'b1101111 ? 1 : // jal
						   opcode4 == 7'b1100111 ? 1 : 0; // jalr

	assign alu_forward_sel_rs1 = ins2_rs1 == 0  && (opcode2 ==  7'b0110011 || opcode2 == 7'b0010011) ? 0 :
		                         ins3_rd == ins2_rs1 && (opcode2 == 7'b0110011 || opcode2 ==  7'b0010011) && (opcode3 == 7'b0110011 || opcode3 ==  7'b0010011) ? 1 : 
	                             ins4_rd == ins2_rs1 && (opcode2 == 7'b0110011 || opcode2 ==  7'b0010011) && (opcode4 == 7'b0110011 || opcode4 ==  7'b0010011) ? 2 :
								 (opcode3 == 7'b0110111 && ins2_rs1 == ins3_rd) && ins2_has_rs1 ? 3 : 
								 opcode3 == 7'b0010111 && ins2_rs1 == ins3_rd  && ins2_has_rs1? 4 : 
								 ins2_rs1 == ins4_rd && ins4_has_rd && ins2_has_rs1? 6 : 0;

							 // after I'm finished with adding the logic
							 // related to lui, also do it with auipc
	// 0 is rs2_2
	// 1 is immediate
	// 3 is alu_out3
	// 4 is alu_out4
	// 5 is lui_val3
	// 6 is auipc_val3
	assign alu_forward_sel_rs2 = ins2_rs2 == 5'b00000 && opcode2 == 7'b0110011 ? 0 :
		                         opcode2 == 7'b0010011 ? 1 : // immediate
	                             (ins3_rd == ins2_rs2 && opcode2 == 7'b0110011) && ins3_has_rd ? 2 : // R-type
								 (ins4_rd == ins2_rs2 && opcode2 == 7'b0110011) && ins4_has_rd ? 3 : 
								 opcode3 == 7'b0110111 && ins2_rs2 == ins3_rd && ins2_has_rs2 ? 4 : 
								 opcode3 == 7'b0010111 && ins2_rs2 == ins3_rd && ins2_has_rs2 ? 5 : 
								 ins2_rs2 == ins4_rd && ins2_has_rs2 && ins4_has_rd ? 6 : 0;


	// 1 is take alu_out3
	// 2 is take alu_out4
	// 3 is take dmem_out4
	// 0 is regular behaviour
	assign brancher_forward_sel_rs1 = opcode2 == 7'b1100011 && (ins3_rd == ins2_rs1) && (opcode3 == 7'b0110011 || opcode3 == 7'b0010011) ? 1 : 
		                              opcode2 == 7'b1100011 && ins4_rd == ins2_rs1 && (opcode4 == 7'b0110011 || opcode4 == 7'b0010011) ? 2 : 
									  opcode2 == 7'b1100011 && ins4_rd == ins2_rs1 && opcode4 == 7'b0000011 ? 3 : 
								      opcode2 == 7'b1100011 && opcode3 == 7'b0110111 && ins3_rd == ins2_rs1 ? 4 : 
									  opcode2 == 7'b1100011 && opcode3 == 7'b0010111 && ins3_rd == ins2_rs1 ? 5 : 0;

	assign brancher_forward_sel_rs2 = opcode2 == 7'b1100011 && (ins3_rd == ins2_rs2) && (opcode3 == 7'b0110011 || opcode3 == 7'b0010011) ? 1 : 
		                              opcode2 == 7'b1100011 && ins4_rd == ins2_rs2 && (opcode4 == 7'b0110011 || opcode4 == 7'b0010011) ? 2 : 
									  opcode2 == 7'b1100011 && ins4_rd == ins2_rs2 && opcode4 == 7'b0000011 ? 3 :
								      opcode2 == 7'b1100011 && opcode3 == 7'b0110111 && ins3_rd == ins2_rs2 ? 4 : 
									  opcode2 == 7'b1100011 && opcode3 == 7'b0010111 && ins3_rd == ins2_rs2 ? 5 : 0;

	assign stall_decode = opcode2 == 7'b1101111 || opcode2 == 7'b1100111 || branch_comp ? 1 : 0;

	// if the instruction at t - 1 (i.e. at the next pipeline stage) is of
	// U/R/I-type (because they can alter regfile results) and my rs2 (which
	// corresponds to what's feeding the data bus in store instructions) is
	// equal to the instruction at t - 1's rd, then forward;
	assign dmem_store_data_forward_sel = (opcode4 == 7'b0110111 || opcode4 == 7'b0010111 || opcode4 == 7'b0010011 || opcode4 == 7'b0110011) && ins4_rd == ins3_rs2 && opcode3 == 7'b0100011 ? 1 : 0;

	// if at the wb stage I have a load instruction and my current instruction
	// needs any type of register access for rs1 and it coincides with the rd
	// from the load instruction, forward -> TODO this shouldn't work, it makes no
	// sense; I'm going to rewrite the entire logic behind it and if it breaks
	// I should come back here later
//	assign load_forward_sel_rs1 = opcode4 == 7'b0000011 && (opcode1 == 7'b1100011 || opcode1 == 7'b0000011 || opcode1 == 7'b0010011 || opcode1 == 7'b0110011 || opcode1 == 7'b0100011) && ins1_rs1 == ins4_rd ? 1 : 0;
//	assign load_forward_sel_rs2 = opcode4 == 7'b0000011 && (opcode1 == 7'b1100011 || opcode1 == 7'b0110011 || opcode1 == 7'b0100011) && ins1_rs2 == ins4_rd ? 1 : 0;
	
	// if at the WB stage I have ANY destination register (i.e. rd field) and
	// my current instruction at ID depends on the result that will be
	// only written back on the next clock, then I need to forward the data that's being fed into the regfile in this clock cycle
	assign load_forward_sel_rs1 = ins4_has_rd && ins1_has_rs1 && (ins1_rs1 == ins4_rd) ? 1 : 0;
	assign load_forward_sel_rs2 =  ins4_has_rd && ins1_has_rs2 && (ins1_rs2 == ins4_rd) ? 1 : 0;

endmodule
