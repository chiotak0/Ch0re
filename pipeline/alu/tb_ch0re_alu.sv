`timescale 1ns/100ps

`include "ch0re_types.sv"
`include "debug_prints.sv"

module tb_ch0re_alu();

	ch0re_alu_op_t alu_op = new();

	ch0re_alu_intf intf();
	ch0re_alu dut(intf);

	initial begin

		gen_verify_all_alu_ops();
		gen_rand_alu_ops(250);
		$finish();
	end

	task gen_rand_alu_ops(int ceil);

		for (int i = 0; i < ceil; ++i) begin

			alu_op.gen_rand();

			intf.i_op = alu_op.get_op();
			intf.i_s1 = alu_op.get_src1();
			intf.i_s2 = alu_op.get_src2();

			`DBP_PRINT_CURR();
			$write("generated '%0s'\n", intf.i_op.name());

			#5;

			verify_alu_result();

			`DBP_PRINT_CURR();
			$write("'%0s' has correct results\n", intf.i_op.name());

		end

		`DBP_PRINT_CURR();
		$write({`DBP_SUCCESS, "\n"});

	endtask

	task gen_verify_all_alu_ops();

		for (int op = ALU_EQ; op <= ALU_SLTU; ++op) begin

			alu_op.gen(alu_op_e'(op));

			intf.i_op = alu_op_e'(op);
			intf.i_s1 = alu_op.get_src1();
			intf.i_s2 = alu_op.get_src2();

			`DBP_PRINT_CURR();
			$write("generated '%0s'\n", intf.i_op.name());

			#5;

			verify_alu_result();

			`DBP_PRINT_CURR();
			$write("'%0s' has correct results\n", intf.i_op.name());

		end

		`DBP_PRINT_CURR();
		$write({`DBP_SUCCESS, "\n"});

	endtask

	task __fail();


	endtask;

	task verify_alu_result();

		assert(
			alu_op.get_op() == intf.i_op
		)
		else begin

			$display();
			alu_op.print();
			print_dut();
			$fatal();

		end

		unique case (alu_op.get_op())

			ALU_SLT, ALU_SLTU,
			ALU_ADD, ALU_SUB,
			ALU_OR,  ALU_XOR,
			ALU_AND, ALU_SLL,
			ALU_SRL, ALU_SRA: begin

				assert(
					alu_op.get_res() == intf.o_res
				)
				else begin

					$display();
					alu_op.print();
					print_dut();
					$fatal();

				end

			end

			ALU_EQ,  ALU_NE,
			ALU_LT,  ALU_GE,
			ALU_LTU, ALU_GEU: begin

				assert(
					alu_op.get_flag_lt() == intf.o_flag_less &&
					alu_op.get_flag_zero() == intf.o_flag_zero
				)
				else begin

					$display();
					alu_op.print();
					print_dut();
					$fatal();

				end

			end

			default:;

		endcase

	endtask

	task print_dut();

		$display();
		$display("-----------------------------");
		$display("intf.i_op  = %0s", intf.i_op.name());
		$display("intf.i_s1  = %0d (h%0h)", signed'(intf.i_s1), intf.i_s1);
		$display("intf.i_s2  = %0d (h%0h)", signed'(intf.i_s2), intf.i_s2);
		$display("intf.o_res = %0d (h%0h)", signed'(intf.o_res), intf.o_res);
		$display("-----------------------------");
		$display("intf.o_flag_zero = 1'b%1b", intf.o_flag_zero);
		$display("intf.o_flag_less   = 1'b%1b", intf.o_flag_less);
		$display("-----------------------------");

	endtask

endmodule: tb_ch0re_alu

