module load_staller(ins1, ins0, load_use_stall);
	input [31:0] ins1, ins0;
	output load_use_stall;
// if ins1 is a load: check for hazards    // jalr/load/i-type rs1 == load1 rd//  ops rs1/rs2 == load rd
	assign load_use_stall = ins1[6:0] == 7'b0000011 && 
		                    ((ins1[11:7] == ins0[19:15] && (ins0[6:0] == 7'b1100111 || ins0[6:0] == 7'b0000011 || ins0[6:0] == 7'b0010011)) || 
		                    ((ins1[11:7] == ins0[19:15] || ins1[11:7] == ins0[24:20]) && (ins0[6:0] == 7'b1100011 || ins0[6:0] == 7'b0110011 || ins0[6:0] == 7'b0100011))) ? 1 : 0; 
endmodule
