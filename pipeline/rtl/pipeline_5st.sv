`ifndef CH0RE_PIPELINE_5ST_SV
`define CH0RE_PIPELINE_5ST_SV

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

typedef enum logic [6 : 0] {
    //1
} opdec;

`include "memory_models/regfile_2r1w/regfile_2r1w.sv"  /// TODO: will be removed upon 'release'
`include "memory_models/mem_sync_sp/mem_sync_sp.sv"

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
    ) rf_intf 
    (.clk(clk));

    mem_sync_sp_intf #(
        .DEPTH(IMEM_DEPTH),
        .DATA_WIDTH(IMEM_DATA_WIDTH),
        .INIT_FILE(IMEM_FILE)
    ) imem_intf (
        .clk(clk)
    );

    logic [63 : 0] REG_PC;
    logic [95 : 0] REG_IFID;   // 32instr + 64npc
    logic [228 : 0] REG_IDEX;  // 32imm + 64rs1 + 64rs2 + 64npc + 5rd = 229-bits

    logic [rf_intf.DATA_WIDTH - 1 : 0] REG_EXMEM;  // 
    logic [rf_intf.DATA_WIDTH - 1 : 0] REG_MEMWB;  //

    regfile_2r1w regfile(rf_intf);
    mem_sync_sp imem (imem_intf);


    /* STAGE 1 (IF/ID) */
    always_ff @(posedge clk) begin : stage_1_if_id
        if (!rst_) begin
            REG_IFID <= 'b0;
            REG_PC <= REG_PC_FIRST_LEGAL_ADDRESS;
        end
        else begin
            REG_IFID[0 +: IMEM_DATA_WIDTH] <= imem_intf.o_rdata;
            REG_IFID[IMEM_DATA_WIDTH +: 64] <= REG_PC + 64'h4;
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
            REG_IDEX <= 'b0;
        end
        else begin

            /// TODO: Imm logic

            REG_IDEX[32 +: 64] <= rf_intf.o_rdata1; // rs1
            REG_IDEX[96 +: 64] <= rf_intf.o_rdata2; // rs2
            REG_IDEX[160 +: 64] <= REG_IFID[32 +: 64]; // npc
            REG_IDEX[224 +: 5] <= REG_IFID[7 +: 5]; // rd
        end
    end : stage_2_id_ex

    always_comb begin
        rf_intf.i_raddr1 = REG_IFID[15 : 19];
        rf_intf.i_raddr2 = REG_IFID[20 : 24];
    end


    /* STAGE 3 (EX/MEM) */
    /* always_ff @(posedge clk) begin : stage_3_ex_mem
        if (!rst_) begin
            REG_EXMEM <= 'b0;
        end
        else begin
            REG_EXMEM <= REG_IDEX;
        end
    end : stage_3_ex_mem */


    /* STAGE 4 (MEM/WB) */
    /* always_ff @(posedge clk) begin : stage_4_mem_wb
        if (!rst_) begin
            REG_MEMWB <= 'b0;
        end
        else begin
            REG_MEMWB <= REG_EXMEM;
        end
    end : stage_4_mem_wb */

    /* STAGE 5 (WB) */

endmodule: pipeline_5st

`endif /* CH0RE_PIPELINE_5ST_SV */
