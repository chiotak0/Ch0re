`timescale 1ns/100ps

`include "ch0re_types.sv"
`include "debug_prints.sv"

`define TOTAL_OPGEN 50
typedef enum logic [5:0] {

	/* R-FORMAT */

	OPGEN_ADD,
	OPGEN_SUB,
	OPGEN_XOR,
	OPGEN_OR,
	OPGEN_AND,
	OPGEN_SLL,
	OPGEN_SRL,
	OPGEN_SRA,
	OPGEN_SLT,
	OPGEN_SLTU,

	OPGEN_ADDW,
	OPGEN_SUBW,
	OPGEN_SLLW,
	OPGEN_SRLW,
	OPGEN_SRAW,

	/* I-FORMAT */

	OPGEN_ADDI,
	OPGEN_XORI,
	OPGEN_ORI,
	OPGEN_ANDI,
	OPGEN_SLLI,
	OPGEN_SRLI,
	OPGEN_SRAI,
	OPGEN_SLTI,
	OPGEN_SLTIU,

	OPGEN_ADDIW,
	OPGEN_SLLIW,
	OPGEN_SRLIW,
	OPGEN_SRAIW,

	OPGEN_LB,
	OPGEN_LH,
	OPGEN_LW,
	OPGEN_LD,
	OPGEN_LBU,
	OPGEN_LHU,
	OPGEN_LWU,

	OPGEN_JALR,

	/* S-FORMAT */

	OPGEN_SB,
	OPGEN_SH,
	OPGEN_SW,
	OPGEN_SD,

	/* B-FORMAT */

	OPGEN_BEQ,
	OPGEN_BNE,
	OPGEN_BLT,
	OPGEN_BGE,
	OPGEN_BLTU,
	OPGEN_BGEU,

	/* J-FORMAT */

	OPGEN_JAL,

	/* U-FORMAT */

	OPGEN_LUI,
	OPGEN_AUIPC,

	/* ILLEGAL */

	OPGEN_ILLEGAL
} opcode_gen_e;

typedef enum logic [4:0] {
	REG_X0_ZERO  = 0,
	REG_X1_RA    = 1,
	REG_X2_SP    = 2,
	REG_X3_GP    = 3,
	REG_X4_TP    = 4,

	REG_X10_A0   = 10,
	REG_X11_A1   = 11,
	REG_X12_A2   = 12,
	REG_X13_A3   = 13,
	REG_X14_A4   = 14,
	REG_X15_A5   = 15,
	REG_X16_A6   = 16,
	REG_X17_A7   = 17,

	REG_X8_S0_FP = 8,
	REG_X9_S1    = 9,
	REG_X18_S2   = 18,
	REG_X19_S3   = 19,
	REG_X20_S4   = 20,
	REG_X21_S5   = 21,
	REG_X22_S6   = 22,
	REG_X23_S7   = 23,
	REG_X24_S8   = 24,
	REG_X25_S9   = 25,
	REG_X26_S10  = 26,
	REG_X27_S11  = 27,

	REG_X5_T0    = 5,
	REG_X6_T1    = 6,
	REG_X7_T2    = 7,
	REG_X28_T3   = 28,
	REG_X29_T4   = 29,
	REG_X30_T5   = 30,
	REG_X31_T6   = 31
} reg_e;

typedef struct {
	opcode_gen_e op;
	iformat_e fmt;
	bit [20:0] imm;

	reg_e rs1;
	reg_e rs2;
	reg_e rd;
} instruction_t;

`define IGNORE_REG REG_X0_ZERO
`define IGNORE_IMM 20'h0

`define IGNORE_F7 7'h00
`define IGNORE_F3 3'h0

`define OPCODE   6:0
`define RD       11:7
`define FUNC3    14:12
`define RS1      19:15
`define RS2      24:20
`define FUNC7    31:25
`define IMM_I    31:20
`define IMM_S_L `RD
`define IMM_S_H `FUNC7
`define IMM_B_L `RD
`define IMM_B_H `FUNC7
`define IMM_U    31:12
`define IMM_J   `IMM_U

