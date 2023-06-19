/*  Pipeline Spec:
 *  5-stage     [y]
 *  RV64I       [y]
 *  forwarding  [n]
 *  exceptions  [n]
 */

/* Exceptions:
 * instruction-address-misaligned (IALIGH=32) (think in IF if PC[1:0] != 0) /// TODO: <--
 * instruction-illegal
 */

`define SIMULATION


module ch0re_pipeline5st #(
	parameter IMEM_DEPTH = 2048,
	parameter IMEM_ADDR_WIDTH = $clog2(IMEM_DEPTH),
	parameter IMEM_FILE = "codemem.dat",
	parameter IMEM_START = 0,
	parameter DMEM_DEPTH = 2048,
	parameter DMEM_ADDR_WIDTH = $clog2(DMEM_DEPTH),
	parameter DMEM_FILE = "codemem.dat"
) (
	input logic clk,
	input logic rst_n
);

	localparam DMEM_DATA_WIDTH = 64;

	/* Pipeline Registers */

	logic [63:0] REG_PC;
	logic [63:0] IFIDR;

	`define IFIDR_CURR_PC 0+:64

	mem_sync_sp_intf #(
		.DEPTH(4096),
		.DATA_WIDTH(32),
		.INIT_FILE(IMEM_FILE)
	) imem_intf (
		.clk(clk)
	);

	mem_sync_sp imem(imem_intf);


	logic [340:0] IDEXR;

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
	`define IDEXR_LSU_OP  		335+:2
	`define IDEXR_WEN           337+:1
	`define IDEXR_IFORMAT       338+:3

	regfile_2r1w_intf #(
		.DATA_WIDTH(64)
	) rf_intf (
		.clk(clk)
	);

	regfile_2r1w regfile(rf_intf);
	ch0re_idecoder_intf idec_intf();
	ch0re_idecoder idec(idec_intf);


	logic [141:0] EXMEMR;

	`define EXMEMR_ALU_OUT   0+:64
	`define EXMEMR_RS2	     64+:64
	`define EXMEMR_RD	     128+:5
	`define EXMEMR_LSU_OP    133+:2
	`define EXMEMR_DATA_TYPE 135+:3
	`define EXMEMR_WEN       138+:1
	`define EXMEMR_IFORMAT   139+:3

	ch0re_alu_intf alu_intf();
	ch0re_alu alu(alu_intf);


	logic [74:0] MEMWBR;

	`define MEMWBR_OUT  	 0+:64
	`define MEMWBR_LSU_OP    64+:2
	`define MEMWBR_RD        66+:5
	`define MEMWBR_WEN       71+:1
	`define MEMWBR_DATA_TYPE 72+:3

	mem_sync_sp_rvdmem_intf #(
		.DEPTH(4096),
		.DATA_WIDTH(DMEM_DATA_WIDTH),
		.INIT_FILE(DMEM_FILE)
	) dmem_intf (
		.clk(clk)
	);

	mem_sync_sp_rvdmem dmem(dmem_intf);


	logic [63:0] wb_data;

	/*********************************/

	/* STAGE-1: 'IFETCH' */

	logic [63:0] next_pc;
	logic [63:0] branch_target;

	always_ff @(posedge clk, negedge rst_n) begin: stage_1_if

		if (!rst_n) begin

			IFIDR <= 'b0;
			REG_PC <= 'h150;

		end
		else begin

			IFIDR[`IFIDR_CURR_PC] <= REG_PC;
			REG_PC <= next_pc;

		end

	end: stage_1_if

	always_comb begin

		`ifdef SIMULATION
		imem_intf.i_addr = REG_PC[0 +: IMEM_ADDR_WIDTH] >> 2;  // simulation
		`endif

		next_pc = REG_PC + 'h4;

		unique case (IDEXR[`IDEXR_ALU_OP])

			ALU_EQ: begin

				if (alu_intf.o_flag_zero) begin
					next_pc = IDEXR[`IDEXR_BRANCH_TARGET];
				end

			end

			ALU_NE: begin

				if (!alu_intf.o_flag_zero) begin
					next_pc = IDEXR[`IDEXR_BRANCH_TARGET];
				end

			end

			ALU_LT, ALU_LTU: begin

				if (alu_intf.o_flag_less) begin
					next_pc = IDEXR[`IDEXR_BRANCH_TARGET];
				end

			end

			ALU_GE, ALU_GEU: begin

				if (!alu_intf.o_flag_less) begin
					next_pc = IDEXR[`IDEXR_BRANCH_TARGET];
				end

			end

			default: begin

				unique case (opcode_e'(imem_intf.o_rdata[6:2]))

					OPCODE_JAL,
					OPCODE_JALR: next_pc = branch_target;

					default: next_pc = REG_PC + 'h4;

				endcase

			end

		endcase

	end


	/* STAGE-2: 'IDECODE' */

	always_ff @(posedge clk, negedge rst_n) begin: stage_2_id

		if (!rst_n) begin
			IDEXR <= 'b0;
		end
		else begin

			// idec_intf.o_illegal_instr (future: precise exceptions?)

			/* Forward data from WB if conflicting address exists (read & write) */

			if (idec_intf.o_rf_raddr1) begin

				if (idec_intf.o_rf_raddr1 == MEMWBR[`MEMWBR_RD])
					IDEXR[`IDEXR_RS1] <= wb_data;
				else
					IDEXR[`IDEXR_RS1] <= rf_intf.o_rdata1;
			end
			else begin
				IDEXR[`IDEXR_RS1] <= 'b0;
			end

			if (idec_intf.o_rf_raddr2) begin

				if (idec_intf.o_rf_raddr2 == MEMWBR[`MEMWBR_RD])
					IDEXR[`IDEXR_RS2] <= wb_data;
				else
					IDEXR[`IDEXR_RS2] <= rf_intf.o_rdata1;
			end
			else begin
				IDEXR[`IDEXR_RS2] <= 'b0;
			end

			/**********************************************************************/

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

		end

	end: stage_2_id

	always_comb begin

		idec_intf.i_instr = imem_intf.o_rdata;

		branch_target = IFIDR[`IFIDR_CURR_PC] + idec_intf.o_imm;
		rf_intf.i_raddr1 = idec_intf.o_rf_raddr1;
		rf_intf.i_raddr2 = idec_intf.o_rf_raddr2;

	end


	/* STAGE-3: 'EXECUTE' */

	always_ff @(posedge clk, negedge rst_n) begin: stage_3_ex

		if (!rst_n) begin
			EXMEMR <= 'b0;
		end
		else begin

			EXMEMR[`EXMEMR_ALU_OUT] <= alu_intf.o_res;
			EXMEMR[`EXMEMR_IFORMAT] <= IDEXR[`IDEXR_IFORMAT];
			EXMEMR[`EXMEMR_RS2] <= IDEXR[`IDEXR_RS2];
			EXMEMR[`EXMEMR_RD] <= IDEXR[`IDEXR_RD];
			EXMEMR[`EXMEMR_LSU_OP] <= IDEXR[`IDEXR_LSU_OP];
			EXMEMR[`EXMEMR_DATA_TYPE] <= IDEXR[`IDEXR_DATA_TYPE];
			EXMEMR[`EXMEMR_WEN] <= IDEXR[`IDEXR_WEN];

		end

	end: stage_3_ex

	always_comb begin

		idec_intf.i_ex_rd = IDEXR[`IDEXR_RD];
		idec_intf.i_ex_wen = IDEXR[`IDEXR_WEN];
		idec_intf.i_ex_iformat = IDEXR[`IDEXR_IFORMAT];

		/* ALU's source-operands-selection muxes */

		alu_intf.i_op = alu_op_e'(IDEXR[`IDEXR_ALU_OP]);

		/* unique case (IDEXR[`IDEXR_ALU_MUX1_SEL])

			ALU_MUX1_SEL_PC: alu_intf.i_s1 = IDEXR[`IDEXR_PC];
			ALU_MUX1_SEL_REG: alu_intf.i_s1 = IDEXR[`IDEXR_RS1];
			ALU_MUX1_SEL_IMM_ZERO: alu_intf.i_s1 = 'h0;

			ALU_MUX1_SEL_FWD: begin

				alu_intf.i_s1 = 'h0;
				assert(1'b0) else $fatal("Not implemented yet!\n");

			end

		endcase

		unique case (IDEXR[`IDEXR_ALU_MUX2_SEL])

			ALU_MUX2_SEL_IMM: alu_intf.i_s2 = IDEXR[`IDEXR_IMM];
			ALU_MUX2_SEL_REG: alu_intf.i_s2 = IDEXR[`IDEXR_RS2];
			ALU_MUX2_SEL_IMM_FOUR: alu_intf.i_s2 = 'h4;
			ALU_MUX2_SEL_FWD: begin

				alu_intf.i_s2 = 'h0;
				assert(1'b0) else $fatal("Not implemented yet!\n");

			end

		endcase */

	end


	/* STAGE-4: 'MEMORY' */

	logic new_wen;

	always_ff @(posedge clk, negedge rst_n) begin: stage_4_mem

		if (!rst_n) begin
			MEMWBR <= 'b0;
		end
		else begin

			MEMWBR[`MEMWBR_OUT] <= EXMEMR[`EXMEMR_ALU_OUT];
			MEMWBR[`MEMWBR_LSU_OP] <= EXMEMR[`EXMEMR_LSU_OP];
			MEMWBR[`MEMWBR_RD] <= EXMEMR[`EXMEMR_RD];
			MEMWBR[`MEMWBR_WEN] <= new_wen;
			MEMWBR[`MEMWBR_DATA_TYPE] <= EXMEMR[`EXMEMR_DATA_TYPE];

		end

	end: stage_4_mem

	always_comb begin

		if ((EXMEMR[`EXMEMR_LSU_OP] == LSU_STORE) & EXMEMR[`EXMEMR_WEN]) begin

			new_wen = 1'b0;

			unique case (EXMEMR[`EXMEMR_DATA_TYPE - 1])  // ignore: BYTEU, HALFU, WORDU

				DTYPE_BYTE: dmem_intf.i_wen = {7'b0, 1'b1};
				DTYPE_HALF: dmem_intf.i_wen = {6'b0, 2'b1};
				DTYPE_WORD: dmem_intf.i_wen = {4'b0, 4'b1};
				DTYPE_DOUBLE: dmem_intf.i_wen = 8'b1;

				default:;

			endcase

		end
		else begin
			dmem_intf.i_wen = 8'b0;
			new_wen = EXMEMR[`EXMEMR_WEN];
		end

		dmem_intf.i_addr = EXMEMR[`EXMEMR_ALU_OUT];
		dmem_intf.i_wdata = EXMEMR[`EXMEMR_RS2];

	end

	/* STAGE-5: 'WRITE-BACK' */

	logic [63:0] read_data;

	assign read_data = dmem_intf.o_rdata;

	always_comb begin: stage_5_wb

		if (MEMWBR[`MEMWBR_LSU_OP] == LSU_LOAD) begin

			unique case (MEMWBR[`MEMWBR_DATA_TYPE])

				DTYPE_BYTE: wb_data = {{57{read_data[7]}}, read_data[6:0]};
				DTYPE_HALF: wb_data = {{49{read_data[15]}}, read_data[14:0]};
				DTYPE_WORD: wb_data = {{33{read_data[31]}}, read_data[30:0]};
				DTYPE_DOUBLE: wb_data = read_data;

				DTYPE_BYTEU: wb_data = {{56{1'b0}}, read_data[7:0]};
				DTYPE_HALFU: wb_data = {{48{1'b0}}, read_data[15:0]};
				DTYPE_WORDU: wb_data = {{32{1'b0}}, read_data[31:0]};

				default: begin
					wb_data = {64{1'h1}};
					assert(1'b0) else $fatal();
				end

			endcase

		end
		else begin
			wb_data = MEMWBR[`MEMWBR_OUT];
		end

		if (MEMWBR[`MEMWBR_RD])
			rf_intf.i_wen = MEMWBR[`MEMWBR_WEN];
		else
			rf_intf.i_wen = 'b0;

		rf_intf.i_waddr = MEMWBR[`MEMWBR_RD];
		rf_intf.i_wdata = wb_data;

	end: stage_5_wb

endmodule: ch0re_pipeline5st

