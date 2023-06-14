`timescale 1ns/100ps

`include "ch0re_types.sv"
`include "debug_prints.sv"

module tb_idecoder();

	instruction_t instr = new();

	idecoder_intf idec_intf();
	idecoder dut(idec_intf);

	initial begin

		gen_check_all_instructions();
		$finish();

	end

	task check_decoded_instr();

		unique case (instr.get_fmt())

			IFORMAT_R: begin

				R_FORMAT: assert(
					!idec_intf.o_illegal_instr &&
					idec_intf.o_rf_raddr1 == instr.get_rs1() &&
					idec_intf.o_rf_raddr2 == instr.get_rs2() &&
					idec_intf.o_rf_waddr == instr.get_rd() &&
					idec_intf.o_instr_format == IFORMAT_R &&
					idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_REG &&
					idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_REG
				) else begin
					print_dut_output();
					$display();
					instr.print();
					$fatal();
				end

			end

			IFORMAT_I: begin

				I_FORMAT: assert(
					!idec_intf.o_illegal_instr &&
					idec_intf.o_rf_raddr1 == instr.get_rs1() &&
					idec_intf.o_rf_waddr == instr.get_rd() &&
					idec_intf.o_instr_format == IFORMAT_I &&
					idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_REG &&
					idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM
				) else begin
					print_dut_output();
					$display();
					instr.print();
					$fatal();
				end

			end

			IFORMAT_S: begin

				S_FORMAT: assert(
					!idec_intf.o_illegal_instr &&
					idec_intf.o_rf_raddr1 == instr.get_rs1() &&
					idec_intf.o_rf_raddr2 == instr.get_rs2() &&
					idec_intf.o_instr_format == IFORMAT_S &&
					idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_REG &&
					idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM
				) else begin
					print_dut_output();
					$display();
					instr.print();
					$fatal();
				end

			end


			IFORMAT_B: begin

				B_FORMAT: assert(
					!idec_intf.o_illegal_instr &&
					idec_intf.o_rf_raddr1 == instr.get_rs1() &&
					idec_intf.o_rf_raddr2 == instr.get_rs2() &&
					idec_intf.o_instr_format == IFORMAT_B &&
					idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_REG &&
					idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_REG
				) else begin
					print_dut_output();
					$display();
					instr.print();
					$fatal();
				end

			end


			IFORMAT_J: begin

				J_FORMAT: assert(
					!idec_intf.o_illegal_instr &&
					idec_intf.o_rf_waddr == instr.get_rd() &&
					idec_intf.o_instr_format == IFORMAT_J &&
					idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_PC &&
					idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM
				) else begin
					print_dut_output();
					$display();
					instr.print();
					$fatal();
				end

			end


			IFORMAT_U: begin

				U_FORMAT: assert(
					!idec_intf.o_illegal_instr &&
					idec_intf.o_rf_waddr == instr.get_rd() &&
					idec_intf.o_instr_format == IFORMAT_U
				) else begin
					print_dut_output();
					$display();
					instr.print();
					$fatal();
				end

				unique case (instr.get_op())

					"lui": begin

						U_FORMAT_LUI: assert(
							idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_IMM &&  // zero
							idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM     // idec_intf.imm
						) else begin
							print_dut_output();
							$display();
							instr.print();
							$fatal();
						end

					end

					"auipc": begin

						U_FORMAT_AUIPC: assert(
							idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_PC &&
							idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM
						) else begin
							print_dut_output();
							$display();
							instr.print();
							$fatal();
						end

					end

					default: begin
						assert(1'b0) else $fatal();
					end

				endcase

			end

			default: begin

				ILLEGAL_INSTRUCTION: assert(
					idec_intf.o_illegal_instr
				) else begin
					print_dut_output();
					$display();
					instr.print();
					$fatal();
				end

			end

		endcase

		`DBP_PRINT_CURR();
		$write("'%0s' was decoded successfully\n", instr.get_op());

	endtask : check_decoded_instr

	task gen_check_all_instructions();  // Under Construction

		ITT_LOOP: foreach (instruction_t::itt[i]) begin

			`DBP_PRINT_CURR();
			$write("generating '%0s'\n", i);

			instr.gen(i, REG_X2_SP, REG_X1_RA, 3, idec_intf.i_instr);
			#5;
			check_decoded_instr();
			$display();

		end

		`DBP_PRINT_CURR();
		$write({`DBP_SUCCESS, "\n"});

	endtask : gen_check_all_instructions
 
	task print_dut_output();

		$display("idec_intf.o_illegal_instr = 1'b%0b", idec_intf.o_illegal_instr);
		$display("idec_intf.o_rf_raddr1     = 5'h%0x", idec_intf.o_rf_raddr1);
		$display("idec_intf.o_rf_raddr2     = 5'h%0x", idec_intf.o_rf_raddr2);
		$display("idec_intf.o_rf_waddr      = 5'h%0x", idec_intf.o_rf_waddr);

		$display("idec_intf.o_instr_format  = %s (h%0x)", idec_intf.o_instr_format.name(), idec_intf.o_instr_format);
		$display("idec_intf.o_alu_op        = %s (h%0x)", idec_intf.o_alu_op.name(), idec_intf.o_alu_op);
		$display("idec_intf.imm           = 'h%0x", idec_intf.o_imm);
		$display("idec_intf.o_alu_mux1_sel  = %s ('h%0x)", idec_intf.o_alu_mux1_sel.name(), idec_intf.o_alu_mux1_sel);
		$display("idec_intf.o_alu_mux2_sel  = %s ('h%0x)", idec_intf.o_alu_mux2_sel.name(), idec_intf.o_alu_mux2_sel);

	endtask : print_dut_output

endmodule : tb_idecoder

