`include "ch0re_types.sv"
`include "debug_prints.sv"

class ch0re_alu_op_t;

	randc alu_op_e op;

	rand bit signed [63:0] src1;
	rand bit signed [63:0] src2;

	logic [31:0] random_seed;
	int seed_file;

	constraint small_nums {
		src1 >= -100;
		src1 <= 100;

		src2 >= -100;
		src2 <= 100;
	};

	local bit signed [63:0] res;

	local logic flag_overflow;
	local logic flag_zero;
	local logic flag_lt;

	/* Methods */

	function new();

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

	function alu_op_e get_op();
		return this.op;
	endfunction

	function bit [63:0] get_src1();
		return this.src1;
	endfunction

	function bit [63:0] get_src2();
		return this.src2;
	endfunction

	function bit [63:0] get_res();
		return this.res;
	endfunction

	function logic get_flag_overflow();
		return this.flag_overflow;
	endfunction

	function logic get_flag_zero();
		return this.flag_zero;
	endfunction

	function logic get_flag_lt();
		return this.flag_lt;
	endfunction

	function void gen(alu_op_e op);

		this.op = op;

		assert(randomize(this.src1))
		else $fatal();

		assert(randomize(this.src2))
		else $fatal();

		this.flag_zero = (this.src1 == this.src2) ? 1'b1 : 1'b0;
		this.flag_lt = 'hx;  // I only care about branches

		unique case (op)

			ALU_SLT:  this.res = (this.src1 < this.src2) ? 'b1 : 'b0;
			ALU_SLTU: this.res = (unsigned'(this.src1) < unsigned'(this.src2)) ? 'b1 : 'b0;

			ALU_ADD: this.res = this.src1 + this.src2;
			ALU_SUB: this.res = this.src1 - this.src2;

			ALU_EQ,  ALU_NE,
			ALU_LT,  ALU_GE: this.flag_lt = (this.src1 < this.src2) ? 'b1 : 'b0;

			ALU_LTU, ALU_GEU: this.flag_lt = (unsigned'(this.src1) < unsigned'(this.src2)) ? 'b1 : 'b0;

			ALU_OR:  this.res = this.src1 | this.src2;
			ALU_XOR: this.res = this.src1 ^ this.src2;
			ALU_AND: this.res = this.src1 & this.src2;

			ALU_SLL: this.res = this.src1 << this.src2[5:0];
			ALU_SRL: this.res = this.src1 >> this.src2[5:0];
			ALU_SRA: this.res = this.src1 >>> this.src2[5:0];

			default:;

		endcase

	endfunction

	function void gen_rand();

		assert(randomize(this.op))
		else $fatal();

		this.gen(this.op);

	endfunction;

	function void print();

		$display("src1 = %0d (h%0h)", this.src1, this.src1);
		$display("op   = %0s", this.op.name());
		$display("src2 = %0d (h%0h)", this.src2, this.src2);
		$display("res  = %0d (h%0h)", this.res, this.res);
		$display("");
		// $display("flag_overflow = 1'b%1b", this.flag_overflow);
		$display("flag_zero = 1'b%1b", this.flag_zero);
		$display("flag_lt   = 1'b%1b", this.flag_lt);

	endfunction

endclass

