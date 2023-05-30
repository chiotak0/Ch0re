`ifndef CHORE_PIPELINE_5ST_SV
`define CHORE_PIPELINE_5ST_SV

/*/ Pipeline Spec:
 *  RV64IC then try M
/*/

// `include "../../memory_models_rtl/regfile_2r1w/regfile_2r1w.sv"

module pipeline_5st #(
    parameter RF_DLEN = 64,
    parameter RF_ALEN = 5,
    parameter IM_DEPTH = 2048,
    parameter IM_ADDR_WIDTH = $clog2(IM_DEPTH),
    parameter IM_DATA_WIDTH = 32
) (
    input wire clk,
    input wire rst_n
);
    parameter IM_DATA_BYTES = IM_DATA_WIDTH / 8;  // Verilatoor has problem with 'localparam'
    parameter PC_FIRST_LEGAL_ADDRESS = 64'b0;

    logic [IM_ADDR_WIDTH - 1 : 0] im_addr;  // connect with PC (where to define PC)
    logic [IM_DATA_WIDTH - 1 : 0] im_wdata;
    logic [IM_DATA_BYTES - 1 : 0] im_wen; // ???
    logic [IM_DATA_WIDTH - 1 : 0] im_rdata;

    logic [RF_ALEN - 1 : 0] rf_raddr1;
    logic [RF_ALEN - 1 : 0] rf_raddr2;

    logic rf_wen;
    logic [RF_ALEN - 1 : 0] rf_waddr;
    logic [RF_DLEN - 1 : 0] rf_wdata;

    logic [RF_DLEN - 1 : 0] rf_rdata1;
    logic [RF_DLEN - 1 : 0] rf_rdata2;

    logic [RF_DLEN - 1 : 0] PC;

    /**************************************/

    logic [RF_DLEN - 1 : 0] IFIDIR;
    // logic [RF_DLEN - 1 : 0] IDEXIR;
    // logic [RF_DLEN - 1 : 0] EXMEMIR;
    // logic [RF_DLEN - 1 : 0] MEMWBIR;

    regfile_2r1w #(
        .DLEN(64)
    ) regfile (
        .clk(clk),
        .i_raddr_a(rf_raddr1),
        .i_raddr_b(rf_raddr2),
        .i_wen(rf_wen),
        .i_waddr(rf_waddr),
        .i_wdata(rf_wdata),

        .o_rdata_a(rf_rdata1),
        .o_rdata_b(rf_rdata2)
    );

    mem_sync_sp #(
        .DEPTH(IM_DEPTH),
        .DATA_WIDTH(IM_DATA_WIDTH)
    ) imem (
        .clk(clk),
        .i_addr(im_addr),
        .i_wdata(im_wdata),
        .i_wen(im_wen),

        .o_rdata(im_rdata)
    );


    /* STAGE 1 (IF/ID) */
    always_ff @(posedge clk) begin : stage_1_if_id
        if (!rst_n) begin
            IFIDIR <= 'b0;
            PC <= PC_FIRST_LEGAL_ADDRESS;
        end
        else begin
            IFIDIR[0 +: IM_DATA_WIDTH] <= im_rdata;
        end
    end : stage_1_if_id

    always_comb begin : wire_assignments
        im_addr = PC[0 +: IM_ADDR_WIDTH];
    end : wire_assignments


    /* STAGE 2 (ID/EX) */
    /* always_ff @(posedge clk) begin : stage_2_id_ex
        if (!rst_n) begin
            IDEXIR <= 'b0;
        end
        else begin
            IDEXIR <= IFIDIR;
        end
    end : stage_2_id_ex */


    /* STAGE 3 (EX/MEM) */
    /* always_ff @(posedge clk) begin : stage_3_ex_mem
        if (!rst_n) begin
            EXMEMIR <= 'b0;
        end
        else begin
            EXMEMIR <= IDEXIR;
        end
    end : stage_3_ex_mem */


    /* STAGE 4 (MEM/WB) */
    /* always_ff @(posedge clk) begin : stage_4_mem_wb
        if (!rst_n) begin
            MEMWBIR <= 'b0;
        end
        else begin
            MEMWBIR <= EXMEMIR;
        end
    end : stage_4_mem_wb */

    /* STAGE 5 (WB) */

endmodule: pipeline_5st

`endif /* CHORE_PIPELINE_5ST_SV */
