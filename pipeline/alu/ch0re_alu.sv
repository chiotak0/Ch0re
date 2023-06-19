`include "ch0re_types.sv"

interface ch0re_alu_intf();

	alu_op_e i_op;

	logic [63:0] i_s1;
	logic [63:0] i_s2;

	logic o_flag_zero;
	logic o_flag_less;

	logic [63:0] o_res;

endinterface: ch0re_alu_intf

module ch0re_alu(ch0re_alu_intf intf);


	/* ADDER */

	logic [63:0] new_s2;
	logic [64:0] adder_result;

	always_comb begin: sign_handling

		/* handing signess */

		unique case (intf.i_op)

			ALU_LT,
			ALU_GE,
			ALU_EQ,
			ALU_NE,
			ALU_SLT,
			ALU_SUB, ALU_LTU,
			ALU_GEU, ALU_SLTU: new_s2 = ~intf.i_s2 + 64'h1;

			default: new_s2 = intf.i_s2;

		endcase

	end: sign_handling

	assign adder_result = intf.i_s1 + new_s2;
	assign intf.o_flag_zero = (!adder_result[63:0]) ? 1'b1 : 1'b0;

	always_comb begin: results

		unique case (intf.i_op)

			ALU_GEU, ALU_SLTU, ALU_LTU: intf.o_flag_less = intf.i_s1 < intf.i_s2;
			default: intf.o_flag_less = adder_result[63];

		endcase

		unique case (intf.i_op)

			ALU_SLT, ALU_SLTU: intf.o_res = intf.o_flag_less;

			ALU_EQ,  ALU_NE,
			ALU_LT,  ALU_GE,
			ALU_LTU, ALU_GEU,
			ALU_ADD, ALU_SUB: intf.o_res = adder_result[63:0];

			ALU_OR:  intf.o_res = intf.i_s1 | intf.i_s2;
			ALU_XOR: intf.o_res = intf.i_s1 ^ intf.i_s2;
			ALU_AND: intf.o_res = intf.i_s1 & intf.i_s2;

			ALU_SLL: intf.o_res = intf.i_s1 << intf.i_s2[5:0];
			ALU_SRL: intf.o_res = intf.i_s1 >> intf.i_s2[5:0];
			ALU_SRA: intf.o_res = signed'(intf.i_s1) >>> intf.i_s2[5:0];  // part-select is unsigned........

			default:;

		endcase

	end: results

endmodule: ch0re_alu

