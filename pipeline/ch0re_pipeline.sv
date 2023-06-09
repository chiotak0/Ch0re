/*  Pipeline Spec:
 *  5-stage     [y]
 *  RV64I       [y]
 *  forwarding  [y]
 *  exceptions  [n]
 */

/* Exceptions: ?
 * instruction-address-misaligned (IALIGH=32) (if PC[1:0] != 0 ?)
 * instruction-illegal
 */

`include "pipeline_reg_info.sv"

// `define SIMULATION


module ch0re_pipeline #(
	parameter IMEM_FILE = "codemem.dat",
	parameter DMEM_FILE = "codemem.dat",
	parameter IMEM_START = 0
) (
	input logic clk,
	input logic rst_n
);
	localparam DMEM_DATA_WIDTH = 64;
	localparam IMEM_DATA_WIDTH = 32;
	localparam DMEM_DATA_BYTES = DMEM_DATA_WIDTH / 8;
	localparam IMEM_DATA_BYTES = IMEM_DATA_WIDTH / 8;

	`ifdef SIMULATION

	localparam DMEM_SIZE = (1 << 14);
	localparam IMEM_SIZE = (1 << 14);

	`else

	localparam DMEM_SIZE = (1 << 13);
	localparam IMEM_SIZE = (1 << 13);

	`endif

	localparam DMEM_DEPTH = DMEM_SIZE / DMEM_DATA_BYTES;
	localparam IMEM_DEPTH = IMEM_SIZE / IMEM_DATA_BYTES;

	localparam IMEM_ADDR_WIDTH = $clog2(IMEM_DEPTH);
	localparam DMEM_ADDR_WIDTH = $clog2(DMEM_DEPTH);

	// logic dmem_addr;
	// logic dmem_wdata;
	// logic dmem_wen;
	// logic dmem_rdata;


	/* Pipeline Registers */

	/* FETCH */

	logic [`PCR_SIZE] PCR;
	logic [`IFIDR_SIZE] IFIDR;

	`ifdef SIMULATION

	mem_sync_sp_intf #(
		.DEPTH(IMEM_DEPTH),
		.DATA_WIDTH(IMEM_DATA_WIDTH),
		.INIT_FILE(IMEM_FILE)
	) imem_intf (
		.clk(clk)
	);

	mem_sync_sp imem(imem_intf);

	`else

	mem_sync_sp_syn_intf #(
		.DEPTH(IMEM_DEPTH),
		.DATA_WIDTH(IMEM_DATA_WIDTH)
	) imem_intf (
		.clk(clk)
	);

	mem_sync_sp_syn imem(imem_intf);

	`endif


	/* DECODE */

	logic [`IDEXR_SIZE] IDEXR;

	regfile_2r1w_intf #(
		.DATA_WIDTH(64)
	) rf_intf (
		.clk(clk)
	);

	regfile_2r1w regfile(rf_intf);

	ch0re_idecoder_intf idec_intf(
		.clk(clk),
		.rst_n(rst_n)
	);

	ch0re_idecoder idec(idec_intf);


	/* EXECUTE */

	logic [`EXMEMR_SIZE] EXMEMR;

	ch0re_alu_intf alu_intf();
	ch0re_alu alu(alu_intf);


	/* MEMORY */

	logic [`MEMWBR_SIZE] MEMWBR;

	`ifdef SIMULATION

	mem_sync_sp_rvdmem_intf #(
		.DEPTH(DMEM_DEPTH),
		.DATA_WIDTH(DMEM_DATA_WIDTH),
		.INIT_FILE(DMEM_FILE)
	) dmem_intf (
		.clk(clk)
	);

	mem_sync_sp_rvdmem dmem(dmem_intf);

	`else 

	mem_sync_sp_syn_intf #(
		.DEPTH(DMEM_DEPTH),
		.DATA_WIDTH(DMEM_DATA_WIDTH)
	) dmem_intf (
		.clk(clk)
	);

	mem_sync_sp_syn dmem(dmem_intf);

	`endif


	/* WRITE BACK */

	logic [63:0] wb_data;

	/*********************************/

	/* PC handling */

	logic [63:0] new_offset;
	logic [63:0] branch_target;

	/* pipeline stall (IF, ID, EX) */

	logic STALLR;

	/* disable instructions in {IF,ID} if a branch was taken */

	logic DISIFR;
	logic branch_taken;

	/* history registers (dependencies) to reduce wires between stages */

	logic [10:0] EXHR;
	logic [8:0] MEMHR;


	/* STAGE-1: 'IFETCH' */

	always_ff @(posedge clk) begin: stage_1_if

		if (!rst_n) begin

			IFIDR <= 'b0;
			PCR <= IMEM_START - 'h4;

		end
		else begin

			if (!STALLR) begin

				IFIDR[`IFIDR_CURR_PC] <= PCR;

				if ((!IDEXR[`IDEXR_DISABLED]) & branch_taken) begin

					if (!IDEXR[`IDEXR_IS_JALR]) begin
						PCR <= IDEXR[`IDEXR_BRANCH_TARGET];
					end
					else begin

						unique case (IDEXR[`IDEXR_ALU_MUX1_SEL])

							ALU_MUX1_SEL_FWD_MEM: PCR <= EXMEMR[`EXMEMR_ALU_OUT] + IDEXR[`IDEXR_IMM];
							ALU_MUX1_SEL_FWD_WB:  PCR <= wb_data + IDEXR[`IDEXR_IMM];

							default: PCR <= IDEXR[`IDEXR_RS1] + IDEXR[`IDEXR_IMM];
						endcase
					end
				end
				else if ((!idec_intf.o_idis) & (opcode_e'(imem_intf.o_rdata[6:2]) == OPCODE_JAL)) begin
					PCR <= branch_target;
				end
				else begin
					PCR <= PCR + 'h4;
				end
			end
			else begin
				PCR <= PCR;
				IFIDR <= IFIDR;
			end
		end
	end

	always_comb begin: stage_1_if_comb

		if (!STALLR) begin

			`ifdef SIMULATION
			imem_intf.i_addr = PCR[0 +: IMEM_ADDR_WIDTH] >> 2;
			`else
			imem_intf.i_addr = PCR[0+: IMEM_ADDR_WIDTH];
			`endif
		end
		else begin

			`ifdef SIMULATION
			imem_intf.i_addr = (PCR[0 +: IMEM_ADDR_WIDTH] >> 2) - 1;
			`else
			imem_intf.i_addr = PCR[0+: IMEM_ADDR_WIDTH] - 'h4;
			`endif
		end


		branch_taken = 1'b0;

		if (IDEXR[`IDEXR_DISABLED]) begin
			branch_taken = 1'b0;
		end
		else begin
			unique case (IDEXR[`IDEXR_ALU_OP])

				ALU_EQ: begin
					if (alu_intf.o_flag_zero) begin
						branch_taken = 1'b1;
					end
				end

				ALU_NE: begin
					if (!alu_intf.o_flag_zero) begin
						branch_taken = 1'b1;
					end
				end

				ALU_LT, ALU_LTU: begin
					if (alu_intf.o_flag_less) begin
						branch_taken = 1'b1;
					end
				end

				ALU_GE, ALU_GEU: begin
					if (!alu_intf.o_flag_less) begin
						branch_taken = 1'b1;
					end
				end

				default: branch_taken = IDEXR[`IDEXR_IS_JALR];
			endcase
		end
	end


	/* STAGE-2: 'IDECODE' */

	always_ff @(posedge clk) begin: stage_2_id

		if (!rst_n) begin

			IDEXR <= 'h0;
			IDEXR[`IDEXR_ALU_OP] <= ALU_ADD;
			STALLR <= 1'b0;
			EXHR <= 'h0;
		end
		else begin

			STALLR <= idec_intf.o_pl_stall;

			if (!STALLR) begin

				/* handling bypass{WB->ID} and x0 */

				if (idec_intf.o_rf_raddr1 != 'h0) begin

					if (idec_intf.o_rf_raddr1 == MEMWBR[`MEMWBR_RD] & (MEMWBR[`MEMWBR_WEN]) &
						(MEMWBR[`MEMWBR_IFORMAT] != IFORMAT_S)) begin
						IDEXR[`IDEXR_RS1] <= wb_data;
					end
					else begin
						IDEXR[`IDEXR_RS1] <= rf_intf.o_rdata1;
					end
				end
				else begin
					IDEXR[`IDEXR_RS1] <= 'b0;
				end

				if (idec_intf.o_rf_raddr2 != 'h0) begin

					if (idec_intf.o_rf_raddr2 == MEMWBR[`MEMWBR_RD] & (MEMWBR[`MEMWBR_WEN]) &
						(MEMWBR[`MEMWBR_IFORMAT] != IFORMAT_S)) begin
						IDEXR[`IDEXR_RS2] <= wb_data;
					end
					else begin
						IDEXR[`IDEXR_RS2] <= rf_intf.o_rdata2;
					end
				end
				else begin
					IDEXR[`IDEXR_RS2] <= 'b0;
				end

				/***********************************/

				IDEXR[`IDEXR_PC] <= IFIDR[`IFIDR_CURR_PC];
				IDEXR[`IDEXR_RD] <= idec_intf.o_rf_waddr;

				IDEXR[`IDEXR_IMM] <= idec_intf.o_imm;
				IDEXR[`IDEXR_ALU_OP] <= idec_intf.o_alu_op;
				IDEXR[`IDEXR_IFORMAT] <= idec_intf.o_instr_format;
				IDEXR[`IDEXR_ALU_MUX1_SEL] <= idec_intf.o_alu_mux1_sel;
				IDEXR[`IDEXR_ALU_MUX2_SEL] <= idec_intf.o_alu_mux2_sel;

				IDEXR[`IDEXR_DATA_TYPE] <= idec_intf.o_data_type;
				IDEXR[`IDEXR_BRANCH_TARGET] <= branch_target;
				IDEXR[`IDEXR_LSU_OP] <= idec_intf.o_lsu_op;
				IDEXR[`IDEXR_WEN] <= idec_intf.o_wen;
				IDEXR[`IDEXR_I64] <= idec_intf.o_i64;
				IDEXR[`IDEXR_DISABLED] <= idec_intf.o_idis;

				if (opcode_e'(idec_intf.i_instr[6:2]) == OPCODE_JALR) begin
					IDEXR[`IDEXR_IS_JALR] <= 1'b1;
				end
				else begin
					IDEXR[`IDEXR_IS_JALR] <= 1'b0;
				end

				// EXHR[`EXHR_LSU_OP] <= idec_intf.o_lsu_op;
				// EXHR[`EXHR_IFMT] <= idec_intf.o_instr_format;
				// EXHR[`EXHR_WEN] <= idec_intf.o_wen;
				// EXHR[`EXHR_RD] <= idec_intf.o_rf_waddr;

				/* history registers update */

				// MEMHR[`MEMHR_IFMT] <= EXHR[`EXHR_IFMT];
				// MEMHR[`MEMHR_WEN] <= EXHR[`EXHR_WEN];
				// MEMHR[`MEMHR_RD] <= EXHR[`EXHR_RD];
			end
			else begin

				IDEXR <= IDEXR;
				STALLR <= 1'b0;
				EXHR <= EXHR;
				MEMHR <= MEMHR;
			end
		end
	end

	always_comb begin: stage_2_id_comb

		idec_intf.i_instr = imem_intf.o_rdata;
		idec_intf.i_br_taken = branch_taken;

		rf_intf.i_raddr1 = idec_intf.o_rf_raddr1;
		rf_intf.i_raddr2 = idec_intf.o_rf_raddr2;

		branch_target = IFIDR[`IFIDR_CURR_PC] + idec_intf.o_imm;
	end


	/* STAGE-3: 'EXECUTE' */

	assign idec_intf.i_ex_rd = IDEXR[`IDEXR_RD]; //EXHR[`EXHR_RD];
	assign idec_intf.i_ex_wen = IDEXR[`IDEXR_WEN]; //EXHR[`EXHR_WEN];
	assign idec_intf.i_ex_lsu_op = lsu_op_e'(IDEXR[`IDEXR_LSU_OP]); //EXHR[`EXHR_LSU_OP];
	assign idec_intf.i_ex_iformat = iformat_e'(IDEXR[`IDEXR_IFORMAT]); //EXHR[`EXHR_IFMT];

	assign alu_intf.i_op = alu_op_e'(IDEXR[`IDEXR_ALU_OP]);
	assign alu_intf.i_i64 = IDEXR[`IDEXR_I64];

	always_ff @(posedge clk) begin: stage_3_ex

		if (!rst_n) begin
			EXMEMR <= 'b0;
		end
		else begin

			if (!STALLR) begin

				EXMEMR[`EXMEMR_ALU_OUT] <= alu_intf.o_res;
				EXMEMR[`EXMEMR_IFORMAT] <= IDEXR[`IDEXR_IFORMAT];
				EXMEMR[`EXMEMR_RD] <= IDEXR[`IDEXR_RD];
				EXMEMR[`EXMEMR_LSU_OP] <= IDEXR[`IDEXR_LSU_OP];
				EXMEMR[`EXMEMR_DATA_TYPE] <= IDEXR[`IDEXR_DATA_TYPE];
				EXMEMR[`EXMEMR_WEN] <= IDEXR[`IDEXR_WEN];
				EXMEMR[`EXMEMR_DISABLED] <= IDEXR[`IDEXR_DISABLED];

				if (IDEXR[`IDEXR_LSU_OP] == LSU_STORE) begin

					unique case (IDEXR[`IDEXR_ALU_MUX2_SEL])

						ALU_MUX2_SEL_FWD_WB: EXMEMR[`EXMEMR_RS2] <= wb_data;
						ALU_MUX2_SEL_FWD_MEM: EXMEMR[`EXMEMR_RS2] <= EXMEMR[`EXMEMR_ALU_OUT];

						default: EXMEMR[`EXMEMR_RS2] <= IDEXR[`IDEXR_RS2];
					endcase
				end
				else begin
					EXMEMR[`EXMEMR_RS2] <= IDEXR[`IDEXR_RS2];
				end
			end
			else begin

				EXMEMR <= EXMEMR;
				EXMEMR[`EXMEMR_LSU_OP] <= LSU_NONE;
				EXMEMR[`EXMEMR_WEN] <= 1'b0;
				EXMEMR[`EXMEMR_DISABLED] <= 1'b1;
			end
		end
	end

	always_comb begin: stage_3_ex_comb

		/* ALU's source-operands-selection muxes */

		unique case (IDEXR[`IDEXR_ALU_MUX1_SEL])

			ALU_MUX1_SEL_PC:       alu_intf.i_s1 = IDEXR[`IDEXR_PC];
			ALU_MUX1_SEL_REG:      alu_intf.i_s1 = IDEXR[`IDEXR_RS1];
			ALU_MUX1_SEL_IMM_ZERO: alu_intf.i_s1 = 'h0;

			ALU_MUX1_SEL_FWD_WB: begin

				if (!IDEXR[`IDEXR_IS_JALR]) begin
					alu_intf.i_s1 = wb_data;
				end
				else begin
					alu_intf.i_s1 = IDEXR[`IDEXR_PC];
				end
			end

			ALU_MUX1_SEL_FWD_MEM: begin

				if (!IDEXR[`IDEXR_IS_JALR]) begin
					alu_intf.i_s1 = EXMEMR[`EXMEMR_ALU_OUT];
				end
				else begin
					alu_intf.i_s1 = IDEXR[`IDEXR_PC];
				end
			end

			default:;

		endcase

		/// TODO: rewrite it better using if-else to avoid duplicate code!

		unique case (IDEXR[`IDEXR_ALU_MUX2_SEL])

			ALU_MUX2_SEL_IMM: alu_intf.i_s2 = IDEXR[`IDEXR_IMM];
			ALU_MUX2_SEL_REG: alu_intf.i_s2 = IDEXR[`IDEXR_RS2];

			ALU_MUX2_SEL_FWD_WB: begin

				if (IDEXR[`IDEXR_LSU_OP] != LSU_STORE) begin
					alu_intf.i_s2 = wb_data;
				end
				else begin
					alu_intf.i_s2 = IDEXR[`IDEXR_IMM];
				end
			end

			ALU_MUX2_SEL_FWD_MEM: begin

				if (IDEXR[`IDEXR_LSU_OP] != LSU_STORE) begin
					alu_intf.i_s2 = EXMEMR[`EXMEMR_ALU_OUT];
				end
				else begin
					alu_intf.i_s2 = IDEXR[`IDEXR_IMM];
				end
			end
			ALU_MUX2_SEL_IMM_FOUR: alu_intf.i_s2 = 'h4;

			default:;
		endcase
	end


	/* STAGE-4: 'MEMORY' */

	logic new_wen;

	assign idec_intf.i_mem_rd = EXMEMR[`EXMEMR_RD]; //MEMHR[`MEMHR_RD];
	assign idec_intf.i_mem_wen = EXMEMR[`EXMEMR_WEN]; //MEMHR[`MEMHR_WEN];
	assign idec_intf.i_mem_iformat = iformat_e'(EXMEMR[`EXMEMR_IFORMAT]); //MEMHR[`MEMHR_IFMT];

	always_ff @(posedge clk) begin: stage_4_mem

		if (!rst_n) begin
			MEMWBR <= 'b0;
		end
		else begin

			MEMWBR[`MEMWBR_ALU_OUT] <= EXMEMR[`EXMEMR_ALU_OUT];
			MEMWBR[`MEMWBR_LSU_OP] <= EXMEMR[`EXMEMR_LSU_OP];
			MEMWBR[`MEMWBR_RD] <= EXMEMR[`EXMEMR_RD];
			MEMWBR[`MEMWBR_WEN] <= new_wen;
			MEMWBR[`MEMWBR_DATA_TYPE] <= EXMEMR[`EXMEMR_DATA_TYPE];
			MEMWBR[`MEMWBR_IFORMAT] <= EXMEMR[`EXMEMR_IFORMAT];
			MEMWBR[`MEMWBR_DISABLED] <= EXMEMR[`EXMEMR_DISABLED];
		end
	end

	always_comb begin: stage_4_mem_comb

		if ((EXMEMR[`EXMEMR_LSU_OP] == LSU_STORE) & EXMEMR[`EXMEMR_WEN]) begin

			new_wen = 1'b0;

			unique case (EXMEMR[`EXMEMR_DATA_TYPE - 1])  // ignoring 'BYTEU, HALFU, WORDU'

				DTYPE_BYTE: dmem_intf.i_wen = {7'b0, 1'b1};
				DTYPE_HALF: dmem_intf.i_wen = {6'b0, 2'b1};
				DTYPE_WORD: dmem_intf.i_wen = {4'b0, 4'b1};
				DTYPE_DOUBLE: dmem_intf.i_wen = 8'b1;

				default:;

			endcase
		end
		else begin
			dmem_intf.i_wen = 'h0;
			new_wen = EXMEMR[`EXMEMR_WEN];
		end

		dmem_intf.i_addr = EXMEMR[`EXMEMR_ALU_OUT];
		dmem_intf.i_wdata = EXMEMR[`EXMEMR_RS2];
	end


	/* STAGE-5: 'WRITE-BACK' */

	logic [63:0] read_data;
	logic [2:0] byte_offset;

	assign read_data = dmem_intf.o_rdata;

	always_comb begin: stage_5_wb_comb

		byte_offset = MEMWBR[`MEMWBR_ALU_OUT - 61];  // extracting only the 3 LSbits

		if (MEMWBR[`MEMWBR_LSU_OP] == LSU_LOAD) begin

			unique case (MEMWBR[`MEMWBR_DATA_TYPE])

				DTYPE_BYTE: begin

					unique case (byte_offset)

						// Could have I used 'generate' construct?

						3'h0: wb_data = {{57{read_data[7]}}, read_data[0+:7]};
						3'h1: wb_data = {{57{read_data[15]}}, read_data[8+:7]};
						3'h2: wb_data = {{57{read_data[23]}}, read_data[16+:7]};
						3'h3: wb_data = {{57{read_data[31]}}, read_data[24+:7]};
						3'h4: wb_data = {{57{read_data[39]}}, read_data[32+:7]};
						3'h5: wb_data = {{57{read_data[47]}}, read_data[40+:7]};
						3'h6: wb_data = {{57{read_data[55]}}, read_data[48+:7]};
						3'h7: wb_data = {{57{read_data[63]}}, read_data[56+:7]};
					endcase
				end

				DTYPE_BYTEU: begin

					unique case (byte_offset)

						3'h0: wb_data = {{56{1'b0}}, read_data[0+:8]};
						3'h1: wb_data = {{56{1'b0}}, read_data[8+:8]};
						3'h2: wb_data = {{56{1'b0}}, read_data[16+:8]};
						3'h3: wb_data = {{56{1'b0}}, read_data[24+:8]};
						3'h4: wb_data = {{56{1'b0}}, read_data[32+:8]};
						3'h5: wb_data = {{56{1'b0}}, read_data[40+:8]};
						3'h6: wb_data = {{56{1'b0}}, read_data[48+:8]};
						3'h7: wb_data = {{56{1'b0}}, read_data[56+:8]};
					endcase
				end

				DTYPE_HALF: begin

					unique casez (byte_offset)

						3'b00?: wb_data = {{49{read_data[15]}}, read_data[0+:15]};
						3'b01?: wb_data = {{49{read_data[31]}}, read_data[16+:15]};
						3'b10?: wb_data = {{49{read_data[47]}}, read_data[32+:15]};
						3'b11?: wb_data = {{49{read_data[63]}}, read_data[48+:15]};
					endcase
				end

				DTYPE_HALFU: begin

					unique casez (byte_offset)

						3'b00?: wb_data = {{48{1'b0}}, read_data[0+:16]};
						3'b01?: wb_data = {{48{1'b0}}, read_data[16+:16]};
						3'b10?: wb_data = {{48{1'b0}}, read_data[32+:16]};
						3'b11?: wb_data = {{48{1'b0}}, read_data[48+:16]};
					endcase
				end

				DTYPE_WORD: begin

					unique casez (byte_offset)

						3'b0??: wb_data = {{33{read_data[31]}}, read_data[0+:31]};
						3'b1??: wb_data = {{33{read_data[63]}}, read_data[32+:31]};

						default:;
					endcase
				end

				DTYPE_WORDU: begin

					unique casez (byte_offset)

						3'b0??: wb_data = {{32{1'b0}}, read_data[0+:32]};
						3'b1??: wb_data = {{32{1'b0}}, read_data[32+:32]};

						default:;
					endcase
				end

				DTYPE_DOUBLE: wb_data = read_data;

				DTYPE_BYTEU: begin

					unique case (byte_offset)

						// Could have I used 'generate' construct?

						3'b000: wb_data = {{56{1'b0}}, read_data[0+:8]};
						3'b001: wb_data = {{56{1'b0}}, read_data[8+:8]};
						3'b010: wb_data = {{56{1'b0}}, read_data[16+:8]};
						3'b100: wb_data = {{56{1'b0}}, read_data[24+:8]};
						3'b011: wb_data = {{56{1'b0}}, read_data[32+:8]};
						3'b101: wb_data = {{56{1'b0}}, read_data[40+:8]};
						3'b110: wb_data = {{56{1'b0}}, read_data[48+:8]};
						3'b111: wb_data = {{56{1'b0}}, read_data[56+:8]};
					endcase
				end

				default: begin
					wb_data = {64{1'h1}};
					assert(1'b0) else $fatal();
				end
			endcase

		end
		else begin
			wb_data = MEMWBR[`MEMWBR_ALU_OUT];
		end

		if (MEMWBR[`MEMWBR_RD]) begin
			rf_intf.i_wen = MEMWBR[`MEMWBR_WEN];
		end
		else begin
			rf_intf.i_wen = 'b0;
		end

		rf_intf.i_waddr = MEMWBR[`MEMWBR_RD];
		rf_intf.i_wdata = wb_data;
	end

endmodule: ch0re_pipeline

