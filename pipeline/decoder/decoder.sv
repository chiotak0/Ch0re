import ch0re_types::*;


module decoder (
	input logic [31:0] i_instr,

	output logic o_illegal_instr,

	/* to Register File */

	output logic [4:0] o_rf_raddr1,
	output logic [4:0] o_rf_raddr2,
	output logic [4:0] o_rf_waddr,

	/* to ALU */

	output logic [63:0] o_imm,
	output iformat_e o_instr_format, /// TODO: remove!
	output alu_op_e o_alu_op
	output alu_mux1_sel_e o_alu_mux1_sel,
	output alu_mux2_sel_e o_alu_mux2_sel,

	/* to LSU */

	output data_type_e o_data_type

);
	logic [31:0] instr;

	/** Register Handling **/

	assign instr = i_instr;
	assign o_rf_raddr1 = instr[19:15];
	assign o_rf_raddr2 = instr[24:20];
	assign o_rf_waddr  = instr[11:7];

	/** Decode + Instruction Check **/

	opcode_e opcode = opcode_e'(instr[6:2]);

	always_comb begin : 32_bit_instruction_decoder

		/* Only 32-bit instructions supported! */

		if (instr[1:0] != 2'b11) begin
			o_illegal_instr = 1'b1;

			o_alu_mux1_sel = ALU_MUX1_SEL_REG;
			o_alu_mux2_sel = ALU_MUX2_SEL_REG;
			o_instr_format = 'b0;
			o_alu_op = 'b0;
			o_imm = 64'h0;
		end
		else begin

			o_illegal_instr = 1'b0;

			o_instr_format = IFORMAT_R;
			o_alu_op = ALU_SLTU;
			o_imm = 64'h0;
			o_alu_mux1_sel = ALU_MUX1_SEL_REG;
			o_alu_mux2_sel = ALU_MUX2_SEL_REG;
			o_data_type = DTYPE_DOUBLE

			unique case (opcode)

				OPCODE_OP32: begin : op_op32  // "w"

					/* rd = (rs1[31:0] op rs2[31:0])[31:0] */

					o_instr_format = IFORMAT_R;
					o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					o_alu_mux2_sel = ALU_MUX2_SEL_REG;

					unique case (instr[14:12])

						3'h0: begin
							if (instr[31:25] == 7'h0)
								o_alu_op = ALU_ADD;
							else if (instr[31:25] == 7'h20)
								o_alu_op = ALU_SUB;
							else
								o_illegal_instr = 1'b1;
						end

						3'h5: begin
							if (instr[31:25] == 7'h0)
								o_alu_op = ALU_SRL;
							else if (instr[31:25] == 7'h20)
								o_alu_op = ALU_SRA;
							else
								o_illegal_instr = 1'b1;
						end

						3'h1: o_alu_op = ALU_SLL;

						default: o_illegal_instr = 1'b1;

					endcase

				end : op_op32

				OPCODE_OP_IMM32: begin : op_op_imm32

					/* rd = (rs1 op imm)[31:0] */

					o_instr_format = IFORMAT_I;
					o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					o_alu_mux2_sel = ALU_MUX2_SEL_IMM;

					unique case (instr[14:12])

						3'h1: begin
							o_illegal_instr = (instr[31:25] == 7'h0) ? 1'b0 : 1'b1;
							o_imm = {59{1'b0}, instr[24:20]};
							o_alu_op = ALU_SLL;
						end

						3'h5: begin
							o_imm = {59{1'b0}, instr[24:20]};

							if (instr[31:25] == 7'h0)
								o_alu_op = ALU_SRL;
							else if (instr[31:25] == 7'h10)
								o_alu_op = ALU_SRA;
							else
								o_illegal_instr = 1'b1;
						end

						3'h0: o_alu_op = ALU_ADD;

						default: o_illegal_instr = 1'b1;

					endcase

				end : op_op_imm32

				OPCODE_OP: begin : op_op

					/* rd = rs1 op rs2 */

					o_instr_format = IFORMAT_R;
					o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					o_alu_mux2_sel = ALU_MUX2_SEL_REG;

					unique case (instr[14:12])

						3'h0: begin
							if (instr[31:25] == 7'h0)
								o_alu_op = ALU_ADD;
							else if (instr[31:25] == 7'h20)
								o_alu_op = ALU_SUB;
							else
								o_illegal_instr = 1'b1;
						end

						3'h5: begin
							if (instr[31:25] == 7'h0)
								o_alu_op = ALU_SRL;
							else if (instr[31:25] == 7'h20)
								o_alu_op = ALU_SRA;
							else
								o_illegal_instr = 1'b1;
						end

						3'h1: o_alu_op = ALU_SLL;
						3'h2: o_alu_op = ALU_SLT;
						3'h3: o_alu_op = ALU_SLTU;
						3'h4: o_alu_op = ALU_XOR;
						3'h6: o_alu_op = ALU_OR;
						3'h7: o_alu_op = ALU_AND;

						default:;

					endcase

				end : op_op

				OPCODE_OP_IMM: begin : op_imm

					/* rd = rs1 op imm */

					o_instr_format = IFORMAT_I;
					o_imm = {52{instr[31]}, instr[31:20]};
					o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					o_alu_mux2_sel = ALU_MUX2_SEL_IMM;

					unique case (instr[14:12])

						3'h1: begin
							o_illegal_instr = (instr[31:26] == 6'h0) ? 1'b0 : 1'b1;
							o_imm = {58{1'b0}, instr[25:20]};
							o_alu_op = ALU_SLL;
						end

						3'h5: begin
							o_imm = {58{1'b0}, instr[25:20]};

							if (instr[31:26] == 6'h0)
								o_alu_op = ALU_SRL;
							else if (instr[31:26] == 6'h10)
								o_alu_op = ALU_SRA;
							else
								o_illegal_instr = 1'b1;
						end

						3'h0: o_alu_op = ALU_ADD;
						3'h2: o_alu_op = ALU_SLT;
						3'h3: o_alu_op = ALU_SLTU;
						3'h4: o_alu_op = ALU_XOR;
						3'h6: o_alu_op = ALU_OR;
						3'h7: o_alu_op = ALU_AND;

						default:;

					endcase

				end : op_imm

				OPCODE_LOAD: begin : op_load

					/* rd = Mem[rs1 + imm] */

					o_instr_format = IFORMAT_I;

					o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					o_alu_mux2_sel = ALU_MUX2_SEL_IMM;
					o_data_type = instr[14:12];
					o_alu_op = ALU_ADD;

					o_illegal_instr = (instr[14:12] == 3'h7) ? 1'b1 : 1'b0;
					o_imm = {{52{instr[31]}}, instr[31:20]};

				end : op_load

				OPCODE_STORE: begin : op_store

					/* Mem[rs1 + imm] = rs2 */

					o_instr_format = IFORMAT_S;
					o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					o_alu_mux2_sel = ALU_MUX2_SEL_IMM;
					o_data_type = instr[14:12];
					o_alu_op = ALU_ADD;

					// if func3 >= 4 and func3 <=7 <=> illegal
					o_illegal_instr = (instr[14] == 1'b1) ? 1'b1 : 1'b0;
					o_imm = {{52{instr[31]}}, instr[31:25], instr[11:7]};

				end : op_store

				OPCODE_BRANCH: begin : op_branch

					/* if(rs1 cond rs2) then PC += imm */

					o_instr_format = IFORMAT_B;
					o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					o_alu_mux2_sel = ALU_MUX2_SEL_REG;
					o_alu_op = {1'b0, instr[14:12]};

					o_illegal_instr = (instr[14:12] == 3'h2 | instr[14:12] == 3'h3) ? 1'b1 : 1'b0;
					o_imm = {{52{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

				end : op_branch

				OPCODE_JAL: begin :op_jal

					/* rd = PC + 4; PC += imm */

					o_instr_format = IFORMAT_J;
					o_alu_mux1_sel = ALU_MUX1_SEL_PC;
					o_alu_mux2_sel = ALU_MUX2_SEL_IMM;

					o_imm = {{44{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
					o_alu_op = ALU_ADD;

				end : op_jal

				OPCODE_JALR: begin :op_jalr

					/* rd = PC + 4; PC = rs1 + imm */

					o_instr_format = IFORMAT_I;
					o_alu_mux1_sel = ALU_MUX1_SEL_REG;
					o_alu_mux2_sel = ALU_MUX2_SEL_IMM;

					o_illegal_instr = (instr[14:12] == 3'h0) ? 1'b0 : 1'b1;
					o_imm = {{52{instr[31]}}, instr[31:20]};
					o_alu_op = ALU_ADD;

				end : op_jalr

				OPCODE_LUI: begin : op_lui

					/* rd = (imm << 12) */

					o_instr_format = IFORMAT_U;
					o_alu_mux1_sel = ALU_MUX1_SEL_IMM; // zero
					o_alu_mux2_sel = ALU_MUX2_SEL_IMM; // imm

					o_imm = {{32{instr[31]}}, instr[31:12], 12'b0};
					o_alu_op = ALU_ADD;

				end : op_lui

				OPCODE_AUIPC: begin : op_auipc

					/* rd = PC + (imm << 12) */

					o_instr_format = IFORMAT_U;
					o_alu_mux1_sel = ALU_MUX1_SEL_PC;
					o_alu_mux2_sel = ALU_MUX2_SEL_IMM;

					o_imm = o_imm = {{32{instr[31]}}, instr[31:12], 12'b0};
					o_alu_op = ALU_ADD;

				end : op_auipc

				default: o_illegal_instr = 1'b1; // unknown

			endcase
		end

	end : 32_bit_instruction_decoder

endmodule : decoder
