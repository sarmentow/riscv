// outputs 1 if branch condition holds
// 0 otherwise
module brancher(opc, rs1, rs2, funct3, out);
	input [6:0] opc;
	input [31:0] rs1, rs2;
	input [2:0] funct3;
	output out;

//	wire [31:0] sub; -> this is part of my schematic because in my head the
//	easiest way of doing this comparison is to subtract the numbers and see if
//	the result is zero but I can just do it in one go;
	wire lt, eq, ult;

	assign lt = $signed(rs1) < $signed(rs2);
	assign eq = rs1 == rs2;
	assign ult = $unsigned(rs1) < $unsigned(rs2);

	assign out = funct3 == 3'b000 && opc == 7'b1100011 ? eq :
		         funct3 == 3'b001 && opc == 7'b1100011 ? ~eq :
				 funct3 == 3'b100 && opc == 7'b1100011 ? lt :
				 funct3 == 3'b101 && opc == 7'b1100011 ? ~lt :
				 funct3 == 3'b110 && opc == 7'b1100011 ? ult :
				 funct3 == 3'b111 && opc == 7'b1100011 ? ~ult : 0;
	
endmodule
