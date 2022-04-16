`include "mux.v"
`include "pipelinereg.v"
`include "alu.v"
`include "control.v"
`include "brancher.v"
`include "regfile.v"
`include "pc.v"
`include "insmem.v"
`include "loadstaller.v"

module core(clk, mem_addr, mem_w, mem_w_sel, mem_in_data, mem_out_data_raw);
	input clk;
	input [31:0] mem_out_data_raw;
	wire [31:0] mem_out_data_formatted_size;
	assign mem_out_data_formatted_size = ins3[6:0] != 7'b0000011 ? 0 : 
		                                 ins3[14:12] == 3'b010 ? mem_out_data_raw : // lw
		       							 ins3[14:12] == 3'b001 ? (mem_out_data_raw[15] == 1'b1 ? {{16{1'b1}}, mem_out_data_raw[15:0]} : {{16{1'b0}}, mem_out_data_raw[15:0]}) : // lh
										 ins3[14:12] == 3'b000 ? (mem_out_data_raw[7] == 1'b1 ? {{24{1'b1}}, mem_out_data_raw[7:0]} : {{24{1'b0}}, mem_out_data_raw[7:0]}) : // lb
										 ins3[14:12] == 3'b101 ? {{16{1'b0}}, mem_out_data_raw[15:0]} :  //lhu
									     ins3[14:12] == 3'b100 ? {{24{1'b0}}, mem_out_data_raw[7:0]} : mem_out_data_raw;  // lbu

	output [31:0] mem_in_data, mem_addr;
	output [2:0] mem_w_sel;
	assign mem_w_sel = ins3[14:12];
	output mem_w;

	// I need better names
	wire [31:0] alu_rs1_in, alu_rs2_in, alu_out, rs1_1, rs2_1, regfile_data, rs1_1_or_regfile_data, rs2_1_or_regfile_data; 
	wire [31:0] pc_next, pc_out, pc_next_line, ins, branch_addr;
	wire [2:0] pc_next_sel;
	wire [31:0] jal_address_calc, jalr_address_calc, jalr_address_calc_last_bit_not_set, branch_imm, brancher_rs1_2_in, brancher_rs2_2_in;
	wire regfile_write, pc_write;
	wire [2:0] regfile_data_source_sel;

	wire should_branch, stall_decode, stall_load_use;
	
	wire[31:0] lui_val3, lui_val4, auipc_val4, auipc_val3;

	wire [2:0] brancher_forward_sel_rs1, brancher_forward_sel_rs2;
	wire [2:0] alu_forward_sel_rs1, alu_forward_sel_rs2;
	wire load_forward_sel_rs1, load_forward_sel_rs2;
	wire dmem_store_data_forward_sel;

	assign lui_val4 = {ins4[31:12], 12'b000000000000};
	// Need this for forwarding to execute stage
	assign lui_val3 = {ins3[31:12], 12'b000000000000};
	assign auipc_val4 = {ins4[31:12], 12'b000000000000} + pc_out4;
	assign auipc_val3 = {ins3[31:12], 12'b000000000000} + pc_out3;

	assign pc_write = clk;

	assign mem_in_data = dmem_store_data_forward_sel ? alu_out4 : rs2_3;

	// figure out if it's load or store
	assign mem_addr = ins3[6:0] == 7'b0100011 ? {ins3[31:25], ins3[11:7]} + rs1_3 : ins3[31:20] + rs1_3;

	assign jal_address_calc = {{11{ins2[31]}}, ins2[31],ins2[19:12],ins2[20],ins2[30:21],1'b0} + pc_out2;
	assign jalr_address_calc_last_bit_not_set = ins2[31:20] + rs1_2;
	assign jalr_address_calc = {jalr_address_calc_last_bit_not_set[31:1], 1'b0};
	assign branch_imm = {19'b0, ins2[31],ins2[7],ins2[30:25],ins2[11:8], 1'b0};
	assign branch_addr =  branch_imm + pc_out2;
	assign pc_next_line = pc_out + 4;

	// pipeline wires
	// Naming schemes works as follows wirename$NUMBER means
	// that the signal in that wire corresponds to an instruction
	// emmited at t - $NUMBER; So pc_out2 is the signal of pc_out
	// 2 instructions ago; i.e. t, t - 1, **t - 2**
	wire [31:0] pc_out1, pc_out2, pc_out3, pc_out4;
	wire [31:0] ins1, ins1_out, ins2, ins3, ins4, actual_ins0;
	wire [31:0] rs1_2, rs1_3, rs2_2, rs2_3;
	wire [31:0] alu_out3, alu_out4;
	wire [31:0] mem_out_data_4;

	// This is kind of a hack (by "kind of" I mean that it works, and that
	// I won't change it for now) to flush the pipeline at IF phase
	// The naming is terrible TODO
	// I need to stall 1 cycle in fetch either if I'm branching or if I'm
	// loading; The loading stall requires a lot more effort because if I'm
	// trying to be smart about it I need more logic plus a way of telling my
	// PC to not update that during that cycle.
	assign actual_ins0 = (ins2[6:0] == 7'b1100011 && should_branch) || stall_load_use ? 32'b00000000000000000000000000010011 : ins;
	assign ins1_out = stall_decode ? 32'b00000000000000000000000000010011 : ins1;
	assign rs1_1_or_regfile_data = load_forward_sel_rs1 ? regfile_data : rs1_1;
	assign rs2_1_or_regfile_data = load_forward_sel_rs2 ? regfile_data : rs2_1;

	pc program_counter(pc_next, clk, pc_write, pc_out);
	mux8 pc_next_address_mux(pc_next_line, jal_address_calc, jalr_address_calc, branch_addr, pc_out, 0, 0, 0, pc_next_sel, pc_next);
	// dmem_out isn't pipelined because load instructions only output the
	// requested data at the next clock cycle anyway
	mux8 regfile_data_source_mux(alu_out4, mem_out_data_formatted_size, pc_out4, lui_val4, auipc_val4, 0, 0, 0, regfile_data_source_sel, regfile_data);
	mux8 alu_rs1_forward_mux(rs1_2, alu_out3, alu_out4, lui_val3, auipc_val3, 0, 0, 0, alu_forward_sel_rs1, alu_rs1_in);
	mux8 alu_rs2_forward_mux(rs2_2, {{20{ins2[31]}}, ins2[31:20]}, alu_out3, alu_out4, lui_val3, auipc_val3, 0, 0, alu_forward_sel_rs2, alu_rs2_in);
	mux8 brancher_rs1_forward_mux(rs1_2, alu_out3, alu_out4, mem_out_data_formatted_size, lui_val3, auipc_val3, 0, 0, brancher_forward_sel_rs1, brancher_rs1_2_in);
	mux8 brancher_rs2_forward_mux(rs2_2, alu_out3, alu_out4, mem_out_data_formatted_size, lui_val3, auipc_val3, 0, 0, brancher_forward_sel_rs2, brancher_rs2_2_in);
	brancher branch_condition_checker(ins2[6:0], brancher_rs1_2_in, brancher_rs2_2_in, ins2[14:12], should_branch);
	control core_control_unit(ins[6:0], ins1[6:0], ins2[6:0], ins3[6:0], ins4[6:0], ins4[11:7], ins3[11:7], ins2[19:15], ins2[24:20], ins3[24:20], ins1[19:15], ins1[24:20], should_branch, stall_load_use, load_forward_sel_rs1, load_forward_sel_rs2, pc_next_sel, regfile_data_source_sel, mem_w, regfile_write, alu_forward_sel_rs1, alu_forward_sel_rs2, brancher_forward_sel_rs1, brancher_forward_sel_rs2, stall_decode, dmem_store_data_forward_sel);
	load_staller core_load_staller(ins1, ins, stall_load_use);
	insmem imem(pc_out, ins);
	regfile registers(clk, ins1[19:15], ins1[24:20], ins4[11:7], regfile_write, regfile_data, rs1_1, rs2_1);
	alu alunit(alu_rs1_in, alu_rs2_in, {ins2[31:25],ins2[14:12]}, alu_out);
	pipeline_register reg_pc_out1(clk, pc_out, 1'b0, pc_out1);
	pipeline_register reg_pc_out2(clk, pc_out1, 1'b0, pc_out2);
	pipeline_register reg_pc_out3(clk, pc_out2, 1'b0, pc_out3);
	pipeline_register reg_pc_out4(clk, pc_out3, 1'b0, pc_out4);
	pipeline_register reg_ins1(clk, actual_ins0, 1'b0,  ins1); // If should branch or jumps, must clear the results of reg1 (i.e. stall)
	pipeline_register reg_ins2(clk, ins1_out, 1'b0, ins2);
	pipeline_register reg_ins3(clk, ins2, 1'b0, ins3);
	pipeline_register reg_ins4(clk, ins3, 1'b0, ins4);
	pipeline_register reg_rs1_2(clk, rs1_1_or_regfile_data, 1'b0, rs1_2);
	pipeline_register reg_rs1_3(clk, rs1_2, 1'b0, rs1_3);
	pipeline_register reg_rs2_2(clk, rs2_1_or_regfile_data, 1'b0, rs2_2);
	pipeline_register reg_rs2_3(clk, rs2_2, 1'b0, rs2_3);
	pipeline_register reg_alu_out3(clk, alu_out, 1'b0, alu_out3);
	pipeline_register reg_alu_out4(clk, alu_out3, 1'b0, alu_out4);
	pipeline_register reg_dmem_out4(clk, mem_out_data_formatted_size, 1'b0, mem_out_data_4);

endmodule
