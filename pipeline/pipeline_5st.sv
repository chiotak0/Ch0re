/*  Pipeline Spec:
 *  5-stage     []
 *  RV64IC      []
 *  forwarding  []
 *  bypassing   []
 *  exceptions  []
 */

/* Exceptions:
 * instruction-address-misaligned (IALIGH=32)
 */


module pipeline_5st #(
	parameter IMEM_DEPTH = 2048,
	parameter IMEM_ADDR_WIDTH = $clog2(IMEM_DEPTH),
	parameter IMEM_DATA_WIDTH = 32,
	parameter IMEM_FILE = "codemem.dat"
) (
	input logic clk,
	input logic rst_n
);
	localparam REG_FILE_SIZE = 32;
	localparam REG_ADDR_WIDTH = $clog2(REG_FILE_SIZE);


	/* STAGE-1: 'IF/ID' */

	logic [63:0] REG_PC;
	logic [63:0] IFIDR;

	`define IFIDR_CURR_PC 0+:64

	logic [63:0] NPC;

	mem_sync_sp_intf #(
		.DEPTH(IMEM_DEPTH),
		.DATA_WIDTH(IMEM_DATA_WIDTH)
		// .INIT_FILE(IMEM_FILE),
		// .INIT_START('h0)
		// .INIT_END('h160 - 1)
	) imem_intf (
		.clk(clk)
	);

	mem_sync_sp imem (imem_intf);

	always_ff @(posedge clk, negedge rst_n) begin : stage_1_if_id
		if (!rst_n) begin

			IFIDR <= 'b0;
			REG_PC <= 'b0;

		end
		else begin

			IFIDR[`IFIDR_CURR_PC] <= REG_PC;
			REG_PC <= NPC;

		end
	end : stage_1_if_id

	always_comb begin

		NPC = REG_PC + 'h4;  /// TODO: add mux from stage-3
		imem_intf.i_addr = REG_PC[0 +: IMEM_ADDR_WIDTH] >> 2;

	end


	/* STAGE-2: 'ID/EX' */

	logic [334:0] IDEXR;

	`define IDEXR_IMM           0+:64
	`define IDEXR_RS1           64+:64
	`define IDEXR_RS2           128+:64
	`define IDEXR_PC            192+:64
	`define IDEXR_RD            256+:5
	`define IDEXR_ALU_OP        261+:4
	`define IDEXR_ALU_MUX1_SEL  265+:2
	`define IDEXR_ALU_MUX2_SEL  267
	`define IDEXR_DATA_TYPE     268+:3
	`define IDEXR_BRANCH_TARGET 271+:64

	regfile_2r1w_intf #(
		.DATA_WIDTH(64)
	) rf_intf (
		.clk(clk)
	);

	regfile_2r1w regfile(rf_intf);
	idecoder_intf idec_intf();
	idecoder idec(idec_intf);

	always_ff @(posedge clk, @negedge rst_n) begin : stage_2_id_ex

		if (!rst_n) begin
			IDEXR <= 'b0;
		end
		else begin

			// idec_intf.o_illegal_instr ???

			IDEXR[`IDEXR_RS1] <= rf_intf.o_rdata1;
			IDEXR[`IDEXR_RS2] <= rf_intf.o_rdata2;
			IDEXR[`IDEXR_PC] <= IFIDR[`IFIDR_CURR_PC];
			IDEXR[`IDEXR_RD] <= idec_intf.o_rf_waddr;

			IDEXR[`IDEXR_IMM] <= idec_intf.o_imm;
			IDEXR[`IDEXR_ALU_OP] <= idec_intf.o_alu_op;
			IDEXR[`IDEXR_ALU_MUX1_SEL] <= idec_intf.o_alu_mux1_sel;
			IDEXR[`IDEXR_ALU_MUX2_SEL] <= idec_intf.o_alu_mux2_sel;

			IDEXR[`IDEXR_DATA_TYPE] <= idec_intf.o_data_type;
			IDEXR[`IDEXR_BRANCH_TARGET] <= IFIDR[`IFIDR_CURR_PC] + idec_intf.o_imm;

		end

	end : stage_2_id_ex

	always_comb begin

		idec_intf.i_instr = imem_intf.o_rdata;

		rf_intf.i_raddr1 = idec_intf.o_rf_raddr1;
		rf_intf.i_raddr2 = idec_intf.o_rf_raddr2;

	end


	/* STAGE-3: 'EX/MEM' */

	logic [100:0] EXMEMR;     // | 64res | 5rd | 1cond |

	/* STAGE 3 (EX/MEM) */
	/* always_ff @(posedge clk) begin : stage_3_ex_mem
		if (!rst_n) begin
			EXMEMR <= 'b0;
		end
		else begin
			EXMEMR <= IDEXR;
		end
	end : stage_3_ex_mem */


	/* STAGE 4 (MEM/WB) */
	/* always_ff @(posedge clk) begin : stage_4_mem_wb
		if (!rst_n) begin
			MEMWBR <= 'b0;
		end
		else begin
			MEMWBR <= EXMEMR;
		end
	end : stage_4_mem_wb */

	/* STAGE 5 (WB) */

endmodule: pipeline_5st