`define GET_FUNC7(array, op) array[op][14:8]
`define GET_FUNC3(array, op) array[op][7:5]
`define GET_OPCODE(array, op) array[op][4:0]

module tb_idecoder();

	logic [17:0] iinfo [0:`TOTAL_OPGEN - 1] = {

		/* R-FORMAT */

		{IFORMAT_R, 7'h00, 3'h0, OPCODE_OP}, // add
		{IFORMAT_R, 7'h20, 3'h0, OPCODE_OP}, // sub
		{IFORMAT_R, 7'h00, 3'h4, OPCODE_OP}, // xor
		{IFORMAT_R, 7'h00, 3'h6, OPCODE_OP}, // or
		{IFORMAT_R, 7'h00, 3'h7, OPCODE_OP}, // and
		{IFORMAT_R, 7'h00, 3'h1, OPCODE_OP}, // sll
		{IFORMAT_R, 7'h00, 3'h5, OPCODE_OP}, // srl
		{IFORMAT_R, 7'h20, 3'h5, OPCODE_OP}, // sra
		{IFORMAT_R, 7'h00, 3'h2, OPCODE_OP}, // slt
		{IFORMAT_R, 7'h00, 3'h3, OPCODE_OP}, // sltu

		{IFORMAT_R, 7'h00, 3'h0, OPCODE_OP32}, // addw
		{IFORMAT_R, 7'h20, 3'h0, OPCODE_OP32}, // subw
		{IFORMAT_R, 7'h00, 3'h1, OPCODE_OP32}, // sllw
		{IFORMAT_R, 7'h00, 3'h5, OPCODE_OP32}, // srlw
		{IFORMAT_R, 7'h20, 3'h5, OPCODE_OP32}, // sraw

		/* I-FORMAT */

		{IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_OP_IMM}, // addi
		{IFORMAT_I, `IGNORE_F7, 3'h4, OPCODE_OP_IMM}, // xori
		{IFORMAT_I, `IGNORE_F7, 3'h6, OPCODE_OP_IMM}, // ori
		{IFORMAT_I, `IGNORE_F7, 3'h7, OPCODE_OP_IMM}, // andi
		{IFORMAT_I,    6'h00  , 3'h1, OPCODE_OP_IMM}, // slli --rv64
		{IFORMAT_I,    6'h00  , 3'h5, OPCODE_OP_IMM}, // srli --rv64
		{IFORMAT_I,    6'h10  , 3'h0, OPCODE_OP_IMM}, // srai --rv64
		{IFORMAT_I, `IGNORE_F7, 3'h2, OPCODE_OP_IMM}, // slti
		{IFORMAT_I, `IGNORE_F7, 3'h3, OPCODE_OP_IMM}, // sltu

		{IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_OP_IMM32}, // addiw
		{IFORMAT_I,    7'h00  , 3'h1, OPCODE_OP_IMM32}, // slliw
		{IFORMAT_I,    7'h00  , 3'h5, OPCODE_OP_IMM32}, // srliw
		{IFORMAT_I,    7'h20  , 3'h5, OPCODE_OP_IMM32}, // sraiw

		{IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_LOAD}, // lb
		{IFORMAT_I, `IGNORE_F7, 3'h1, OPCODE_LOAD}, // lh
		{IFORMAT_I, `IGNORE_F7, 3'h2, OPCODE_LOAD}, // lw
		{IFORMAT_I, `IGNORE_F7, 3'h3, OPCODE_LOAD}, // ld
		{IFORMAT_I, `IGNORE_F7, 3'h4, OPCODE_LOAD}, // lbu
		{IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_LOAD}, // lhu
		{IFORMAT_I, `IGNORE_F7, 3'h6, OPCODE_LOAD}, // lwu

		{IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_JALR}, // jalr

		/* S-FORMAT */

		{IFORMAT_S, `IGNORE_F7, 3'h0, OPCODE_STORE}, // sb
		{IFORMAT_S, `IGNORE_F7, 3'h1, OPCODE_STORE}, // sh
		{IFORMAT_S, `IGNORE_F7, 3'h2, OPCODE_STORE}, // sw
		{IFORMAT_S, `IGNORE_F7, 3'h3, OPCODE_STORE}, // sd

		/* B-FORMAT */

		{IFORMAT_B, `IGNORE_F7, 3'h0, OPCODE_BRANCH}, // beq
		{IFORMAT_B, `IGNORE_F7, 3'h1, OPCODE_BRANCH}, // bne
		{IFORMAT_B, `IGNORE_F7, 3'h4, OPCODE_BRANCH}, // blt
		{IFORMAT_B, `IGNORE_F7, 3'h5, OPCODE_BRANCH}, // bge
		{IFORMAT_B, `IGNORE_F7, 3'h6, OPCODE_BRANCH}, // bltu
		{IFORMAT_B, `IGNORE_F7, 3'h7, OPCODE_BRANCH}, // bgeu

		/* J-FORMAT */

		{IFORMAT_J, `IGNORE_F7, `IGNORE_F3, OPCODE_JAL}, // jal

		/* U-FORMAT */

		{IFORMAT_U, `IGNORE_F7, `IGNORE_F3, OPCODE_LUI},  // lui
		{IFORMAT_U, `IGNORE_F7, `IGNORE_F3, OPCODE_AUIPC}, // aupc

		/* ILLEGAL */

		{IFORMAT_R, `IGNORE_F7, 3'h7, OPCODE_LOAD} // load?
	};

	instruction_t g_instr;

	idecoder_intf idec_intf();
	idecoder dut(idec_intf);

	/// TODO: make an "instruction" class

	initial begin

		g_instr.op = OPGEN_ADDI;
		g_instr.rd = REG_X1_RA;
		g_instr.rs1 = REG_X0_ZERO;
		g_instr.imm = 20'h3;
		g_instr.rs2 = `IGNORE_REG;

		generate_instr();

		#5
		check_dec_instr();

		#5
		g_instr.op = OPGEN_LWU;
		g_instr.rd = REG_X31_T6;
		g_instr.rs1 = REG_X16_A6;
		g_instr.imm = 20'h32;
		g_instr.rs2 = `IGNORE_REG;

		generate_instr();

		#5
		check_dec_instr();

		#5
		g_instr.op = OPGEN_SUB;
		g_instr.rd = REG_X2_SP;
		g_instr.rs1 = REG_X3_GP;
		g_instr.rs2 = REG_X5_T0;

		generate_instr();

		#5
		check_dec_instr();

		#5
		g_instr.op = OPGEN_ILLEGAL;

		generate_instr();

		#5
		check_dec_instr();

		#5
		$finish();

	end

	task generate_instr(/** TODO: inputs, more clear */);

		$display({"[", `DBP_BOLD, `DBP_FYELL, "TASK", `DBP_RST, "]: ", `DBP_DIM, "%m", `DBP_RST, "\n"});
		$display("\tGenerating '%0s'\n", g_instr.op.name());

		idec_intf.i_instr[`OPCODE] = {`GET_OPCODE(iinfo, g_instr.op), 2'b11};

		if (g_instr.op < OPGEN_ADDI) begin : R_FORMAT
			idec_intf.i_instr[`RD]    = g_instr.rd;
			idec_intf.i_instr[`FUNC3] = `GET_FUNC3(iinfo, g_instr.op);
			idec_intf.i_instr[`RS1]   = g_instr.rs1;
			idec_intf.i_instr[`RS2]   = g_instr.rs2;
			idec_intf.i_instr[`FUNC7] = `GET_FUNC7(iinfo, g_instr.op);
		end
		else if (g_instr.op < OPGEN_SB) begin : I_FORMAT
			idec_intf.i_instr[`RD]    = g_instr.rd;
			idec_intf.i_instr[`FUNC3] = `GET_FUNC3(iinfo, g_instr.op);
			idec_intf.i_instr[`RS1]   = g_instr.rs1;
			idec_intf.i_instr[`IMM_I] = g_instr.imm[11:0];
		end
		else if (g_instr.op < OPGEN_BEQ) begin : S_FORMAT
			idec_intf.i_instr[`IMM_S_L] = g_instr.imm[4:0];
			idec_intf.i_instr[`FUNC3]   = `GET_FUNC3(iinfo, g_instr.op);
			idec_intf.i_instr[`RS1]     = g_instr.rs1;
			idec_intf.i_instr[`RS2]     = g_instr.rs2;
			idec_intf.i_instr[`IMM_S_H] = g_instr.imm[11:5];
		end
		else if (g_instr.op < OPGEN_JAL) begin : B_FORMAT
			idec_intf.i_instr[`IMM_B_L] = {g_instr.imm[4:1], g_instr.imm[11]};
			idec_intf.i_instr[`RS1]     = g_instr.rs1;
			idec_intf.i_instr[`FUNC3]   = `GET_FUNC3(iinfo, g_instr.op);
			idec_intf.i_instr[`RS2]     = g_instr.rs2;
			idec_intf.i_instr[`IMM_B_H] = {g_instr.imm[12], g_instr.imm[10:5]};
		end
		else if (g_instr.op == OPGEN_JAL) begin : J_FORMAT
			idec_intf.i_instr[`RD]    = g_instr.rd;
			idec_intf.i_instr[`IMM_J] = {g_instr.imm[20], g_instr.imm[10:1], g_instr.imm[11], g_instr.imm[19:12]};
		end
		else if (g_instr.op < OPGEN_ILLEGAL) begin : U_FORMAT
			idec_intf.i_instr[`RD]    = g_instr.rd;
			idec_intf.i_instr[`IMM_U] = g_instr.imm;
		end
		else if (g_instr.op == OPGEN_ILLEGAL) begin : ILLEGAL
			// faulted 'load'
			idec_intf.i_instr[`RD]    = g_instr.rd;
			idec_intf.i_instr[`FUNC3] = `GET_FUNC3(iinfo, g_instr.op);
			idec_intf.i_instr[`RS1]   = g_instr.rs1;
			idec_intf.i_instr[`IMM_I] = g_instr.imm[11:0];
		end
		else begin

			assert(1'b0) else $finish();
		end

		$display({`DBP_SUCCESS, "\n"});

	endtask : generate_instr

	task check_dec_instr();

		$display({"[", `DBP_BOLD, `DBP_FYELL, "TASK", `DBP_RST, "]: ", `DBP_DIM, "%m", `DBP_RST});

		if (g_instr.op < OPGEN_ADDI) begin : R_FORMAT
			assert(
				!idec_intf.o_illegal_instr &&
				idec_intf.o_rf_raddr1 == g_instr.rs1 &&
				idec_intf.o_rf_raddr2 == g_instr.rs2 &&
				idec_intf.o_rf_waddr == g_instr.rd &&
				idec_intf.o_instr_format == IFORMAT_R &&
				idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_REG &&
				idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_REG
			) else begin
				print_dut_output();
				$display();
				print_instr_binary();
				$fatal();
			end
		end
		else if (g_instr.op < OPGEN_SB) begin : I_FORMAT
			assert(
				!idec_intf.o_illegal_instr &&
				idec_intf.o_rf_raddr1 == g_instr.rs1 &&
				idec_intf.o_rf_waddr == g_instr.rd &&
				idec_intf.o_instr_format == IFORMAT_I &&
				idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_REG &&
				idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM
			) else begin
				print_dut_output();
				$display();
				print_instr_binary();
				$fatal();
			end
		end
		else if (g_instr.op < OPGEN_BEQ) begin : S_FORMAT
			assert(
				!idec_intf.o_illegal_instr &&
				idec_intf.o_rf_raddr1 == g_instr.rs1 &&
				idec_intf.o_rf_raddr2 == g_instr.rs2 &&
				idec_intf.o_instr_format == IFORMAT_S &&
				idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_REG &&
				idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM
			) else begin
				print_dut_output();
				$display();
				print_instr_binary();
				$fatal();
			end
		end
		else if (g_instr.op < OPGEN_JAL) begin : B_FORMAT
			assert(
				!idec_intf.o_illegal_instr &&
				idec_intf.o_rf_raddr1 == g_instr.rs1 &&
				idec_intf.o_rf_raddr2 == g_instr.rs2 &&
				idec_intf.o_instr_format == IFORMAT_B &&
				idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_REG &&
				idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_REG
			) else begin
				print_dut_output();
				$display();
				print_instr_binary();
				$fatal();
			end
		end
		else if (g_instr.op == OPGEN_JAL) begin : J_FORMAT
			assert(
				!idec_intf.o_illegal_instr &&
				idec_intf.o_rf_waddr == g_instr.rd &&
				idec_intf.o_instr_format == IFORMAT_J &&
				idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_PC &&
				idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM
			) else begin
				print_dut_output();
				$display();
				print_instr_binary();
				$fatal();
			end
		end
		else if (g_instr.op == OPGEN_LUI) begin : U_FORMAT_LUI
			assert(
				!idec_intf.o_illegal_instr &&
				idec_intf.o_rf_waddr == g_instr.rd &&
				idec_intf.o_instr_format == IFORMAT_U &&
				idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_IMM &&  // zero
				idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM     // idec_intf.imm
			) else begin
				print_dut_output();
				$display();
				print_instr_binary();
				$fatal();
			end
		end
		else if (g_instr.op == OPGEN_AUIPC) begin : U_FORMAT_AUIPC
			assert(
				!idec_intf.o_illegal_instr &&
				idec_intf.o_rf_waddr == g_instr.rd &&
				idec_intf.o_instr_format == IFORMAT_U &&
				idec_intf.o_alu_mux1_sel == ALU_MUX1_SEL_PC &&
				idec_intf.o_alu_mux2_sel == ALU_MUX2_SEL_IMM
			) else begin
				print_dut_output();
				$display();
				print_instr_binary();
				$fatal();
			end
		end
		else if (g_instr.op == OPGEN_ILLEGAL) begin : ILLEGAL
			assert(
				idec_intf.o_illegal_instr
			) else begin
				print_dut_output();
				$display();
				print_instr_binary();
				$fatal();
			end
		end

		$display({`DBP_SUCCESS, "\n"});

	endtask : check_dec_instr

	task check_all_instructions();  // Under Construction

		for (int i = OPGEN_ADD; i <= OPGEN_ILLEGAL; ++i) begin
			g_instr.op = opcode_gen_e'(i);
			g_instr.fmt = iinfo[g_instr.op][17:15];
			// if I gen this
			// if R gen that
			// etc (random registers)
		end

	endtask : check_all_instructions

	task print_instr_binary();

		$display("opcode = %7b", idec_intf.i_instr[6:0]);

		if (g_instr.op < OPGEN_ADDI) begin : R_FORMAT
			$display("rd     = %5b", idec_intf.i_instr[11:7]);
			$display("func3  = %3b", idec_intf.i_instr[14:12]);
			$display("rs1    = %5b", idec_intf.i_instr[19:15]);
			$display("rs2    = %5b", idec_intf.i_instr[24:20]);
			$display("func7  = %7b", idec_intf.i_instr[31:25]);
		end
		else if (g_instr.op < OPGEN_SB) begin : I_FORMAT
			$display("rd     = %5b", idec_intf.i_instr[11:7]);
			$display("func3  = %3b", idec_intf.i_instr[14:12]);
			$display("rs1    = %5b", idec_intf.i_instr[19:15]);
			$display("idec_intf.imm    = h%12h", idec_intf.i_instr[31:20]);
		end
		else if (g_instr.op < OPGEN_JAL) begin : S_B_FORMAT
			$display("immlo  = %5b", idec_intf.i_instr[11:7]);
			$display("func3  = %3b", idec_intf.i_instr[14:12]);
			$display("rs1    = %5b", idec_intf.i_instr[19:15]);
			$display("rs2    = %5b", idec_intf.i_instr[24:20]);
			$display("immhi  = %7b", idec_intf.i_instr[31:25]);
		end
		else if (g_instr.op < OPGEN_ILLEGAL) begin : J_U_FORMAT
			$display("rd     = %5b", idec_intf.i_instr[11:7]);
			$display("idec_intf.imm    = %20h", idec_intf.i_instr[31:12]);
		end
		else if (g_instr.op == OPGEN_ILLEGAL) begin : ILLEGAL
			$display("func3 = %3b", idec_intf.i_instr[14:12]);
		end
		else begin
			assert(1'b0) else $finish();
		end

	endtask : print_instr_binary

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

