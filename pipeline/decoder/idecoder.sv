`include "ch0re_types.sv"

interface idecoder_intf();

	logic [31:0] i_instr;

	logic o_illegal_instr;

	logic [4:0] o_rf_raddr1;
	logic [4:0] o_rf_raddr2;
	logic [4:0] o_rf_waddr;

	/* to ALU */

	logic [63:0] o_imm;
	iformat_e o_instr_format; /// TODO: remove!
	alu_op_e o_alu_op;
	alu_mux1_sel_e o_alu_mux1_sel;
	alu_mux2_sel_e o_alu_mux2_sel;

	/* to LSU */

	data_type_e o_data_type;

endinterface : idecoder_intf


module idecoder(idecoder_intf intf);
	logic [31:0] instr;
	opcode_e opcode;

	/** Register Handling **/

	assign instr = intf.i_instr;
	assign intf.o_rf_raddr1 = instr[19:15];
	assign intf.o_rf_raddr2 = instr[24:20];
	assign intf.o_rf_waddr  = instr[11:7];
	assign opcode = opcode_e'(instr[6:2]);


	always_comb begin

		/* Only 32-bit instructions supported! */

		if (instr[1:0] != 2'b11) begin

			intf.o_illegal_instr = 1'b1;

			intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
			intf.o_alu_mux2_sel = ALU_MUX2_SEL_REG;
			intf.o_instr_format = 'b0;
			intf.o_alu_op = 'b0;
			intf.o_imm = 64'h0;
		end
		else begin

			intf.o_illegal_instr = 1'b0;

			unique case (opcode)

				OPCODE_OP32: begin : op_op32  // "w"

					/* rd = (rs1[31:0] op rs2[31:0])[31:0] */

					intf.o_instr_format = IFORMAT_R;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_REG;

					unique case (instr[14:12])

						3'h0: begin
							if (instr[31:25] == 7'h0)
								intf.o_alu_op = ALU_ADD;
							else if (instr[31:25] == 7'h20)
								intf.o_alu_op = ALU_SUB;
							else
								intf.o_illegal_instr = 1'b1;
						end

						3'h5: begin
							if (instr[31:25] == 7'h0)
								intf.o_alu_op = ALU_SRL;
							else if (instr[31:25] == 7'h20)
								intf.o_alu_op = ALU_SRA;
							else
								intf.o_illegal_instr = 1'b1;
						end

						3'h1: intf.o_alu_op = ALU_SLL;

						default: intf.o_illegal_instr = 1'b1;

					endcase

				end : op_op32

				OPCODE_OP_IMM32: begin : op_op_imm32

					/* rd = (rs1 op imm)[31:0] */

					intf.o_instr_format = IFORMAT_I;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;

					intf.o_imm = {{59{1'b0}}, instr[24:20]};

					unique case (instr[14:12])

						3'h1: begin
							intf.o_illegal_instr = (instr[31:25] == 7'h0) ? 1'b0 : 1'b1;
							intf.o_alu_op = ALU_SLL;
						end

						3'h5: begin
							if (instr[31:25] == 7'h0)
								intf.o_alu_op = ALU_SRL;
							else if (instr[31:25] == 7'h10)
								intf.o_alu_op = ALU_SRA;
							else
								intf.o_illegal_instr = 1'b1;
						end

						3'h0: intf.o_alu_op = ALU_ADD;

						default: intf.o_illegal_instr = 1'b1;

					endcase

				end : op_op_imm32

				OPCODE_OP: begin : op_op

					/* rd = rs1 op rs2 */

					intf.o_instr_format = IFORMAT_R;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_REG;

					unique case (instr[14:12])

						3'h0: begin
							if (instr[31:25] == 7'h0)
								intf.o_alu_op = ALU_ADD;
							else if (instr[31:25] == 7'h20)
								intf.o_alu_op = ALU_SUB;
							else
								intf.o_illegal_instr = 1'b1;
						end

						3'h5: begin
							if (instr[31:25] == 7'h0)
								intf.o_alu_op = ALU_SRL;
							else if (instr[31:25] == 7'h20)
								intf.o_alu_op = ALU_SRA;
							else
								intf.o_illegal_instr = 1'b1;
						end

						3'h1: intf.o_alu_op = ALU_SLL;
						3'h2: intf.o_alu_op = ALU_SLT;
						3'h3: intf.o_alu_op = ALU_SLTU;
						3'h4: intf.o_alu_op = ALU_XOR;
						3'h6: intf.o_alu_op = ALU_OR;
						3'h7: intf.o_alu_op = ALU_AND;

						default:;

					endcase

				end : op_op

				OPCODE_OP_IMM: begin : op_imm

					/* rd = rs1 op imm */

					intf.o_instr_format = IFORMAT_I;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;

					intf.o_imm = {{52{instr[31]}}, instr[31:20]};

					unique case (instr[14:12])

						3'h1: begin
							intf.o_illegal_instr = (instr[31:26] == 6'h0) ? 1'b0 : 1'b1;
							intf.o_imm = {{58{1'b0}}, instr[25:20]};
							intf.o_alu_op = ALU_SLL;
						end

						3'h5: begin
							intf.o_imm = {{58{1'b0}}, instr[25:20]};

							if (instr[31:26] == 6'h0)
								intf.o_alu_op = ALU_SRL;
							else if (instr[31:26] == 6'h10)
								intf.o_alu_op = ALU_SRA;
							else
								intf.o_illegal_instr = 1'b1;
						end

						3'h0: intf.o_alu_op = ALU_ADD;
						3'h2: intf.o_alu_op = ALU_SLT;
						3'h3: intf.o_alu_op = ALU_SLTU;
						3'h4: intf.o_alu_op = ALU_XOR;
						3'h6: intf.o_alu_op = ALU_OR;
						3'h7: intf.o_alu_op = ALU_AND;

						default:;

					endcase

				end : op_imm

				OPCODE_LOAD: begin : op_load

					intf.o_illegal_instr = (instr[14:12] == 3'h7) ? 1'b1 : 1'b0;

					/* rd = Mem[rs1 + imm] */

					intf.o_instr_format = IFORMAT_I;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;
					intf.o_data_type = instr[14:12];
					intf.o_alu_op = ALU_ADD;

					intf.o_imm = {{{52{instr[31]}}}, instr[31:20]};

				end : op_load

				OPCODE_STORE: begin : op_store

					// if func3 >= 4 and func3 <=7 <=> illegal
					intf.o_illegal_instr = (instr[14] == 1'b1) ? 1'b1 : 1'b0;

					/* Mem[rs1 + imm] = rs2 */

					intf.o_instr_format = IFORMAT_S;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;
					intf.o_data_type = instr[14:12];
					intf.o_alu_op = ALU_ADD;

					intf.o_imm = {{{52{instr[31]}}}, instr[31:25], instr[11:7]};

				end : op_store

				OPCODE_BRANCH: begin : op_branch

					intf.o_illegal_instr = (instr[14:12] == 3'h2 | instr[14:12] == 3'h3) ? 1'b1 : 1'b0;

					/* if(rs1 cond rs2) then PC += imm */

					intf.o_instr_format = IFORMAT_B;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_REG;
					intf.o_alu_op = {1'b0, instr[14:12]};

					intf.o_imm = {{{52{instr[31]}}}, instr[7], instr[30:25], instr[11:8], 1'b0};

				end : op_branch

				OPCODE_JAL: begin :op_jal

					/* rd = PC + 4; PC += imm */

					intf.o_instr_format = IFORMAT_J;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_PC;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;
					intf.o_alu_op = ALU_ADD;

					intf.o_imm = {{44{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

				end : op_jal

				OPCODE_JALR: begin :op_jalr

					intf.o_illegal_instr = (instr[14:12] == 3'h0) ? 1'b0 : 1'b1;

					/* rd = PC + 4; PC = rs1 + imm */

					intf.o_instr_format = IFORMAT_I;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;
					intf.o_alu_op = ALU_ADD;

					intf.o_imm = {{{52{instr[31]}}}, instr[31:20]};

				end : op_jalr

				OPCODE_LUI: begin : op_lui

					/* rd = (imm << 12) */

					intf.o_instr_format = IFORMAT_U;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_IMM; // zero
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM; // imm
					intf.o_alu_op = ALU_ADD;

					intf.o_imm = {{32{instr[31]}}, instr[31:12], 12'b0};

				end : op_lui

				OPCODE_AUIPC: begin : op_auipc

					/* rd = PC + (imm << 12) */

					intf.o_instr_format = IFORMAT_U;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_PC;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_IMM;
					intf.o_alu_op = ALU_ADD;

					intf.o_imm = {{32{instr[31]}}, instr[31:12], 12'b0};

				end : op_auipc

				default: begin

					// assert(1'b0) else $fatal();

					intf.o_illegal_instr = 1'b1; // unknown

					intf.o_instr_format = IFORMAT_R;
					intf.o_alu_op = ALU_SLTU;
					intf.o_imm = 64'h0;
					intf.o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					intf.o_alu_mux2_sel = ALU_MUX2_SEL_REG;
					intf.o_data_type = DTYPE_DOUBLE;

				end

			endcase
		end

	end

endmodule : idecoder
