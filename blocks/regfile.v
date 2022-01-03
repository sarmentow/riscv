module regfile(rs1, rs2, rd, write_val, write_enable, clk, rs1_out, rs2_out);
	input write_enable, clk;
	input [4:0] rs1, rs2, rd;

	input [31:0] write_val;
	reg [31:0] registers[31:0];
	
	output [31:0] rs1_out, rs2_out;

	integer i;
	
	initial begin
		for (i = 0; i < 32; i = i + 1) begin
			registers[i] = 0;
		end
	end

	assign rs1_out = registers[rs1] < 32 && registers[rs1] >= 0 ? registers[rs1] : rs1_out;
	assign rs2_out = registers[rs2] < 32 && registers[rs2] >= 0 ? registers[rs2] : rs2_out;

	always @ (posedge clk) begin
		case (write_enable) 
			0: begin end
			1: begin
				registers[rd] = write_val;	
			end
		endcase
	end

endmodule
