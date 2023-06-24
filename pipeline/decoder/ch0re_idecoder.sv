`include "ch0re_types.sv"

interface ch0re_idecoder_intf(
	input logic clk,
	input logic rst_n
);

	logic [31:0] i_instr;

	/* Bypassing */

	logic [4:0] i_ex_rd;
	iformat_e i_ex_iformat;
	lsu_op_e i_ex_lsu_op;
	logic i_ex_wen;

	logic [4:0] i_mem_rd;
	iformat_e i_mem_iformat;
	logic i_mem_wen;

	/* Generic Control */

	logic o_illegal_instr;
	logic o_wen;

	/* to RegFile */

	logic [4:0] o_rf_raddr1;
	logic [4:0] o_rf_raddr2;
	logic [4:0] o_rf_waddr;

	/* to ALU */

	logic [63:0] o_imm;
	iformat_e o_instr_format;
	alu_op_e o_alu_op;

	alu_mux1_sel_e o_alu_mux1_sel;
	alu_mux2_sel_e o_alu_mux2_sel;

	/* to LSU */

	data_type_e o_data_type;
	lsu_op_e o_lsu_op;

	/* to Pipeline Control */

	logic o_pl_stall;

endinterface: ch0re_idecoder_intf


module ch0re_idecoder(ch0re_idecoder_intf intf);

	logic [31:0] instr;
	logic dis_ninstr;
	opcode_e opcode;

	logic DISNIR;  // disable next instruction register

	/** Register Handling **/

	assign intf.o_rf_raddr1 = instr[19:15];
	assign intf.o_rf_raddr2 = instr[24:20];
	assign intf.o_rf_waddr  = instr[11:7];

	assign instr  = intf.i_instr;
	assign opcode = opcode_e'(instr[6:2]);


	always_ff @(posedge intf.clk, negedge intf.rst_n) begin: dis_ninstr_after_jump

		if (!intf.rst_n) begin
			DISNIR <= 1'b0;
		end
		else  begin
			DISNIR <= dis_ninstr;
		end

	end: dis_ninstr_after_jump


	always_comb begin: decoding

		/* Only 32-bit instructions supported! */

		if (instr[1:0] != 2'b11) begin

			intf.o_illegal_instr = 1'b1;

			intf.o_instr_format = IFORMAT_NONE;
			intf.o_alu_op = ALU_SLL;
			intf.o_lsu_op = LSU_LOAD;
			intf.o_imm = 64'h0;
			intf.o_wen = 1'b0;
			dis_ninstr = 1'b1;
		end
		else begin

			intf.o_illegal_instr = 1'b0;
			intf.o_lsu_op = LSU_NONE;
			intf.o_data_type = DTYPE_DOUBLE;
			dis_ninstr = 1'b0;

			if (!DISNIR) begin
				intf.o_wen = 1'b1;
			end
			else begin
				intf.o_wen = 1'b0;
			end

			unique case (opcode)

				OPCODE_OP32: begin: op_op32  // "w"

					/* rd = (rs1[31:0] op rs2[31:0])[31:0] */

					intf.o_instr_format = IFORMAT_R;

					unique case (instr[14:12])

						3'h0: begin
							if (instr[31:25] == 7'h0) begin
								intf.o_alu_op = ALU_ADD;
							end
							else if (instr[31:25] == 7'h20) begin
								intf.o_alu_op = ALU_SUB;
							end
							else begin
								intf.o_illegal_instr = 1'b1;
								intf.o_instr_format = IFORMAT_NONE;
								intf.o_wen = 1'b0;
							end
						end

						3'h5: begin
							if (instr[31:25] == 7'h0) begin
								intf.o_alu_op = ALU_SRL;
							end
							else if (instr[31:25] == 7'h20) begin
								intf.o_alu_op = ALU_SRA;
							end
							else begin
								intf.o_illegal_instr = 1'b1;
								intf.o_instr_format = IFORMAT_NONE;
								intf.o_wen = 1'b0;
							end
						end

						3'h1: intf.o_alu_op = ALU_SLL;

						default: begin
							intf.o_illegal_instr = 1'b1;
							intf.o_instr_format = IFORMAT_NONE;
							intf.o_wen = 1'b0;
						end

					endcase

				end: op_op32

				OPCODE_OP_IMM32: begin: op_op_imm32 // "w"

					/* rd = (rs1 op imm)[31:0] */

					intf.o_instr_format = IFORMAT_I;
					intf.o_imm = {{59{1'b0}}, instr[24:20]};

					unique case (instr[14:12])

						3'h1: begin
							if (instr[31:25] == 7'h0) begin
								intf.o_alu_op = ALU_SLL;
							end
							else begin
								intf.o_illegal_instr = 1'b1;
								intf.o_instr_format = IFORMAT_NONE;
								intf.o_wen = 1'b0;
								intf.o_alu_op = ALU_SLTU;
							end
						end

						3'h5: begin
							if (instr[31:25] == 7'h0) begin
								intf.o_alu_op = ALU_SRL;
							end
							else if (instr[31:25] == 7'h20) begin
								intf.o_alu_op = ALU_SRA;
							end
							else begin
								intf.o_illegal_instr = 1'b1;
								intf.o_instr_format = IFORMAT_NONE;
								intf.o_wen = 1'b0;
								intf.o_alu_op = ALU_SLTU;
							end
						end

						3'h0: intf.o_alu_op = ALU_ADD;

						default: begin
							intf.o_illegal_instr = 1'b1;
							intf.o_instr_format = IFORMAT_NONE;
							intf.o_wen = 1'b0;
							intf.o_alu_op = ALU_SLTU;
						end

					endcase

				end: op_op_imm32

				OPCODE_OP: begin: op_op

					/* rd = rs1 op rs2 */

					intf.o_instr_format = IFORMAT_R;

					unique case (instr[14:12])

						3'h0: begin
							if (instr[31:25] == 7'h0) begin
								intf.o_alu_op = ALU_ADD;
							end
							else if (instr[31:25] == 7'h20) begin
								intf.o_alu_op = ALU_SUB;
							end
							else begin
								intf.o_illegal_instr = 1'b1;
								intf.o_instr_format = IFORMAT_NONE;
								intf.o_wen = 1'b0;
								intf.o_alu_op = ALU_SLTU;
							end
						end

						3'h5: begin
							if (instr[31:25] == 7'h0) begin
								intf.o_alu_op = ALU_SRL;
							end
							else if (instr[31:25] == 7'h20) begin
								intf.o_alu_op = ALU_SRA;
							end
							else begin
								intf.o_illegal_instr = 1'b1;
								intf.o_instr_format = IFORMAT_NONE;
								intf.o_wen = 1'b0;
								intf.o_alu_op = ALU_SLTU;
							end
						end

						3'h1: intf.o_alu_op = ALU_SLL;
						3'h2: intf.o_alu_op = ALU_SLT;
						3'h3: intf.o_alu_op = ALU_SLTU;
						3'h4: intf.o_alu_op = ALU_XOR;
						3'h6: intf.o_alu_op = ALU_OR;
						3'h7: intf.o_alu_op = ALU_AND;

						default:;

					endcase

				end: op_op

				OPCODE_OP_IMM: begin: op_imm

					/* rd = rs1 op imm */

					intf.o_instr_format = IFORMAT_I;
					intf.o_imm = {{52{instr[31]}}, instr[31:20]};

					unique case (instr[14:12])

						3'h1: begin
							if (instr[31:26] == 6'h0) begin
								intf.o_alu_op = ALU_SLL;
							end
							else begin
								intf.o_illegal_instr = 1'b1;
								intf.o_instr_format = IFORMAT_NONE;
								intf.o_wen = 1'b0;
								intf.o_alu_op = ALU_SLTU;
							end

							intf.o_imm = {{58{1'b0}}, instr[25:20]};
						end

						3'h5: begin
							intf.o_imm = {{58{1'b0}}, instr[25:20]};

							if (instr[31:26] == 6'h0) begin
								intf.o_alu_op = ALU_SRL;
							end
							else if (instr[31:26] == 6'h10) begin
								intf.o_alu_op = ALU_SRA;
							end
							else begin
								intf.o_illegal_instr = 1'b1;
								intf.o_instr_format = IFORMAT_NONE;
								intf.o_wen = 1'b0;
								intf.o_alu_op = ALU_SLTU;
							end
						end

						3'h0: intf.o_alu_op = ALU_ADD;
						3'h2: intf.o_alu_op = ALU_SLT;
						3'h3: intf.o_alu_op = ALU_SLTU;
						3'h4: intf.o_alu_op = ALU_XOR;
						3'h6: intf.o_alu_op = ALU_OR;
						3'h7: intf.o_alu_op = ALU_AND;

						default:;

					endcase

				end: op_imm

				OPCODE_LOAD: begin: op_load

					/* rd = Mem[rs1 + imm] */

					intf.o_instr_format = IFORMAT_I;
					intf.o_data_type = data_type_e'(instr[14:12]);
					intf.o_alu_op = ALU_ADD;
					intf.o_lsu_op = LSU_LOAD;

					intf.o_imm = {{{52{instr[31]}}}, instr[31:20]};

					if (instr[14:12] == 3'h7) begin
						intf.o_illegal_instr = 1'b1;
						intf.o_instr_format = IFORMAT_NONE;
						intf.o_wen = 1'b0;
					end

				end: op_load

				OPCODE_STORE: begin: op_store

					/* Mem[rs1 + imm] = rs2 */

					intf.o_instr_format = IFORMAT_S;
					intf.o_data_type = data_type_e'(instr[14:12]);
					intf.o_alu_op = ALU_ADD;
					intf.o_lsu_op = LSU_STORE;

					intf.o_imm = {{{52{instr[31]}}}, instr[31:25], instr[11:7]};

					// if func3 >= 4 and func3 <=7 <=> illegal
					if (instr[14] == 1'b1) begin
						intf.o_illegal_instr = 1'b1;
						intf.o_instr_format = IFORMAT_NONE;
						intf.o_wen = 1'b0;
					end


				end: op_store

				OPCODE_BRANCH: begin: op_branch

					/* if(rs1 cond rs2) then PC += imm */

					intf.o_instr_format = IFORMAT_B;
					intf.o_alu_op = {1'b0, instr[14:12]};
					intf.o_wen = 1'b0;

					intf.o_imm = {{{52{instr[31]}}}, instr[7], instr[30:25], instr[11:8], 1'b0};

					if (instr[14:12] == 3'h2 | instr[14:12] == 3'h3) begin
						intf.o_illegal_instr = 1'b1;
						intf.o_instr_format = IFORMAT_NONE;
					end

				end: op_branch

				OPCODE_JAL: begin: op_jal

					/* rd = PC + 4; PC += imm */

					intf.o_instr_format = IFORMAT_J;
					intf.o_alu_op = ALU_ADD;
					dis_ninstr = 1'b1;

					intf.o_imm = {{44{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

				end: op_jal

				OPCODE_JALR: begin :op_jalr

					/* rd = PC + 4; PC = rs1 + imm */

					intf.o_instr_format = IFORMAT_I;
					intf.o_alu_op = ALU_ADD;
					dis_ninstr = 1'b1;

					intf.o_imm = {{{52{instr[31]}}}, instr[31:20]};

					if (instr[14:12] != 3'h0) begin
						intf.o_illegal_instr = 1'b1;
						intf.o_instr_format = IFORMAT_NONE;
						intf.o_wen = 1'b0;
					end

				end: op_jalr

				OPCODE_LUI: begin: op_lui

					/* rd = (imm << 12) */

					intf.o_instr_format = IFORMAT_U;
					intf.o_alu_op = ALU_ADD;

					intf.o_imm = {{32{instr[31]}}, instr[31:12], 12'b0};

				end: op_lui

				OPCODE_AUIPC: begin: op_auipc  

					/* rd = PC + (imm << 12) */

					intf.o_instr_format = IFORMAT_U;
					intf.o_alu_op = ALU_ADD;

					intf.o_imm = {{32{instr[31]}}, instr[31:12], 12'b0};

				end: op_auipc

				default: begin

					// assert(1'b0) else $fatal();

					intf.o_illegal_instr = 1'b1; // unknown

					intf.o_instr_format = IFORMAT_NONE;
					intf.o_alu_op = ALU_SLTU;
					intf.o_imm = 64'h0;
					intf.o_wen = 1'b0;

				end

			endcase
		end

	end: decoding


	always_comb begin: alu_muxes_control_signals

		if (intf.o_illegal_instr) begin: illegal_instr
			intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
			intf.o_alu_mux2_sel = ALU_MUX2_SEL_REG;
			intf.o_pl_stall = 1'b1;
		end
		else begin

			intf.o_pl_stall = 1'b0;

			unique case (intf.o_instr_format)

			IFORMAT_R,
			IFORMAT_S,
			IFORMAT_B,
			IFORMAT_I: begin

				if (opcode == OPCODE_JALR) begin  /// TODO: STALL if 'rs1' is needed
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_PC;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM_FOUR;
				end
				else begin

					if ((intf.i_ex_rd == intf.o_rf_raddr1) & (intf.i_ex_wen)) begin

						if (intf.i_ex_lsu_op == LSU_LOAD) begin
							intf.o_pl_stall = 1'b1;
							intf.o_alu_mux1_sel = ALU_MUX1_SEL_FWD_WB;
						end
						else if ((intf.i_ex_iformat != IFORMAT_B) & (intf.i_ex_iformat != IFORMAT_S)) begin
							intf.o_alu_mux1_sel = ALU_MUX1_SEL_FWD_MEM;
						end
						else begin
							intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
						end
					end
					else if ((intf.i_mem_rd == intf.o_rf_raddr1) & (intf.i_mem_wen) &
							 (intf.i_mem_iformat != IFORMAT_B) & (intf.i_mem_iformat != IFORMAT_S)) begin
						intf.o_alu_mux1_sel = ALU_MUX1_SEL_FWD_WB;
					end
					else begin
						intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					end

					if ((intf.i_ex_rd == intf.o_rf_raddr2) & (intf.i_ex_wen)) begin

						if (intf.i_ex_lsu_op == LSU_LOAD) begin
							intf.o_pl_stall = 1'b1;
							intf.o_alu_mux2_sel = ALU_MUX2_SEL_FWD_WB;
						end
						else if ((intf.i_ex_iformat != IFORMAT_B) & (intf.i_ex_iformat != IFORMAT_S)) begin
							intf.o_alu_mux2_sel = ALU_MUX2_SEL_FWD_MEM;
						end
						else if ((intf.o_instr_format == IFORMAT_S) | (intf.o_instr_format == IFORMAT_I)) begin
							intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;
						end
						else begin
							intf.o_alu_mux2_sel = ALU_MUX2_SEL_REG;
						end

					end
					else if ((intf.i_mem_rd == intf.o_rf_raddr2) & (intf.i_mem_wen) &
							 (intf.i_mem_iformat != IFORMAT_B) & (intf.i_mem_iformat != IFORMAT_S)) begin
						intf.o_alu_mux2_sel = ALU_MUX2_SEL_FWD_WB;
					end
					else begin

						if ((intf.o_instr_format == IFORMAT_S) | (intf.o_instr_format == IFORMAT_I)) begin
							intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;
						end
						else begin
							intf.o_alu_mux2_sel = ALU_MUX2_SEL_REG;
						end

					end

				end

			end

			IFORMAT_J: begin /* No bypass */
				intf.o_alu_mux1_sel = ALU_MUX1_SEL_PC;
				intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM_FOUR;
			end

			IFORMAT_U: begin /* No bypass */

				intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;

				if (opcode == OPCODE_LUI)
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_IMM_ZERO;
				else // OPCODE_AUIPC
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_PC;

			end

			default: begin /* error (?) */
				intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
				intf.o_alu_mux2_sel = ALU_MUX2_SEL_REG;

				// assert(1'b0) else $fatal();
			end

			endcase

		end

	end: alu_muxes_control_signals

endmodule: ch0re_idecoder
