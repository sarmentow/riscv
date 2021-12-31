module mux(in_0, in_1, sel, out);
	input [31:0]in_0, in_1;
	input sel;
	output [31:0]out;

	assign out = sel ? in_1 : in_0;
endmodule

module mux16(in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7, in_8, in_9, 
			in_10, in_11, in_12, in_13, in_14, in_15, 
			sel, out);

	input [31:0]in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7, in_8, in_9, 
	in_10, in_11, in_12, in_13, in_14, in_15;
	input [3:0]sel;
	output [31:0] out;
	wire [31:0]imm_00, imm_01, imm_02, imm_03, imm_04, imm_05, imm_06, imm_07;
	wire [31:0]imm_10, imm_11, imm_12, imm_13;
	wire [31:0]imm_20, imm_21;

	assign imm_00 = sel[0] ? in_1 : in_0;
	assign imm_01 = sel[0] ? in_3 : in_2;
	assign imm_02 = sel[0] ? in_5 : in_4;
	assign imm_03 = sel[0] ? in_7 : in_6;
	assign imm_04 = sel[0] ? in_9 : in_8;
	assign imm_05 = sel[0] ? in_11 : in_10;
	assign imm_06 = sel[0] ? in_13 : in_12;
	assign imm_07 = sel[0] ? in_15 : in_14;

	assign imm_10 = sel[1] ? imm_01 : imm_00;
	assign imm_11 = sel[1] ? imm_03 : imm_02;
	assign imm_12 = sel[1] ? imm_05 : imm_04;
	assign imm_13 = sel[1] ? imm_07 : imm_06;

	assign imm_20 = sel[2] ? imm_11 : imm_10;
	assign imm_21 = sel[2] ? imm_13 : imm_12;

	assign out = sel[3] ? imm_21 : imm_20;

		
endmodule

