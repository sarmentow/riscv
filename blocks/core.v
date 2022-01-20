`include "mux.v"
`include "pipelinereg.v"
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
	wire [31:0] alu_in, alu_out, rs1_1, rs2_1, regfile_data; 
	wire [31:0] dmem_out, dmem_address_calc, dmem_data_size_out, dmem_data;
	wire [31:0] pc_next, pc_out, pc_next_line, ins, branch_addr;
	wire [1:0] pc_next_sel;
	wire [31:0] jump_sel, jal_address_calc, jalr_address_calc, jalr_address_calc_last_bit_not_set;
	wire regfile_write, dmem_write, pc_write;
	wire [2:0] regfile_data_source_sel;

	wire should_branch;
	
	wire[31:0] lui_val4, auipc_val4;

	assign lui_val4 = {ins4[31:12], 12'b000000000000};
	assign auipc_val4 = {ins4[31:12], 12'b000000000000} + pc_out4;

	assign pc_write = clk;

	assign dmem_data = rs2_3;

	assign alu_in = imm_alu_sel ? ins2[31:20] : rs2_2;
	// figure out if it's load or store
	assign dmem_address_calc = ins3[6:0] == 7'b0100011 ? {ins3[31:25], ins3[11:7]} + rs1_3 : ins3[31:20] + rs1_3;

	assign jal_address_calc = {ins2[31],ins2[19:12],ins2[20],ins2[30:21],1'b0} + pc_out2;
	assign jalr_address_calc_last_bit_not_set = ins2[31:20] + rs1_2;
	assign jalr_address_calc = {jalr_address_calc_last_bit_not_set[31:1], 1'b0};
	assign branch_addr = {ins2[31],ins2[7],ins2[30:25],ins2[11:8]} + pc_out2;
	assign pc_next_line = pc_out + 4;

	// pipeline wires
	// Naming schemes works as follows wirename$NUMBER means
	// that the signal in that wire corresponds to an instruction
	// emmited at t - $NUMBER; So pc_out2 is the signal of pc_out
	// 2 instructions ago; i.e. t, t - 1, **t - 2**
	wire [31:0] pc_out1, pc_out2, pc_out3, pc_out4;
	wire [31:0] ins1, ins2, ins3, ins4;
	wire [31:0] rs1_2, rs1_3, rs2_2, rs2_3;
	wire [31:0] alu_out3, alu_out4;
	wire [31:0] dmem_out4;

	pc program_counter(pc_next, clk, pc_write, pc_out);
	mux4 pc_next_address_mux(pc_next_line, jal_address_calc, jalr_address_calc, branch_addr, pc_next_sel, pc_next);
	mux8 regfile_data_source_mux(alu_out4, dmem_out4, pc_out4, lui_val4, auipc_val4, 0, 0, 0, regfile_data_source_sel, regfile_data);
	brancher branch_condition_checker(rs1_2, rs2_2, ins2[14:12], should_branch);
	// TODO This is going to need major refactoring; It needs to take
	// ins to ins4
	control core_control_unit(ins[6:0], ins1[6:0], ins2[6:0], ins3[6:0], ins4[6:0], should_branch, pc_next_sel, regfile_data_source_sel, imm_alu_sel, dmem_write, regfile_write);
	insmem imem(pc_out, ins);
	regfile registers(clk, ins1[19:15], ins1[24:20], ins4[11:7], regfile_write, regfile_data, rs1_1, rs2_1);
	alu alunit(rs1_2, alu_in, {ins2[31:25],ins2[14:12]}, alu_out);
	datamem dmem(clk, dmem_address_calc, dmem_data, ins3[14:12], dmem_write, dmem_out);
	datamemSizeSel datamem_size_sel(dmem_out, ins3[14:12], dmem_data_size_out);
	pipeline_register reg_pc_out1(clk, pc_out, pc_out1);
	pipeline_register reg_pc_out2(clk, pc_out1, pc_out2);
	pipeline_register reg_pc_out3(clk, pc_out2, pc_out3);
	pipeline_register reg_pc_out4(clk, pc_out3, pc_out4);
	pipeline_register reg_ins1(clk, ins, ins1);
	pipeline_register reg_ins2(clk, ins1, ins2);
	pipeline_register reg_ins3(clk, ins2, ins3);
	pipeline_register reg_ins4(clk, ins3, ins4);
	pipeline_register reg_rs1_2(clk, rs1_1, rs1_2);
	pipeline_register reg_rs1_3(clk, rs1_2, rs1_3);
	pipeline_register reg_rs2_2(clk, rs2_1, rs2_2);
	pipeline_register reg_rs2_3(clk, rs2_2, rs2_3);
	pipeline_register reg_alu_out3(clk, alu_out, alu_out3);
	pipeline_register reg_alu_out4(clk, alu_out3, alu_out4);
	pipeline_register reg_dmem_out4(clk, dmem_out, dmem_out4);

endmodule
