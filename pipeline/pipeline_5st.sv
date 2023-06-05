/*  Pipeline Spec:
 *  5-stage     []
 *  RV64IC      []
 *  forwarding  []
 *  bypassing   []
 *  exceptions  []
 */

/* Exceptions:
 * instruction-address-misaligned (IALIGH=32)
 */


module pipeline_5st #(
    parameter IMEM_DEPTH = 2048,
    parameter IMEM_ADDR_WIDTH = $clog2(IMEM_DEPTH),
    parameter IMEM_DATA_WIDTH = 32,
    parameter IMEM_FILE = "codemem.dat"
) (
    input logic clk,
    input logic rst_
);
    localparam REG_PC_FIRST_LEGAL_ADDRESS = 64'b0;
    localparam REG_FILE_SIZE = 32;
    localparam REG_ADDR_WIDTH = $clog2(REG_FILE_SIZE);

    regfile_2r1w_intf #(
        .DATA_WIDTH(64)
    ) rf_intf (
        .clk(clk)
    );

    mem_sync_sp_intf #(
        .DEPTH(IMEM_DEPTH),
        .DATA_WIDTH(IMEM_DATA_WIDTH),
        .INIT_FILE(IMEM_FILE),
        .INIT_START('h0)
        // .INIT_END('h160 - 1)
    ) imem_intf (
        .clk(clk)
    );

    logic [63:0] REG_PC;

    logic [95:0] IFIDR;       // | 32instr | 64npc |
    logic [31:0] IFIDR_INST;
    logic [63:0] IFIDR_NPC;

    logic [276:0] IDEXR;      // | 64imm | 64rs1 | 64rs2 | 64npc | 5rd | 10func | 6decop |: 277-bits
    logic [63:0] IDEXR_IMM;
    logic [63:0] IDEXR_RS1;
    logic [63:0] IDEXR_RS2;
    logic [63:0] IDEXR_NPC;
    logic [9:0] IDEXR_FUNC;
    logic [4:0] IDEXR_RD;
    alu_op_e IDEXR_OP;

    logic [100:0] EXMEMR;     // | 64res | 5rd | 1cond |
    logic [63:0] EXMEMR_OUT;

    // logic [rf_intf.DATA_WIDTH - 1 : 0] MEMWBR;  //

    regfile_2r1w regfile(rf_intf);
    mem_sync_sp imem (imem_intf);

    /** debug purposes **/

    assign IFIDR_INST = IFIDR[31:0];
    assign IFIDR_NPC = IFIDR[95:32];

    assign IDEXR_IMM = IDEXR[0+:64];
    assign IDEXR_RS1 = IDEXR[64+:64];
    assign IDEXR_RS2 = IDEXR[128+:64];
    assign IDEXR_NPC = IDEXR[192+:64];
    assign IDEXR_RD = IDEXR[256+:5];
    assign IDEXR_FUNC = IDEXR[261+:10];

    /* STAGE 1 (IF/ID) */
    always_ff @(posedge clk, negedge rst_) begin : stage_1_if_id
        if (!rst_) begin
            IFIDR <= 'b0;
            REG_PC <= {{62{1'b1}}, 2'b00};
        end
        else begin
            IFIDR[0 +: IMEM_DATA_WIDTH] <= imem_intf.o_rdata;
            IFIDR[IMEM_DATA_WIDTH +: 64] <= REG_PC + 64'h4;
            REG_PC <= REG_PC + 'h4;

            /// TODO: add branch logic
        end
    end : stage_1_if_id

    always_comb begin
        imem_intf.i_addr = REG_PC[0 +: IMEM_ADDR_WIDTH] >> 2;
    end


    /* STAGE 2 (ID/EX) */
    always_ff @(posedge clk) begin : stage_2_id_ex
        if (!rst_) begin
            IDEXR <= 'b0;
        end
        else begin

            //
            //

            IDEXR[64+:64] <= rf_intf.o_rdata1;   // rs1
            IDEXR[128+:64] <= rf_intf.o_rdata2;  // rs2
            IDEXR[192+:64] <= IFIDR[32+:64];     // npc
            IDEXR[256+:5] <= IFIDR[7+:5];        // rd
            IDEXR[261+:3] <= IFIDR[12+:3];       // func3
            IDEXR[264+:7] <= IFIDR[25+:7];       // func7

        end
    end : stage_2_id_ex

    always_comb begin
        rf_intf.i_raddr1 = IFIDR[19:15];
        rf_intf.i_raddr2 = IFIDR[24:20];
    end


    /* STAGE 3 (EX/MEM) */
    /* always_ff @(posedge clk) begin : stage_3_ex_mem
        if (!rst_) begin
            EXMEMR <= 'b0;
        end
        else begin
            EXMEMR <= IDEXR;
        end
    end : stage_3_ex_mem */


    /* STAGE 4 (MEM/WB) */
    /* always_ff @(posedge clk) begin : stage_4_mem_wb
        if (!rst_) begin
            MEMWBR <= 'b0;
        end
        else begin
            MEMWBR <= EXMEMR;
        end
    end : stage_4_mem_wb */

    /* STAGE 5 (WB) */

endmodule: pipeline_5st
