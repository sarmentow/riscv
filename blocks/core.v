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
	wire [31:0] pc_next, pc_out, ins;

	wire regfile_write, dmem_write, pc_write;

	// Write logic is temporary
	assign regfile_write = (ins[6:0] == 7'b0110011 ? 1'b1 : 
	                ins[6:0] == 7'b0010011 ? 1'b1 : 
		        ins[6:0] == 7'b0000011 ? 1'b1 : 0);

	assign dmem_write = (ins[6:0] == 7'b0100011 ? 1 : 0);

	assign pc_write = clk;
	assign dmem_data = {ins[31:25], ins[11:7]};

	assign rs2_or_imm = ins[5] ? rs2 : ins[31:20];
	assign dmem_address_calc = ins[31:20] + rs1;
	assign regfile_data = ins[6:0] == 7'b0000011 ? dmem_sel_data_out : alu_out;
	assign pc_next = pc_out + 4;

	
	pc program_counter(pc_next, clk, pc_write, pc_out);
	insmem imem(pc_out, ins);
	regfile registers(clk, ins[19:15], ins[24:20], ins[11:7], regfile_write, regfile_data, rs1, rs2);
	alu alunit(rs1, rs2_or_imm, {ins[31:25],ins[14:12]}, alu_out);
	datamem dmem(clk, dmem_address_calc, dmem_data, ins[14:12], dmem_write, dmem_out);
	datamemSizeSel datamem_size_sel(dmem_out, ins[14:12], dmem_sel_data_out);

endmodule
