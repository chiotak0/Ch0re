/*  Pipeline Spec:
 *  5-stage     [y]
 *  RV64I       [y]
 *  forwarding  [n]
 *  exceptions  [n]
 */

/* Exceptions:
 * instruction-address-misaligned (IALIGH=32)
 * instruction-illegal (think in IF if PC[1:0] != 0) /// TODO: <--
 */

`define SIMULATION


module ch0re_pipeline5st #(
	parameter IMEM_DEPTH = 2048,
	parameter IMEM_ADDR_WIDTH = $clog2(IMEM_DEPTH),
	parameter IMEM_FILE = "codemem.dat",
	parameter DMEM_DEPTH = 2048,
	parameter DMEM_ADDR_WIDTH = $clog2(DMEM_DEPTH),
	parameter DMEM_FILE = "codemem.dat"
) (
	input logic clk,
	input logic rst_n
);

	localparam DMEM_DATA_WIDTH = 64;

	/* STAGE-1: 'IFETCH' */

	logic [63:0] REG_PC;
	logic [63:0] IFIDR;

	`define IFIDR_CURR_PC 0+:64

	logic [63:0] NEXT_PC;

	mem_sync_sp_intf #(
		.DEPTH(IMEM_DEPTH),
		.DATA_WIDTH(32)
		// .INIT_FILE(IMEM_FILE),
		// .INIT_START('h0)
		// .INIT_END('h160 - 1)
	) imem_intf (
		.clk(clk)
	);

	mem_sync_sp imem(imem_intf);

	always_ff @(posedge clk, negedge rst_n) begin : stage_1_if
		if (!rst_n) begin

			IFIDR <= 'b0;
			REG_PC <= 'b0;

		end
		else begin

			IFIDR[`IFIDR_CURR_PC] <= REG_PC;
			REG_PC <= NEXT_PC;

		end
	end : stage_1_if

	always_comb begin

		NEXT_PC = REG_PC + 'h4;  /// TODO: add mux from stage-3 and stage-2
		imem_intf.i_addr = REG_PC[0 +: IMEM_ADDR_WIDTH] >> 2;

	end


	/* STAGE-2: 'IDECODE' */

	logic [337:0] IDEXR;

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

	regfile_2r1w_intf #(
		.DATA_WIDTH(64)
	) rf_intf (
		.clk(clk)
	);

	regfile_2r1w regfile(rf_intf);
	ch0re_idecoder_intf idec_intf();
	ch0re_idecoder idec(idec_intf);

	always_ff @(posedge clk, negedge rst_n) begin : stage_2_id

		if (!rst_n) begin
			IDEXR <= 'b0;
		end
		else begin

			// idec_intf.o_illegal_instr (future: precise exceptions?)

			if (idec_intf.o_rf_raddr1)
				IDEXR[`IDEXR_RS1] <= rf_intf.o_rdata1;
			else
				IDEXR[`IDEXR_RS1] <= 'b0;

			if (idec_intf.o_rf_raddr2)
				IDEXR[`IDEXR_RS2] <= rf_intf.o_rdata2;
			else
				IDEXR[`IDEXR_RS2] <= 'b0;

			IDEXR[`IDEXR_PC] <= IFIDR[`IFIDR_CURR_PC];
			IDEXR[`IDEXR_RD] <= idec_intf.o_rf_waddr;

			IDEXR[`IDEXR_IMM] <= idec_intf.o_imm;
			IDEXR[`IDEXR_ALU_OP] <= idec_intf.o_alu_op;
			IDEXR[`IDEXR_ALU_MUX1_SEL] <= idec_intf.o_alu_mux1_sel;
			IDEXR[`IDEXR_ALU_MUX2_SEL] <= idec_intf.o_alu_mux2_sel;

			IDEXR[`IDEXR_DATA_TYPE] <= idec_intf.o_data_type;
			IDEXR[`IDEXR_BRANCH_TARGET] <= IFIDR[`IFIDR_CURR_PC] + idec_intf.o_imm;
			IDEXR[`IDEXR_LSU_OP] <= idec_intf.o_lsu_op;
			IDEXR[`IDEXR_WEN] <= idec_intf.o_wen;

		end

	end : stage_2_id

	always_comb begin

		idec_intf.i_instr = imem_intf.o_rdata;

		rf_intf.i_raddr1 = idec_intf.o_rf_raddr1;
		rf_intf.i_raddr2 = idec_intf.o_rf_raddr2;

	end


	/* STAGE-3: 'EXECUTE' */

	logic [138:0] EXMEMR;

	`define EXMEMR_ALU_OUT   0+:64
	`define EXMEMR_RS2	     64+:64
	`define EXMEMR_RD	     128+:5
	`define EXMEMR_LSU_OP    133+:2
	`define EXMEMR_DATA_TYPE 135+:3
	`define EXMEMR_WEN       138+:1

	ch0re_alu_intf alu_intf();
	ch0re_alu alu(alu_intf);

	always_ff @(posedge clk, negedge rst_n) begin : stage_3_ex

		if (!rst_n) begin
			EXMEMR <= 'b0;
		end
		else begin

			EXMEMR[`EXMEMR_ALU_OUT] <= alu_intf.o_res;
			EXMEMR[`EXMEMR_RS2] <= IDEXR[`IDEXR_RS2];
			EXMEMR[`EXMEMR_RD] <= IDEXR[`IDEXR_RD];
			EXMEMR[`EXMEMR_LSU_OP] <= IDEXR[`IDEXR_LSU_OP];
			EXMEMR[`EXMEMR_DATA_TYPE] <= IDEXR[`IDEXR_DATA_TYPE];
			EXMEMR[`EXMEMR_WEN] <= IDEXR[`IDEXR_WEN];

		end
	end : stage_3_ex

	always_comb begin

		/// TODO: add ALU muxes!!!

		alu_intf.i_op = IDEXR[`IDEXR_ALU_OP];
		alu_intf.i_s1 = IDEXR[`IDEXR_RS1];
		alu_intf.i_s2 = IDEXR[`IDEXR_RS2];

		unique case (IDEXR[`IDEXR_ALU_MUX1_SEL])

			ALU_MUX1_SEL_PC: begin
				alu_intf.i_s1 = IDEXR[`IDEXR_PC];
				alu_intf.i_s2 = 'h4;
			end

			ALU_MUX1_SEL_IMM_ZERO: begin
				alu_intf.i_s1 = 'h0;
				alu_intf.i_s2 = IDEXR[`IDEXR_IMM];
			end

			ALU_MUX1_SEL_REG: begin

				alu_intf.i_s1 = IDEXR[`IDEXR_RS1];

				if (IDEXR[`IDEXR_ALU_MUX2_SEL] == ALU_MUX2_SEL_REG) begin
					alu_intf.i_s2 = IDEXR[`IDEXR_RS2];
				end
				else begin // imm
					alu_intf.i_s2 = IDEXR[`IDEXR_IMM];
				end

			end

			ALU_MUX1_SEL_FWD: begin

				alu_intf.i_s1 = 'h0;
				alu_intf.i_s2 = 'h0;
				assert(1'b0) else $fatal("Not yet implemented!\n");

			end

		endcase

	end


	/* STAGE-4: 'MEMORY' */

	logic [74:0] MEMWBR;

	`define MEMWBR_ALU_OUT   0+:64
	`define MEMWBR_LSU_OP    64+:2
	`define MEMWBR_RD        66+:5
	`define MEMWBR_WEN       71+:1
	`define MEMWBR_DATA_TYPE 72+:3

	logic new_wen;

	mem_sync_sp_rvdmem_intf #(
		.DATA_WIDTH(DMEM_DATA_WIDTH)
	) dmem_intf (
		.clk(clk)
	);

	mem_sync_sp_rvdmem dmem(dmem_intf);

	always_ff @(posedge clk, negedge rst_n) begin : stage_4_mem

		if (!rst_n) begin
			MEMWBR <= 'b0;
		end
		else begin

			MEMWBR[`MEMWBR_ALU_OUT] <= EXMEMR[`EXMEMR_ALU_OUT];
			MEMWBR[`MEMWBR_LSU_OP] <= EXMEMR[`EXMEMR_LSU_OP];
			MEMWBR[`MEMWBR_RD] <= EXMEMR[`EXMEMR_RD];
			MEMWBR[`MEMWBR_WEN] <= new_wen;
			MEMWBR[`MEMWBR_DATA_TYPE] <= EXMEMR[`EXMEMR_DATA_TYPE];

		end

	end : stage_4_mem

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

	logic [63:0] wb_data;
	logic [63:0] read_data;

	assign read_data = dmem_intf.o_rdata;

	always_comb begin : stage_5_wb

		if (MEMWBR[`MEMWBR_LSU_OP] == LSU_LOAD) begin

			unique case (MEMWBR[`MEMWBR_DATA_TYPE])

				DTYPE_BYTE: wb_data = {{57{read_data[7]}}, read_data[6:0]};
				DTYPE_HALF: wb_data = {{49{read_data[15]}}, read_data[14:0]};
				DTYPE_WORD: wb_data = {{33{read_data[31]}}, read_data[30:0]};
				DTYPE_DOUBLE: wb_data = read_data;

				DTYPE_BYTEU: wb_data = {{56{1'b0}}, read_data[7:0]};
				DTYPE_HALFU: wb_data = {{48{1'b0}}, read_data[15:0]};
				DTYPE_WORDU: wb_data = {{32{1'b0}}, read_data[31:0]};

			endcase

		end
		else begin
			wb_data = MEMWBR[`MEMWBR_ALU_OUT];
		end

		if (MEMWBR[`MEMWBR_RD])
			rf_intf.i_wen = MEMWBR[`MEMWBR_WEN];
		else
			rf_intf.i_wen = 'b0;

		rf_intf.i_waddr = MEMWBR[`MEMWBR_RD];
		rf_intf.i_wdata = wb_data;

	end : stage_5_wb

endmodule: ch0re_pipeline5st

