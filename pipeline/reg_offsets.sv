`ifndef REG_OFFSETS
`define REG_OFFSETS

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

`define EXMEMR_ALU_OUT   0+:64
`define EXMEMR_RS2	     64+:64
`define EXMEMR_RD	     128+:5
`define EXMEMR_LSU_OP    133+:2
`define EXMEMR_DATA_TYPE 135+:3
`define EXMEMR_WEN       138+:1
`define EXMEMR_IFORMAT   139+:3

`define MEMWBR_OUT  	 0+:64
`define MEMWBR_LSU_OP    64+:2
`define MEMWBR_RD        66+:5
`define MEMWBR_WEN       71+:1
`define MEMWBR_DATA_TYPE 72+:3

`endif