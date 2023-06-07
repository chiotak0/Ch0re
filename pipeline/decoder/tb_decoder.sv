import ch0re_types::*;

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
	OPGEN_LW
	OPGEN_LD
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
	OPGEN_AUIPC

	/* ILLEGAL */

	OPGEN_ILLEGAL
} opcode_gen_e;

typedef enum logic [5:0] {
	REG_x0_ZERO  = 0,
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
	REG_X31_T6   = 31,
} reg_e;

typedef struct {
	opcode_gen_e op;
	bit [20:0] imm;

	reg_e rs1;
	reg_e rs2;
	reg_e rd;
} instruction_t;

`define IGNORE_REG 5'h0
`define IGNORE_IMM 20'h0

`define IGNORE_F7 7'h00
`define IGNORE_F3 3'h0

`define OPCODE  6:0
`define RD      11:7
`define FUNC3   14:12
`define RS1     19:15
`define RS2     24:20
`define FUNC7   31:25
`define IMM_I   31:20
`define IMM_S_L `RD
`define IMM_S_H `FUNC7
`define IMM_B_L `RD
`define IMM_B_H `FUNC7
`define IMM_U   31:12
`define IMM_J   `IMM_U

`define GET_FUNC7(array, op) array[op][14:8]
`define `GET_FUNC3(array, op) array[op][7:5]
`define GET_OPCODE(array, op) array[op][4:0]

