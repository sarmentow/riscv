`include "alu.v"
`include "datamem.v"
`include "regfile.v"
`include "pc.v"
`include "insmem.v"

module core(clk);
	input clk;
	// I need better names
	wire [31:0] alu_out, rs1, rs2_or_imm, rs2, regfile_data; 
	wire [31:0] dmem_out, dmem_address_calc, dmem_sel_data_out, dmem_data;
	wire [31:0] pc_next, pc_out, ins, branch_addr;
	wire [31:0] jump_sel, jal_address_calc, jalr_address_calc, jalr_address_calc_last_bit_not_set;

	wire regfile_write, dmem_write, pc_write;

	wire should_jump, branch_or_jump, branch_condition_is_true;
	
	wire[31:0] upper_immediate_val;

	// Write logic is temporary
	assign regfile_write = ins[6:0] == 7'b0110011 ? 1'b1 : 
	                       ins[6:0] == 7'b0010011 ? 1'b1 : 
		               ins[6:0] == 7'b0000011 ? 1'b1 : 
		               ins[6:0] == 7'b1101111 ? 1'b1 : // jal
		               ins[6:0] == 7'b1100111 ? 1'b1 :  // jalr
					   ins[6:0] == 7'b0110111 ? 1'b1 :
					   ins[6:0] == 7'b0101111 ? 1'b1 : 0;

	assign dmem_write = (ins[6:0] == 7'b0100011 ? 1 : 0);

	assign upper_immediate_val = {ins[31:12], 12'b000000000000};

	assign pc_write = clk;

	assign dmem_data = ins[6:0] == 7'b0100011 ? rs2 : 0;

	assign rs2_or_imm = ins[5] ? rs2 : ins[31:20];
	// figure out if it's load or store
	assign dmem_address_calc = ins[6:0] == 7'b0100011 ? {ins[31:25], ins[11:7]} + rs1 : ins[31:20] + rs1;
	assign regfile_data = ins[6:0] == 7'b0000011 ? dmem_sel_data_out : 
		              (ins[6:0] == 7'b1101111 || ins[6:0] == 7'b1100111) ? pc_out + 4 : 
					  ins[6:0] == 7'b0110111 ? upper_immediate_val : 
					  ins[6:0] == 7'b0010111 ? upper_immediate_val + pc_out : alu_out;

	assign jal_address_calc = {ins[31],ins[19:12],ins[20],ins[30:21],1'b0} + pc_out;
	assign jalr_address_calc_last_bit_not_set = ins[31:20] + rs1;
	assign jalr_address_calc = {jalr_address_calc_last_bit_not_set[31:1], 1'b0};
	assign should_jump = (ins[6:0] == 7'b1101111 || ins[6:0] == 7'b1100111) ? 1 : 0;
	assign jump_sel =  should_jump && ins[3] ? jal_address_calc : jalr_address_calc;
	assign branch_addr = {ins[31],ins[7],ins[30:25],ins[11:8]} + pc_out;
	// opcode is branch and condition passes?
	assign pc_next = should_jump ? jump_sel : 
	                 branch_condition_is_true ? branch_addr : pc_out + 4;


	assign branch_condition_is_true = (ins[6:0] == 7'b1100011) && // is branch
		                              ((ins[14:12] == 3'b000 && rs1 == rs2) ||  // is equal in beq
									  (ins[14:12] == 3'b001 && rs1 != rs2) || // is not equal in bne
									  (ins[14:12] == 3'b100 && rs1 < rs2) || // ...
									  (ins[14:12] == 3'b101 && rs1 > rs2) ||
									  (ins[14:12] == 3'b110 && $unsigned(rs1) < $unsigned(rs2)) ||
									  (ins[14:12] == 3'b111 && $unsigned(rs1) > $unsigned(rs2)));

	
	pc program_counter(pc_next, clk, pc_write, pc_out);
	insmem imem(pc_out, ins);
	regfile registers(clk, ins[19:15], ins[24:20], ins[11:7], regfile_write, regfile_data, rs1, rs2);
	alu alunit(rs1, rs2_or_imm, {ins[31:25],ins[14:12]}, alu_out);
	datamem dmem(clk, dmem_address_calc, dmem_data, ins[14:12], dmem_write, dmem_out);
	datamemSizeSel datamem_size_sel(dmem_out, ins[14:12], dmem_sel_data_out);

endmodule
