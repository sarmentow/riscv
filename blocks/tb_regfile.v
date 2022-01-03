`include "regfile.v"
module regfile_tb;
	reg clk, en_w;
	reg[4:0] rs1, rs2, rd;
	reg[31:0] val_w;
	wire[31:0] rs1_out, rs2_out;

	initial begin
		$monitor("rs1 = %d\n rs2 = %d\n rd = %d\n write_enable = %d\n write_value = %d\n rs1_out = %d\n rs2_out = %d\n\n",
		rs1, rs2, rd, en_w, val_w, rs1_out, rs2_out);
		#5 rs1 =0; rs2=0; rd=0; val_w=0; en_w=0;
		#10 rs1 =1; rs2=0; rd=1; val_w=24; en_w=1;
		#10;
		#5 rs1=1; rs2=0; rd=0; val_w=0; en_w=0;
	end

	always begin
		#5 clk = !clk;
	end

	regfile regfile_t(rs1, rs2, rd, val_w, en_w, clk, rs1_out, rs2_out);
	
endmodule
