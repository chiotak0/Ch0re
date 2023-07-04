`ifndef PIPELINE_REG_INFO_SV
`define PIPELINE_REG_INFO_SV

/* IF/ID */

`define IFIDR_CURR_PC       0+:64

`define IFIDR_SIZE          63:0
`define PCR_SIZE            `IFIDR_SIZE

/* ID/EX */

`define IDEXR_IMM           0+:64
`define IDEXR_RS1           64+:64
`define IDEXR_RS2           128+:64
`define IDEXR_PC            192+:64
`define IDEXR_RD            256+:5
`define IDEXR_ALU_OP        261+:4
`define IDEXR_ALU_MUX1_SEL  265+:3
`define IDEXR_ALU_MUX2_SEL  268+:3
`define IDEXR_DATA_TYPE     271+:3
`define IDEXR_BRANCH_TARGET 274+:64
`define IDEXR_LSU_OP  		338+:2
`define IDEXR_WEN           340+:1
`define IDEXR_IFORMAT       341+:3
`define IDEXR_I64           344+:1
`define IDEXR_IS_JALR       345+:1
`define IDEXR_DISABLED      346+:1

`define IDEXR_SIZE          346:0

/* EX/MEM */

`define EXMEMR_ALU_OUT   0+:64
`define EXMEMR_RS2	     64+:64
`define EXMEMR_RD	     128+:5
`define EXMEMR_LSU_OP    133+:2
`define EXMEMR_DATA_TYPE 135+:3
`define EXMEMR_WEN       138+:1
`define EXMEMR_IFORMAT   139+:3
`define EXMEMR_DISABLED  142+:1

`define EXMEMR_SIZE      142:0

/* MEM/WB */

`define MEMWBR_ALU_OUT 	 0+:64
`define MEMWBR_LSU_OP    64+:2
`define MEMWBR_RD        66+:5
`define MEMWBR_WEN       71+:1
`define MEMWBR_DATA_TYPE 72+:3
`define MEMWBR_IFORMAT   75+:3
`define MEMWBR_DISABLED  78+:1

`define MEMWBR_SIZE      78:0

/* Dependency History */

`define EXHR_LSU_OP 0+:2
`define EXHR_IFMT   2+:3
`define EXHR_RD     5+:5
`define EXHR_WEN    10+:1

`define MEMHR_IFMT 0+:3
`define MEMHR_RD   3+:5
`define MEMHR_WEN  8+:1

`endif