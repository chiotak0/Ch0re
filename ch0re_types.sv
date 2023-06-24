`ifndef CH0RE_TYPES_SV
`define CH0RE_TYPES_SV


typedef enum logic [4:0] {
	/** RV32I **/
	OPCODE_OP     = 5'h0c,
	OPCODE_OP_IMM = 5'h04,
	OPCODE_LOAD   = 5'h00,
	OPCODE_STORE  = 5'h08,
	OPCODE_BRANCH = 5'h18,
	OPCODE_JAL    = 5'h1b,
	OPCODE_JALR   = 5'h19,
	OPCODE_LUI    = 5'h0d,
	OPCODE_AUIPC  = 5'h05,

	OPCODE_OP32     = 5'h0e,
	OPCODE_OP_IMM32 = 5'h06

} opcode_e;

typedef enum logic [2:0] {
	IFORMAT_NONE,
	IFORMAT_R,
	IFORMAT_I,
	IFORMAT_S,
	IFORMAT_B,
	IFORMAT_U,
	IFORMAT_J,
	IFORMAT_ILLEGAL
} iformat_e;

typedef enum logic [3:0] {
	ALU_EQ,   // 0x0
	ALU_NE,   // 0x1
	ALU_ADD,
	ALU_SUB,
	ALU_LT,   // 0x4
	ALU_GE,   // 0x5
	ALU_LTU,  // 0x6
	ALU_GEU,  // 0x7
	ALU_XOR,
	ALU_OR,
	ALU_AND,
	ALU_SLL,
	ALU_SRL,
	ALU_SRA,
	ALU_SLT,
	ALU_SLTU
} alu_op_e;

typedef enum logic [1:0] {
	LSU_NONE,
	LSU_LOAD,
	LSU_STORE
} lsu_op_e;

typedef enum logic [2:0] {
	DTYPE_BYTE,
	DTYPE_HALF,
	DTYPE_WORD,
	DTYPE_DOUBLE,

	DTYPE_BYTEU,
	DTYPE_HALFU,
	DTYPE_WORDU
} data_type_e;

typedef enum logic [2:0] {
	ALU_MUX1_SEL_REG,
	ALU_MUX1_SEL_IMM_ZERO,
	ALU_MUX1_SEL_PC,
	ALU_MUX1_SEL_FWD_MEM,
	ALU_MUX1_SEL_FWD_WB
} alu_mux1_sel_e;

typedef enum logic [2:0] {
	ALU_MUX2_SEL_REG,
	ALU_MUX2_SEL_IMM,
	ALU_MUX2_SEL_IMM_FOUR,
	ALU_MUX2_SEL_FWD_MEM,
	ALU_MUX2_SEL_FWD_WB
} alu_mux2_sel_e;

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

typedef enum logic [2:0] {
	DEP_NONE,
	DEP_EX_LOAD,
	DEP_EX_OTHER,
	DEP_MEM_LOAD,
	DEP_MEM_OTHER
} dependency_e;

`endif /* CH0RE_TYPES_SV */