module tb_decoder();

	logic [14:0] iinfo [`TOTAL_OPGEN - 1:0] = {

		/* R-FORMAT */

		{7'h00, 3'h0, OPCODE_OP}, // add
		{7'h20, 3'h0, OPCODE_OP}, // sub
		{7'h00, 3'h4, OPCODE_OP}, // xor
		{7'h00, 3'h6, OPCODE_OP}, // or
		{7'h00, 3'h7, OPCODE_OP}, // and
		{7'h00, 3'h1, OPCODE_OP}, // sll
		{7'h00, 3'h5, OPCODE_OP}, // srl
		{7'h20, 3'h5, OPCODE_OP}, // sra
		{7'h00, 3'h2, OPCODE_OP}, // slt
		{7'h00, 3'h3, OPCODE_OP}, // sltu

		{7'h00, 3'h0, OPCODE_OP32}, // addw
		{7'h20, 3'h0, OPCODE_OP32}, // subw
		{7'h00, 3'h1, OPCODE_OP32}, // sllw
		{7'h00, 3'h5, OPCODE_OP32}, // srlw
		{7'h20, 3'h5, OPCODE_OP32}, // sraw

		/* I-FORMAT */

		{`IGNORE_F7, 3'h0, OPCODE_OP_IMM}, // addi
		{`IGNORE_F7, 3'h4, OPCODE_OP_IMM}, // xori
		{`IGNORE_F7, 3'h6, OPCODE_OP_IMM}, // ori
		{`IGNORE_F7, 3'h7, OPCODE_OP_IMM}, // andi
		{   6'h00  , 3'h1, OPCODE_OP_IMM}, // slli --rv64
		{   6'h00  , 3'h5, OPCODE_OP_IMM}, // srli --rv64
		{   6'h10  , 3'h0, OPCODE_OP_IMM}, // srai --rv64
		{`IGNORE_F7, 3'h2, OPCODE_OP_IMM}, // slti
		{`IGNORE_F7, 3'h3, OPCODE_OP_IMM}, // sltu

		{`IGNORE_F7, 3'h0, OPCODE_OP_IMM32}, // addiw
		{   7'h00  , 3'h1, OPCODE_OP_IMM32}, // slliw
		{   7'h00  , 3'h5, OPCODE_OP_IMM32}, // srliw
		{   7'h20  , 3'h5, OPCODE_OP_IMM32}, // sraiw

		{`IGNORE_F7, 3'h0, OPCODE_LOAD}, // lb
		{`IGNORE_F7, 3'h1, OPCODE_LOAD}, // lh
		{`IGNORE_F7, 3'h2, OPCODE_LOAD}, // lw
		{`IGNORE_F7, 3'h3, OPCODE_LOAD}, // ld
		{`IGNORE_F7, 3'h4, OPCODE_LOAD}, // lbu
		{`IGNORE_F7, 3'h5, OPCODE_LOAD}, // lhu
		{`IGNORE_F7, 3'h6, OPCODE_LOAD}, // lwu

		{`IGNORE_F7, 3'h0, OPCODE_JALR}, // jalr

		/* S-FORMAT */

		{`IGNORE_F7, 3'h0, OPCODE_STORE}, // sb
		{`IGNORE_F7, 3'h1, OPCODE_STORE}, // sh
		{`IGNORE_F7, 3'h2, OPCODE_STORE}, // sw
		{`IGNORE_F7, 3'h3, OPCODE_STORE}, // sd

		/* B-FORMAT */

		{`IGNORE_F7, 3'h0, OPCODE_BRANCH}, // beq
		{`IGNORE_F7, 3'h1, OPCODE_BRANCH}, // bne
		{`IGNORE_F7, 3'h4, OPCODE_BRANCH}, // blt
		{`IGNORE_F7, 3'h5, OPCODE_BRANCH}, // bge
		{`IGNORE_F7, 3'h6, OPCODE_BRANCH}, // bltu
		{`IGNORE_F7, 3'h7, OPCODE_BRANCH}, // bgeu

		/* J-FORMAT */

		{`IGNORE_F7, `IGNORE_F3, OPCODE_JAL}, // jal

		/* U-FORMAT */

		{`IGNORE_F7, `IGNORE_F3, OPCODE_LUI},  // lui
		{`IGNORE_F7, `IGNORE_F3, OPCODE_AUIPC} // aupc

		/* ILLEGAL */

		{`IGNORE_F7, 3'h7, OPCODE_LOAD} // load?
	};

	instruction_t __instr;

	logic [31:0] instr;
	logic illegal_instr;

	logic [4:0] rf_raddr1;
	logic [4:0] rf_raddr2;
	logic [4:0] rf_waddr;

	logic [63:0] imm;
	iformat_e instr_format;
	alu_op_e alu_op;
	alu_mux1_sel_e alu_mux1_sel;
	alu_mux2_sel_e alu_mux2_sel;

	data_type_e data_type;

	decoder dut (
		.i_instr(inst),

		.o_illegal_instr(illegal_instr),

		.o_rf_raddr1(rf_raddr1),
		.o_rf_raddr2(rf_raddr2),
		.o_rf_waddr(rf_waddr),

		.o_imm(imm),
		.o_instr_format(instr_format),
		.o_alu_op(alu_op),
		.o_alu_mux1_sel(alu_mux1_sel),
		.o_alu_mux2_sel(alu_mux2_sel),

		.o_data_type(data_type)
	)

	initial begin

		__instr.op = OPGEN_ADDI;
		__instr.rd = REG_X1_RA
		__instr.rs1 = REG_X0_RA;
		__instr.imm = 20'h3;
		__instr.rs2 = `IGNORE_REG;

		generate_instr(__instr);
		check_dec_instr(__instr);

		//

	end

	task generate_instr(input instruction_t i_instr);

		$display("[" `DBP_BOLD `DBP_FYELL "TASK" `DBP_RST "]: " `DBP_DIM "%m" `DBP_RST "\n");
		$display("\tGenerating '%0s'\n", i_instr.op.name())

		instr[`OPCODE] = {`GET_OPCODE(iinfo, i_instr.op), 2'b11};

		if (i_instr.op < OPGEN_ADDI) begin : R_FORMAT
			instr[`RD]    = i_instr.rd;
			instr[`FUNC3] = `GET_FUNC3(iinfo, i_instr.op);
			instr[`RS1]   = i_instr.rs1;
			instr[`RS2]   = i_instr.rs2;
			instr[`FUNC7] = `GET_FUNC7(iinfo, i_instr.op);
		end
		else if (i_instr.op < OPGEN_SB) begin : I_FORMAT
			instr[`RD]    = i_instr.rd;
			instr[`FUNC3] = `GET_FUNC3(iinfo, i_instr.op);
			instr[`RS1]   = i_instr.rs1;
			instr[`IMM_I] = i_instr.imm[11:0];
		end
		else if (i_instr.op < OPGEN_BEQ) begin : S_FORMAT
			instr[`IMM_S_L] = i_instr.imm[4:0]
			instr[`FUNC3]   = `GET_FUNC3(iinfo, i_instr.op);
			instr[`RS1]     = i_instr.rs1;
			instr[`RS2]     = i_instr.rs2;
			instr[`IMM_S_H] = i_instr.imm[11:5];
		end
		else if (i_instr.op < OPGEN_JAL) begin : B_FORMAT
			instr[`IMM_B_L] = {i_instr.imm[4:1], i_instr.imm[11]};
			instr[`RS1]     = i_instr.rs1;
			instr[`FUNC3]   = `GET_FUNC3(iinfo, i_instr.op);
			instr[`RS2]     = i_instr.rs2;
			instr[`IMM_B_H] = {i_instr.imm[12], i_instr.imm[10:5]};
		end
		else if (i_instr.op == OPGEN_JAL) begin : J_FORMAT
			instr[`RD]    = i_instr.rd;
			instr[`IMM_J] = {i_instr.imm[20], i_instr.imm[10:1], i_instr.imm[11], i_instr.imm[19:12]};
		end
		else if (i_instr.op < OPGEN_ILLEGAL) begin : U_FORMAT
			instr[`RD]    = i_instr.rd;
			instr[`IMM_U] = i_instr.imm;
		end
		else if (i_instr.op == OPGEN_ILLEGAL) begin : ILLEGAL
			// faulted 'load'
			instr[`RD]    = i_instr.rd;
			instr[`FUNC3] = `GET_FUNC3(iinfo, i_instr.op);
			instr[`RS1]   = i_instr.rs1;
			instr[`IMM_I] = i_instr.imm[11:0];
		end
		else begin

			assert(1'b0) else $finish();
		end

		$display(`DBP_SUCCESS "\n");

	endtask : generate_instr

	task check_dec_instr(input instruction_t i_instr);

		$display("[" `DBP_BOLD `DBP_FYELL "TASK" `DBP_RST "]: " `DBP_DIM "%m" `DBP_RST "\n");

		if (i_instr.op < OPGEN_ADDI) begin : R_FORMAT
			assert(
				!i_illegal_instr &&
				rf_raddr1 == i_instr.rs1 &&
				rf_raddr2 == i_instr.rs2 &&
				rf_waddr == i_instr.rd &&
				instr_format == IFORMAT_R &&
				alu_mux1_sel == ALU_MUX1_SEL_REG &&
				alu_mux2_sel == ALU_MUX2_SEL_REG
			) else begin
				print_dut_output();
				$finish();
			end
		end
		else if (i_instr.op < OPGEN_SB) begin : I_FORMAT
			assert(
				!i_illegal_instr &&
				rf_raddr1 == i_instr.rs1 &&
				rf_waddr == i_instr.rd &&
				instr_format == IFORMAT_I &&
				alu_mux1_sel == ALU_MUX1_SEL_REG &&
				alu_mux2_sel == ALU_MUX2_SEL_IMM
			) else begin
				print_dut_output();
				$finish();
			end
		end
		else if (i_instr.op < OPGEN_BEQ) begin : S_FORMAT
			assert(
				!i_illegal_instr &&
				rf_raddr1 == i_instr.rs1 &&
				rf_raddr2 == i_instr.rs2 &&
				instr_format == IFORMAT_S &&
				alu_mux1_sel == ALU_MUX1_SEL_REG &&
				alu_mux2_sel == ALU_MUX2_SEL_IMM
			) else begin
				print_dut_output();
				$finish();
			end
		end
		else if (i_instr.op < OPGEN_JAL) begin : B_FORMAT
			assert(
				!i_illegal_instr &&
				rf_raddr1 == i_instr.rs1 &&
				rf_raddr2 == i_instr.rs2 &&
				instr_format == IFORMAT_B &&
				alu_mux1_sel == ALU_MUX1_SEL_REG &&
				alu_mux2_sel == ALU_MUX2_SEL_REG
			) else begin
				print_dut_output();
				$finish();
			end
		end
		else if (i_instr.op == OPGEN_JAL) begin : J_FORMAT
			assert(
				!i_illegal_instr &&
				rf_waddr == i_instr.rd &&
				instr_format == IFORMAT_J &&
				alu_mux1_sel == ALU_MUX1_SEL_PC &&
				alu_mux2_sel == ALU_MUX2_SEL_IMM
			) else begin
				print_dut_output();
				$finish();
			end
		end
		else if (i_instr.op == OPGEN_LUI) begin : U_FORMAT
			assert(
				!i_illegal_instr &&
				rf_waddr == i_instr.rd &&
				instr_format == IFORMAT_U &&
				alu_mux1_sel == ALU_MUX1_SEL_IMM &&  // zero
				alu_mux2_sel == ALU_MUX2_SEL_IMM     // imm
			) else begin
				print_dut_output();
				$finish();
			end
		end
		else if (i_instr.op == OPGEN_AUIPC) begin : U_FORMAT
			assert(
				!i_illegal_instr &&
				rf_waddr == i_instr.rd &&
				instr_format == IFORMAT_U &&
				alu_mux1_sel == ALU_MUX1_SEL_PC &&
				alu_mux2_sel == ALU_MUX2_SEL_IMM
			) else begin
				print_dut_output();
				$finish();
			end
		end
		else if (i_instr.op == OPGEN_ILLEGAL) begin : ILLEGAL
			assert(
				illegal_instr
			) else begin
				print_dut_output();
				$finish();
			end
		end

		$display(`DBP_SUCCESS "\n");

	endtask : check_dec_instr

	task print_dut_output();

		$display("\tillegal_instr = b%0b\n", illegal_instr);
		$display("\trf_raddr1     = b%0b\n", rf_raddr1);
		$display("\trf_raddr2     = b%0b\n", rf_raddr2);
		$display("\trf_waddr      = b%0b\n", rf_waddr);

		$display("\n");

		$display("\t_instr_format = %s\n", instr_format.name());
		$display("\talu_op        = %s\n", alu_op.name());
		$display("\timm           = 0x%0x\n", imm);
		$display("\talu_mux1_sel  = %s\n", alu_mux1_sel.name());
		$display("\talu_mux2_sel  = %s\n", alu_mux2_sel.name());

	endtask : print_dut_output

endmodule : tb_decoder_id

