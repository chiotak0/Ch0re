// `include "ch0re_types.sv"
// `include "debug_prints.sv"

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

`define GET_ALU_OP(kva, key) alu_op_e'(kva[key][18+:4])
`define GET_IFMT(kva, key)   iformat_e'(kva[key][15+:3])
`define GET_FUNC7(kva, key)  kva[key][8+:7]
`define GET_FUNC3(kva, key)  kva[key][5+:3]
`define GET_OPCODE(kva, key) kva[key][0+:5]

`define EXIT_SUCCESS (0)
`define EXIT_FAILURE (-1)

class ch0re_instruction_t #(type opT = string);

	/* Instruction Binary Representation */

	local logic [31:0] binstr;

	/* instruction translation table */

	static const logic [21:0] itt [string] = '{

		/* R-FORMAT */

		"add"  : {ALU_ADD,  IFORMAT_R, 7'h00, 3'h0, OPCODE_OP},
		"sub"  : {ALU_SUB,  IFORMAT_R, 7'h20, 3'h0, OPCODE_OP},
		"xor"  : {ALU_XOR,  IFORMAT_R, 7'h00, 3'h4, OPCODE_OP},
		"or"   : {ALU_OR,   IFORMAT_R, 7'h00, 3'h6, OPCODE_OP},
		"and"  : {ALU_AND,  IFORMAT_R, 7'h00, 3'h7, OPCODE_OP},
		"sll"  : {ALU_SLL,  IFORMAT_R, 7'h00, 3'h1, OPCODE_OP},
		"srl"  : {ALU_SRL,  IFORMAT_R, 7'h00, 3'h5, OPCODE_OP},
		"sra"  : {ALU_SRA,  IFORMAT_R, 7'h20, 3'h5, OPCODE_OP},
		"slt"  : {ALU_SLT,  IFORMAT_R, 7'h00, 3'h2, OPCODE_OP},
		"sltu" : {ALU_SLTU, IFORMAT_R, 7'h00, 3'h3, OPCODE_OP},

		"addw" : {ALU_ADD, IFORMAT_R, 7'h00, 3'h0, OPCODE_OP32},
		"subw" : {ALU_SUB, IFORMAT_R, 7'h20, 3'h0, OPCODE_OP32},
		"sllw" : {ALU_SLL, IFORMAT_R, 7'h00, 3'h1, OPCODE_OP32},
		"srlw" : {ALU_SRL, IFORMAT_R, 7'h00, 3'h5, OPCODE_OP32},
		"sraw" : {ALU_SRA, IFORMAT_R, 7'h20, 3'h5, OPCODE_OP32},

		/* I-FORMAT */

		"addi" : {ALU_ADD,  IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_OP_IMM},
		"xori" : {ALU_XOR,  IFORMAT_I, `IGNORE_F7, 3'h4, OPCODE_OP_IMM},
		"ori"  : {ALU_OR,   IFORMAT_I, `IGNORE_F7, 3'h6, OPCODE_OP_IMM},
		"andi" : {ALU_AND,  IFORMAT_I, `IGNORE_F7, 3'h7, OPCODE_OP_IMM},
		"slli" : {ALU_SLL,  IFORMAT_I, `IGNORE_F7, 3'h1, OPCODE_OP_IMM},
		"srli" : {ALU_SRL,  IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_OP_IMM},
		"srai" : {ALU_SRA,  IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_OP_IMM},
		"slti" : {ALU_SLT,  IFORMAT_I, `IGNORE_F7, 3'h2, OPCODE_OP_IMM},
		"sltu" : {ALU_SLTU, IFORMAT_I, `IGNORE_F7, 3'h3, OPCODE_OP_IMM},

		"addiw" : {ALU_ADD, IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_OP_IMM32},
		"slliw" : {ALU_SLL, IFORMAT_I, `IGNORE_F7, 3'h1, OPCODE_OP_IMM32},
		"srliw" : {ALU_SRL, IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_OP_IMM32},
		"sraiw" : {ALU_SRA, IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_OP_IMM32},

		"lb"  : {ALU_ADD, IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_LOAD},
		"lh"  : {ALU_ADD, IFORMAT_I, `IGNORE_F7, 3'h1, OPCODE_LOAD},
		"lw"  : {ALU_ADD, IFORMAT_I, `IGNORE_F7, 3'h2, OPCODE_LOAD},
		"ld"  : {ALU_ADD, IFORMAT_I, `IGNORE_F7, 3'h3, OPCODE_LOAD},
		"lbu" : {ALU_ADD, IFORMAT_I, `IGNORE_F7, 3'h4, OPCODE_LOAD},
		"lhu" : {ALU_ADD, IFORMAT_I, `IGNORE_F7, 3'h5, OPCODE_LOAD},
		"lwu" : {ALU_ADD, IFORMAT_I, `IGNORE_F7, 3'h6, OPCODE_LOAD},

		"jalr" : {ALU_ADD, IFORMAT_I, `IGNORE_F7, 3'h0, OPCODE_JALR},

		/* S-FORMAT */

		"sb" : {ALU_ADD, IFORMAT_S, `IGNORE_F7, 3'h0, OPCODE_STORE},
		"sh" : {ALU_ADD, IFORMAT_S, `IGNORE_F7, 3'h1, OPCODE_STORE},
		"sw" : {ALU_ADD, IFORMAT_S, `IGNORE_F7, 3'h2, OPCODE_STORE},
		"sd" : {ALU_ADD, IFORMAT_S, `IGNORE_F7, 3'h3, OPCODE_STORE},

		/* B-FORMAT */

		"beq"  : {ALU_EQ,  IFORMAT_B, `IGNORE_F7, 3'h0, OPCODE_BRANCH},
		"bne"  : {ALU_NE,  IFORMAT_B, `IGNORE_F7, 3'h1, OPCODE_BRANCH},
		"blt"  : {ALU_LT,  IFORMAT_B, `IGNORE_F7, 3'h4, OPCODE_BRANCH},
		"bge"  : {ALU_GE,  IFORMAT_B, `IGNORE_F7, 3'h5, OPCODE_BRANCH},
		"bltu" : {ALU_LTU, IFORMAT_B, `IGNORE_F7, 3'h6, OPCODE_BRANCH},
		"bgeu" : {ALU_GEU, IFORMAT_B, `IGNORE_F7, 3'h7, OPCODE_BRANCH},

		/* J-FORMAT */

		"jal" : {ALU_ADD, IFORMAT_J, `IGNORE_F7, `IGNORE_F3, OPCODE_JAL},

		/* U-FORMAT */

		"lui"   : {ALU_ADD, IFORMAT_U, `IGNORE_F7, `IGNORE_F3, OPCODE_LUI},
		"auipc" : {ALU_ADD, IFORMAT_U, `IGNORE_F7, `IGNORE_F3, OPCODE_AUIPC},

		/* ILLEGAL */

		"illegal" : {ALU_ADD, IFORMAT_ILLEGAL, `IGNORE_F7, 3'h7, OPCODE_LOAD} // illegal load
	};

	/* instruction info */

	opT op;
	alu_op_e alu_op;
	local iformat_e fmt;
	rand local bit [20:0] imm;

	`define MAX_IMM 21

	randc local reg_e rs1;
	randc local reg_e rs2;
	randc local reg_e rd;

	rand dependency_e dep;

	/// TODO: add data_type_e for loads verification

	/* utils */

	logic [31:0] random_seed;
	int seed_file;

	/* Constructors */

	function new();

		this.fmt = IFORMAT_NONE;

		$system("dd if=/dev/random bs=4 count=1 status=none > random_bytes.bin");
		seed_file = $fopen("random_bytes.bin", "r");

		if (seed_file != 0) begin

			void'($fread(random_seed, seed_file));
			$fclose(seed_file);

			`DBP_PRINT_CURR();
			$display("seed: %h", random_seed);

		end
		else begin

			`DBP_PRINT_CURR();	
			$display("failed to open the seed_file for reading");
			random_seed = 1;

			`DBP_PRINT_CURR();
			$display("seed: %h", random_seed);

		end

		srandom(random_seed);

	endfunction

	/* Getters */

	function opT get_op();
		return this.op;
	endfunction

	function alu_op_e get_alu_op();
		return this.alu_op;
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

	function dependency_e get_dep();
		return this.dep;
	endfunction

	/* Other Methods */

	function int gen(opT op, int r1, int r2, int r3_imm, ref logic [31:0] instr, dependency_e dep);  // no support for variadic functions :(

		if (op.len() == 0) begin

			`DBP_PRINT_CURR();
			$write("'op' is empty\n");

			return `EXIT_FAILURE;
		end

		this.op = op;
		this.dep = dep;
		this.alu_op = `GET_ALU_OP(itt, op);

		/* Encode Instruction */

		this.binstr[`OPCODE] = {`GET_OPCODE(itt, op), 2'b11};
		this.fmt = `GET_IFMT(itt, op);

		unique case (this.fmt)

			IFORMAT_R: begin

				this.rd  = reg_e'(r1[4:0]);
				this.rs1 = reg_e'(r2[4:0]);
				this.rs2 = reg_e'(r3_imm[4:0]);

				this.binstr[`RD]    = this.rd;
				this.binstr[`FUNC3] = `GET_FUNC3(itt, op);
				this.binstr[`RS1]   = this.rs1;
				this.binstr[`RS2]   = this.rs2;
				this.binstr[`FUNC7] = `GET_FUNC7(itt, op);

			end

			IFORMAT_I: begin

				this.rd  = reg_e'(r1[4:0]);
				this.rs1 = reg_e'(r2[4:0]);
				this.imm = r3_imm[11:0];

				this.binstr[`RD]    = this.rd;
				this.binstr[`FUNC3] = `GET_FUNC3(itt, op);
				this.binstr[`RS1]   = this.rs1;
				this.binstr[`IMM_I] = this.imm[11:0];

			end

			IFORMAT_S: begin

				this.rs1 = reg_e'(r1[4:0]);
				this.rs2 = reg_e'(r2[4:0]);
				this.imm = r3_imm[11:0];

				this.binstr[`IMM_S_L] = this.imm[4:0];
				this.binstr[`FUNC3]   = `GET_FUNC3(itt, op);
				this.binstr[`RS1]     = this.rs1;
				this.binstr[`RS2]     = this.rs2;
				this.binstr[`IMM_S_H] = this.imm[11:5];

			end

			IFORMAT_B: begin

				this.rs1 = reg_e'(r1[4:0]);
				this.rs2 = reg_e'(r2[4:0]);
				this.imm = r3_imm[12:1];

				this.binstr[`IMM_B_L] = {this.imm[4:1], this.imm[11]};
				this.binstr[`RS1]     = this.rs1;
				this.binstr[`FUNC3]   = `GET_FUNC3(itt, op);
				this.binstr[`RS2]     = this.rs2;
				this.binstr[`IMM_B_H] = {this.imm[12], this.imm[10:5]};

			end

			IFORMAT_J: begin

				this.rd  = reg_e'(r1[4:0]);
				this.imm = r3_imm[20:0];

				this.binstr[`RD]    = this.rd;
				this.binstr[`IMM_J] = {this.imm[20], this.imm[10:1], this.imm[11], this.imm[19:12]};

			end

			IFORMAT_U: begin

				this.rd  = reg_e'(r1[4:0]);
				this.imm = r3_imm[31:12];

				this.binstr[`RD]    = this.rd;
				this.binstr[`IMM_U] = this.imm;

			end

			IFORMAT_ILLEGAL: begin

				// faulted 'load'
				this.binstr[`RD]     = 5'b10101;
				this.binstr[`FUNC3]  = `GET_FUNC3(itt, op);
				this.binstr[`RS1]    = 5'b10101;
				this.binstr[`IMM_I]  = 12'hfff;

			end

			default: assert(1'b0) else $fatal();

		endcase

		// Ignore a portion of the imm for these I-Format instructions

		if (this.op == "srai")
			this.binstr[31:26] = 6'h10;
		else if (this.op == "srli" || this.op == "slli")
			this.binstr[31:26] = 6'h0;
		else if (this.op == "sraiw")
			this.binstr[31:25] = 7'h20;
		else if (this.op == "srliw" || this.op == "slliw")
			this.binstr[31:25] = 7'h0;

		instr = this.binstr;

		return `EXIT_SUCCESS;

	endfunction: gen

	function int gen_rand(string op, ref logic [31:0] instr);

		int tmp;
		int ret;

		assert(randomize(this.rd))
		else $fatal();

		assert(randomize(this.rs1))
		else $fatal();

		assert(randomize(this.rs2))
		else $fatal();

		assert(randomize(this.imm))
		else $fatal();

		assert(randomize(this.dep))
		else $fatal();

		unique case (`GET_IFMT(itt, op))

			IFORMAT_R: ret = this.gen(op, this.rd, this.rs1, this.rs2, instr, this.dep);
			IFORMAT_I: ret = this.gen(op, this.rd, this.rs1, this.imm, instr, this.dep);

			IFORMAT_S,
			IFORMAT_B: ret = this.gen(op, this.rs1, this.rs2, this.imm, instr, this.dep);

			IFORMAT_J,
			IFORMAT_U: ret = this.gen(op, this.rd, this.rs1, this.rs2, instr, this.dep);

			IFORMAT_ILLEGAL: ret = this.gen(op, 32'dx, 32'dx, 32'dx, instr, this.dep);

			default: assert(1'b0) else $fatal();

		endcase

		return ret;

	endfunction

	function void print();

		$display("opcode = %7b", this.binstr[6:0]);

		unique case (this.fmt)

			IFORMAT_R: begin

				$display("rd     = %5b", this.binstr[`RD]);
				$display("func3  = %3b", this.binstr[`FUNC3]);
				$display("rs1    = %5b", this.binstr[`RS1]);
				$display("rs2    = %5b", this.binstr[`RS2]);
				$display("func7  = %7b", this.binstr[`FUNC7]);
				$display("dep    = %0s", this.dep.name());

			end

			IFORMAT_I: begin

				$display("rd     = %5b", this.binstr[`RD]);
				$display("func3  = %3b", this.binstr[`FUNC3]);
				$display("rs1    = %5b", this.binstr[`RS1]);
				$display("imm    = h%12h", this.binstr[`IMM_I]);
				$display("dep    = %0s", this.dep.name());

			end

			IFORMAT_S, IFORMAT_B: begin

				$display("immlo  = %5b", this.binstr[`IMM_B_L]);
				$display("func3  = %3b", this.binstr[`FUNC3]);
				$display("rs1    = %5b", this.binstr[`RS1]);
				$display("rs2    = %5b", this.binstr[`RS2]);
				$display("immhi  = %7b", this.binstr[`IMM_B_H]);
				$display("dep    = %0s", this.dep.name());

			end

			IFORMAT_J, IFORMAT_U: begin

				$display("rd  = %5b", this.binstr[11:7]);
				$display("imm = %20h", this.binstr[31:12]);

			end

			IFORMAT_ILLEGAL: begin // illegal instruction

				// faulted 'load'
				$display("rd     = %5b", this.binstr[`RD]);
				$display("func3  = %3b", this.binstr[`FUNC3]);
				$display("rs1    = %5b", this.binstr[`RS1]);
				$display("imm    = h%12h", this.binstr[`IMM_I]);

			end

			default: begin
				assert(1'b0) else $fatal();
			end

		endcase

	endfunction: print

endclass: ch0re_instruction_t

