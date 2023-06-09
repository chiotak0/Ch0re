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
    IFORMAT_R,
    IFORMAT_I,
    IFORMAT_S,
    IFORMAT_B,
    IFORMAT_U,
    IFORMAT_J
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

typedef enum logic [2:0] {
    DTYPE_BYTE,
    DTYPE_HALF,
    DTYPE_WORD,
    DTYPE_DOUBLE,

    DTYPE_BYTEU,
    DTYPE_HALFU,
    DTYPE_WORDU
} data_type_e;

typedef enum logic [1:0] {
    ALU_MUX1_SEL_REG,
    ALU_MUX1_SEL_IMM,
    ALU_MUX1_SEL_FWD,
    ALU_MUX1_SEL_PC
} alu_mux1_sel_e;

typedef enum logic {
    ALU_MUX2_SEL_REG,
    ALU_MUX2_SEL_IMM
} alu_mux2_sel_e;


`endif /* CH0RE_TYPES_SV */
