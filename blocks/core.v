`include "mux.v"
`include "alu.v"
`include "control.v"
`include "brancher.v"
`include "datamem.v"
`include "regfile.v"
`include "pc.v"
`include "insmem.v"

module core(clk);
	input clk;
	// I need better names
	wire [31:0] alu_in, alu_out, rs1, rs2, regfile_data; 
	wire [31:0] dmem_out, dmem_address_calc, dmem_data_size_out, dmem_data;
	wire [31:0] pc_next, pc_out, pc_next_line, ins, branch_addr;
	wire [1:0] pc_next_sel;
	wire [31:0] jump_sel, jal_address_calc, jalr_address_calc, jalr_address_calc_last_bit_not_set;
	wire regfile_write, dmem_write, pc_write;
	wire [2:0] regfile_data_source_sel;

	wire should_branch;
	
	wire[31:0] lui_val, auipc_val;

	assign lui_val = {ins[31:12], 12'b000000000000};
	assign auipc_val = {ins[31:12], 12'b000000000000} + pc_out;

	assign pc_write = clk;

	assign dmem_data = ins[6:0] == 7'b0100011 ? rs2 : 0;

	assign alu_in = imm_alu_sel ? ins[31:20] : rs2;
	// figure out if it's load or store
	assign dmem_address_calc = ins[6:0] == 7'b0100011 ? {ins[31:25], ins[11:7]} + rs1 : ins[31:20] + rs1;

	assign jal_address_calc = {ins[31],ins[19:12],ins[20],ins[30:21],1'b0} + pc_out;
	assign jalr_address_calc_last_bit_not_set = ins[31:20] + rs1;
	assign jalr_address_calc = {jalr_address_calc_last_bit_not_set[31:1], 1'b0};
	assign branch_addr = {ins[31],ins[7],ins[30:25],ins[11:8]} + pc_out;
	assign pc_next_line = pc_out + 4;
	
	pc program_counter(pc_next, clk, pc_write, pc_out);
	mux4 pc_next_address_mux(pc_next_line, jal_address_calc, jalr_address_calc, branch_addr, pc_next_sel, pc_next);
	mux8 regfile_data_source_mux(alu_out, dmem_out, pc_next_line, lui_val, auipc_val, 0, 0, 0, regfile_data_source_sel, regfile_data);
	brancher branch_condition_checker(rs1, rs2, ins[14:12], should_branch);
	control core_control_unit(ins[6:0], should_branch, pc_next_sel, regfile_data_source_sel, imm_alu_sel, dmem_write, regfile_write);
	insmem imem(pc_out, ins);
	regfile registers(clk, ins[19:15], ins[24:20], ins[11:7], regfile_write, regfile_data, rs1, rs2);
	alu alunit(rs1, alu_in, {ins[31:25],ins[14:12]}, alu_out);
	datamem dmem(clk, dmem_address_calc, dmem_data, ins[14:12], dmem_write, dmem_out);
	datamemSizeSel datamem_size_sel(dmem_out, ins[14:12], dmem_data_size_out);

endmodule
