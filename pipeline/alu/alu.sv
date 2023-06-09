`include "ch0re_types.sv"

module alu #(
	parameter WIDTH = 64
) (
	input alu_op_e i_op,

	input logic [WIDTH-1:0] i_s1,
	input logic [WIDTH-1:0] i_s2,

	output logic o_overflow,

	output logic [WIDTH-1:0] o_res
);

	/* ADDER */

	logic [WIDTH-1:0] s2_2s_compl;
	logic [WIDTH-1:0] adder_result;

	always_comb begin : adder

		s2_2s_compl = (i_op == ALU_SUB) ? ~i_s2 + 'h1 : i_s2; // or branch, slt
		adder_result = i_s1 + s2_2s_compl;

	end : adder

	/* LOGIC */

	always_comb begin : logic

		unique case (i_op)

			ALU_OR: logic_result = i_s1 | i_s2;
			ALU_XOR: logic_result = i_s1 ^ i_s2
			ALU_AND: logic_result = i_s1 & i_s2;

			default:;

		endcase

	end : logic

	always_comb begin : results

		unique case (i_op)

			ALU_EQ, ALU_NE,
			ALU_ADD, ALU_SUB,
			ALU_LT, ALU_GE,
			ALU_LTU, ALU_GEU,
			ALU_SLT, ALU_SLTU: begin
				//
			end

			ALU_OR, ALU_XOR, ALU_AND: o_res = logic_result;

			default:

		endcase

	end : results

endmodule: alu

