// `include "ch0re_types.sv"

interface ch0re_alu_intf();

	alu_op_e i_op;
	data_type_e i_i64;

	logic [63:0] i_s1;
	logic [63:0] i_s2;

	logic o_flag_zero;
	logic o_flag_less;

	logic [63:0] o_res;

	/* modport slave(
		input i_op, i_i64, i_s1, i_s2,
		output o_flag_less, o_flag_zero, o_res
	);

	modport master(
		output i_op, i_i64, i_s1, i_s2,
		input o_flag_less, o_flag_zero, o_res
	); */

endinterface

module ch0re_alu(ch0re_alu_intf intf);


	/* ADDER */

	logic [63:0] new_s2;
	logic [63:0] adder_result;

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
	end


	logic [63:0] tmp_res;

	assign adder_result = intf.i_s1 + new_s2;
	assign intf.o_flag_zero = (adder_result == 'h0) ? 1'b1 : 1'b0;

	always_comb begin: results

		unique case (intf.i_op)

			ALU_GEU, ALU_SLTU, ALU_LTU: intf.o_flag_less = intf.i_s1 < intf.i_s2;
			default: intf.o_flag_less = adder_result[63];
		endcase

		unique case (intf.i_op)

			ALU_SLT, ALU_SLTU: tmp_res = (intf.o_flag_less) ? 1'b1 : 1'b0;

			ALU_EQ,  ALU_NE,
			ALU_LT,  ALU_GE,
			ALU_LTU, ALU_GEU,
			ALU_ADD, ALU_SUB: tmp_res = adder_result;

			ALU_OR:  tmp_res = intf.i_s1 | intf.i_s2;
			ALU_XOR: tmp_res = intf.i_s1 ^ intf.i_s2;
			ALU_AND: tmp_res = intf.i_s1 & intf.i_s2;

			ALU_SLL: tmp_res = intf.i_s1 << intf.i_s2[5:0];
			ALU_SRL: tmp_res = intf.i_s1 >> intf.i_s2[5:0];
			ALU_SRA: tmp_res = $signed(intf.i_s1) >>> intf.i_s2[5:0];

			default:;
		endcase

		if (!intf.i_i64) begin
			intf.o_res = tmp_res;
		end
		else begin
			intf.o_res = {{33{tmp_res[31]}}, tmp_res[30:0]};
		end
	end

endmodule

