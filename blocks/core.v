`include "alu.v"
`include "datamem.v"
`include "regfile.v"

module core(clk, ins);
	input[31:0] ins;
	input clk;
	// I need better names
	wire [31:0] alu_out, rs1, rs2_or_imm, rs2, regfile_data_write, dmem_out, dmem_address_calc, dmem_sel_data_out, dmem_data_write;
	wire write;

	// Write logic is temporary
	assign write = (ins[6:0] == 7'b0110011 ? 1'b1 : 
	                ins[6:0] == 7'b0010011 ? 1'b1 : 
		        ins[6:0] == 7'b0000011 ? 1'b1 : 0);

	assign rs2_or_imm = ins[5] ? rs2 : ins[31:20];
	assign dmem_address_calc = ins[31:20] + rs1;
	assign regfile_data_write = ins[6:0] == 7'b0000011 ? dmem_sel_data_out : alu_out;

	regfile registers(clk, ins[19:15], ins[24:20], ins[11:7], write, regfile_data_write, rs1, rs2);
	alu alunit(rs1, rs2_or_imm, {ins[31:25],ins[14:12]}, alu_out);
	datamem dmem(clk, dmem_address_calc, dmem_data_write, dmem_write, dmem_out);
	datamemSizeSel datamem_size_sel(dmem_out, ins[14:12], dmem_sel_data_out);

endmodule
