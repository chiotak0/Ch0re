`include "ch0re_types.sv"
`include "debug_prints.sv"

`define TOTAL_OPGEN 50

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

`define GET_IFMT(kva, key)   iformat_e'(kva[key][15+:3])
`define GET_FUNC7(kva, key)  kva[key][8+:7]
`define GET_FUNC3(kva, key)  kva[key][5+:3]
`define GET_OPCODE(kva, key) kva[key][0+:5]

`define EXIT_SUCCESS (0)
`define EXIT_FAILURE (-1)

class instruction_t;

	/* Instruction Binary Representation */

	local logic [31:0] binstr;

	/* instruction translation table */

	static const logic [17:0] itt [string] = '{

		/* R-FORMAT */

		"add"  : {IFORMAT_R, 7'h00, 3'h0, OPCODE_OP},
		"sub"  : {IFORMAT_R, 7'h20, 3'h0, OPCODE_OP},
		"xor"  : {IFORMAT_R, 7'h00, 3'h4, OPCODE_OP},
		"or"   : {IFORMAT_R, 7'h00, 3'h6, OPCODE_OP},
		"and"  : {IFORMAT_R, 7'h00, 3'h7, OPCODE_OP},
		"sll"  : {IFORMAT_R, 7'h00, 3'h1, OPCODE_OP},
		"srl"  : {IFORMAT_R, 7'h00, 3'h5, OPCODE_OP},
		"sra"  : {IFORMAT_R, 7'h20, 3'h5, OPCODE_OP},
		"slt"  : {IFORMAT_R, 7'h00, 3'h2, OPCODE_OP},
		"sltu" : {IFORMAT_R, 7'h00, 3'h3, OPCODE_OP},

		"addw" : {IFORMAT_R, 7'h00, 3'h0, OPCODE_OP32},
		"subw" : {IFORMAT_R, 7'h20, 3'h0, OPCODE_OP32},
		"sllw" : {IFORMAT_R, 7'h00, 3'h1, OPCODE_OP32},
		"srlw" : {IFORMAT_R, 7'h00, 3'h5, OPCODE_OP32},
		"sraw" : {IFORMAT_R, 7'h20, 3'h5, OPCODE_OP32},

		/* I-FORMAT */

		"addi" : {IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_OP_IMM},
		"xori" : {IFORMAT_I, `IGNORE_F7, 3'h4, OPCODE_OP_IMM},
		"ori"  : {IFORMAT_I, `IGNORE_F7, 3'h6, OPCODE_OP_IMM},
		"andi" : {IFORMAT_I, `IGNORE_F7, 3'h7, OPCODE_OP_IMM},
		"slli" : {IFORMAT_I, `IGNORE_F7, 3'h1, OPCODE_OP_IMM},
		"srli" : {IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_OP_IMM},
		"srai" : {IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_OP_IMM},
		"slti" : {IFORMAT_I, `IGNORE_F7, 3'h2, OPCODE_OP_IMM},
		"sltu" : {IFORMAT_I, `IGNORE_F7, 3'h3, OPCODE_OP_IMM},

		"addiw" : {IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_OP_IMM32},
		"slliw" : {IFORMAT_I, `IGNORE_F7, 3'h1, OPCODE_OP_IMM32},
		"srliw" : {IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_OP_IMM32},
		"sraiw" : {IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_OP_IMM32},

		"lb"  : {IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_LOAD},
		"lh"  : {IFORMAT_I, `IGNORE_F7, 3'h1, OPCODE_LOAD},
		"lw"  : {IFORMAT_I, `IGNORE_F7, 3'h2, OPCODE_LOAD},
		"ld"  : {IFORMAT_I, `IGNORE_F7, 3'h3, OPCODE_LOAD},
		"lbu" : {IFORMAT_I, `IGNORE_F7, 3'h4, OPCODE_LOAD},
		"lhu" : {IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_LOAD},
		"lwu" : {IFORMAT_I, `IGNORE_F7, 3'h6, OPCODE_LOAD},

		"jarl" : {IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_JALR},

		/* S-FORMAT */

		"sb" : {IFORMAT_S, `IGNORE_F7, 3'h0, OPCODE_STORE},
		"sh" : {IFORMAT_S, `IGNORE_F7, 3'h1, OPCODE_STORE},
		"sw" : {IFORMAT_S, `IGNORE_F7, 3'h2, OPCODE_STORE},
		"sd" : {IFORMAT_S, `IGNORE_F7, 3'h3, OPCODE_STORE},

		/* B-FORMAT */

		"beq"  : {IFORMAT_B, `IGNORE_F7, 3'h0, OPCODE_BRANCH},
		"bne"  : {IFORMAT_B, `IGNORE_F7, 3'h1, OPCODE_BRANCH},
		"blt"  : {IFORMAT_B, `IGNORE_F7, 3'h4, OPCODE_BRANCH},
		"bge"  : {IFORMAT_B, `IGNORE_F7, 3'h5, OPCODE_BRANCH},
		"bltu" : {IFORMAT_B, `IGNORE_F7, 3'h6, OPCODE_BRANCH},
		"bgeu" : {IFORMAT_B, `IGNORE_F7, 3'h7, OPCODE_BRANCH},

		/* J-FORMAT */

		"jal" : {IFORMAT_J, `IGNORE_F7, `IGNORE_F3, OPCODE_JAL},

		/* U-FORMAT */

		"lui"  : {IFORMAT_U, `IGNORE_F7, `IGNORE_F3, OPCODE_LUI},
		"auipc" : {IFORMAT_U, `IGNORE_F7, `IGNORE_F3, OPCODE_AUIPC},

		/* ILLEGAL */

		"illegal" : {IFORMAT_J + 1'b1, `IGNORE_F7, 3'h7, OPCODE_LOAD}
	};

	/* instruction info */

	string op_str;
	local iformat_e fmt;
	local bit [20:0] imm;

	`define MAX_IMM 21

	local reg_e rs1;
	local reg_e rs2;
	local reg_e rd;

	/* Constructors */

	function new();

	endfunction

	/* Getters/Setters */

	function string get_op();
		return this.op_str;
	endfunction

	function iformat_e get_fmt();
		return this.fmt;
	endfunction

	function logic [20:0] get_imm();
		return this.imm;
	endfunction

	function reg_e get_rs1();
		return this.rs1;
	endfunction

	function reg_e get_rs2();
		return this.rs2;
	endfunction

	function reg_e get_rd();
		return this.rd;
	endfunction

	/* Other Methods */

	function int gen(string op, int r1, int r2, int r3_imm, ref logic [31:0] instr);  // no support for variadic functions :(

		if (op.len() == 0) begin

			`DBP_PRINT_CURR();
			$write("'op' is empty\n");

			return `EXIT_FAILURE;
		end

		this.op_str = op;

		/* Encode Instruction */

		binstr[`OPCODE] = {`GET_OPCODE(itt, op), 2'b11};
		this.fmt = `GET_IFMT(itt, op);

		unique case (this.fmt)

			IFORMAT_R: begin

				this.rd  = reg_e'(r1[4:0]);
				this.rs1 = reg_e'(r2[4:0]);
				this.rs2 = reg_e'(r3_imm[4:0]);

				binstr[`RD]    = this.rd;
				binstr[`FUNC3] = `GET_FUNC3(itt, op);
				binstr[`RS1]   = this.rs1;
				binstr[`RS2]   = this.rs2;
				binstr[`FUNC7] = `GET_FUNC7(itt, op);

			end

			IFORMAT_I: begin

				this.rd  = reg_e'(r1[4:0]);
				this.rs1 = reg_e'(r2[4:0]);
				this.imm = r3_imm[11:0];

				binstr[`RD]    = this.rd;
				binstr[`FUNC3] = `GET_FUNC3(itt, op);
				binstr[`RS1]   = this.rs1;
				binstr[`IMM_I] = this.imm[11:0];

			end

			IFORMAT_S: begin

				this.rs1 = reg_e'(r1[4:0]);
				this.rs2 = reg_e'(r2[4:0]);
				this.imm = r3_imm[11:0];

				binstr[`IMM_S_L] = this.imm[4:0];
				binstr[`FUNC3]   = `GET_FUNC3(itt, op);
				binstr[`RS1]     = this.rs1;
				binstr[`RS2]     = this.rs2;
				binstr[`IMM_S_H] = this.imm[11:5];

			end

			IFORMAT_B: begin

				this.rs1 = reg_e'(r1[4:0]);
				this.rs2 = reg_e'(r2[4:0]);
				this.imm = r3_imm[12:1];

				binstr[`IMM_B_L] = {this.imm[4:1], this.imm[11]};
				binstr[`RS1]     = this.rs1;
				binstr[`FUNC3]   = `GET_FUNC3(itt, op);
				binstr[`RS2]     = this.rs2;
				binstr[`IMM_B_H] = {this.imm[12], this.imm[10:5]};

			end

			IFORMAT_J: begin

				this.rd  = reg_e'(r1[4:0]);
				this.imm = r3_imm[20:0];

				binstr[`RD]    = this.rd;
				binstr[`IMM_J] = {this.imm[20], this.imm[10:1], this.imm[11], this.imm[19:12]};

			end

			IFORMAT_U: begin

				this.rd  = reg_e'(r1[4:0]);
				this.imm = r3_imm[31:12];

				binstr[`RD]    = this.rd;
				binstr[`IMM_U] = this.imm;

			end

			default: begin // illegal instruction

				// faulted 'load'
				binstr[`RD]     = 5'b10101;
				binstr[`FUNC3]  = `GET_FUNC3(itt, op);
				binstr[`RS1]    = 5'b10101;
				binstr[`IMM_I]  = 12'hfff;

			end

		endcase

		`DBP_PRINT_CURR();
		$write("generated '%0s' successfully\n", op);

		instr = this.binstr;

	endfunction


	task print();

		$display("opcode = %7b", binstr[6:0]);

		unique case (this.fmt)

			IFORMAT_R: begin

				$display("rd     = %5b", binstr[`RD]);
				$display("func3  = %3b", binstr[`FUNC3]);
				$display("rs1    = %5b", binstr[`RS1]);
				$display("rs2    = %5b", binstr[`RS2]);
				$display("func7  = %7b", binstr[`FUNC7]);

			end

			IFORMAT_I: begin

				$display("rd     = %5b", binstr[`RD]);
				$display("func3  = %3b", binstr[`FUNC3]);
				$display("rs1    = %5b", binstr[`RS1]);
				$display("imm    = h%12h", binstr[`IMM_I]);

			end

			IFORMAT_S, IFORMAT_B: begin

				$display("immlo  = %5b", binstr[`IMM_B_L]);
				$display("func3  = %3b", binstr[`FUNC3]);
				$display("rs1    = %5b", binstr[`RS1]);
				$display("rs2    = %5b", binstr[`RS2]);
				$display("immhi  = %7b", binstr[`IMM_B_H]);

			end

			IFORMAT_J, IFORMAT_U: begin

				$display("rd  = %5b", binstr[11:7]);
				$display("imm = %20h", binstr[31:12]);

			end

			default: begin // illegal instruction

				// faulted 'load'
				$display("rd     = %5b", binstr[`RD]);
				$display("func3  = %3b", binstr[`FUNC3]);
				$display("rs1    = %5b", binstr[`RS1]);
				$display("imm    = h%12h", binstr[`IMM_I]);

			end

		endcase

	endtask: print

endclass : instruction_t

