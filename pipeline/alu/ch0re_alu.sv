`include "ch0re_types.sv"

interface ch0re_alu_intf #(
	parameter WIDTH = 64
) ();

	alu_op_e i_op;

	logic [WIDTH-1:0] i_s1;
	logic [WIDTH-1:0] i_s2;

	logic o_overflow;

	logic [WIDTH-1:0] o_res;
	logic o_cond_hit;

endinterface : ch0re_alu_intf

module ch0re_alu(ch0re_alu_intf intf);

	logic is_signed;

	always_comb begin

		unique case (intf.i_op)

			ALU_LT,
			ALU_GE,
			ALU_SLT: is_signed = 1'b1;

		endcase

	end

	/* ADDER */

	logic [WIDTH-1:0] new_s2;
	logic [WIDTH:0] adder_result;

	always_comb begin : adder

		unique case (intf.i_op)

			ALU_SUB, ALU_LT,
			ALU_LGE, ALU_LTU,
			ALU_GEU, ALU_EQ,
			ALU_NE, ALU_SLT,
			ALU_SLTU: new_s2 = ~intf.i_s2 + 64'h1;

			default: new_s2 = intf.i_s2;

		endcase

		adder_result = intf.i_s1 + new_s2;
		intf.o_overflow = adder_result[WIDTH];

	end : adder

	/* LOGIC */

	logic [WIDTH-1:0] logic_result;

	always_comb begin : logic

		unique case (intf.i_op)

			ALU_OR: logic_result = intf.i_s1 | intf.i_s2;
			ALU_XOR: logic_result = intf.i_s1 ^ intf.i_s2
			ALU_AND: logic_result = intf.i_s1 & intf.i_s2;

			default:;

		endcase

	end : logic

	/* SHIFTS */

	logic [WIDTH-1:0] shift_result;

	always_comb begin : shifts

		unique case (intf.i_op)

			ALU_SLL: shift_result = intf.i_s1 << intf.i_s2[5:0];
			ALU_SRL: shift_result = intf.i_s1 >> intf.i_s2[5:0];
			ALU_SRA: shift_result = intf.i_s1 >>> intf.i_s2[5:0];

			default:;

		endcase

	end : shifts

	/* RESULTS */

	always_comb begin : results

		unique case (intf.i_op)

			ALU_EQ, ALU_NE,
			ALU_LT, ALU_GE,
			ALU_LTU, ALU_GEU,
			ALU_SLT, ALU_SLTU: begin
				//
			end

			ALU_ADD, ALU_SUB: intf.o_res = adder_result;
			ALU_OR, ALU_XOR, ALU_AND: intf.o_res = logic_result;
			ALU_SLL, ALU_SRL, ALU_SRA: intf.o_res = shift_result;

			default:

		endcase

	end : results

endmodule: ch0re_alu

