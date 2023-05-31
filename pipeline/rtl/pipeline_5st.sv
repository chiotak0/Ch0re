`ifndef CH0RE_PIPELINE_5ST_SV
`define CH0RE_PIPELINE_5ST_SV

/*  Pipeline Spec:
 *  5-stage     []
 *  RV64IC      []
 *  forwarding  []
 *  bypassing   []
 */

// `include "memory_models/regfile_2r1w/regfile_2r1w.sv"
`include "memory_models/mem_sync_sp/mem_sync_sp.sv"

module pipeline_5st #(
    parameter REG_DATA_WIDTH = 64,
    parameter IMEM_DEPTH = 2048,
    parameter IMEM_ADDR_WIDTH = $clog2(IMEM_DEPTH),
    parameter IMEM_DATA_WIDTH = 32
) (
    input logic clk,
    input logic rst_
);
    localparam IMEM_DATA_BYTES = IMEM_DATA_WIDTH / 8;  // Verilatoor has problem with 'localparam'
    localparam REG_PC_FIRST_LEGAL_ADDRESS = 64'b0;
    localparam REG_FILE_SIZE = 32;
    localparam REG_ADDR_WIDTH = $clog2(REG_FILE_SIZE);

    logic [IMEM_ADDR_WIDTH - 1 : 0] im_addr;  // connect with REG_PC (where to define REG_PC)
    logic [IMEM_DATA_WIDTH - 1 : 0] im_wdata;
    logic [IMEM_DATA_BYTES - 1 : 0] im_wen;
    logic [IMEM_DATA_WIDTH - 1 : 0] im_rdata;

    logic [/* rf_intf. */REG_DATA_WIDTH - 1 : 0] REG_PC;

    /**************************************/

    logic [/* rf_intf. */REG_DATA_WIDTH - 1 : 0] REG_IFID;
    // logic [REG_DATA_WIDTH - 1 : 0] REG_IDEX;
    // logic [REG_DATA_WIDTH - 1 : 0] REG_EXMEM;
    // logic [REG_DATA_WIDTH - 1 : 0] REG_MEMWB;

    /* regfile_2r1w_intf rf_intf(.clk(clk));

    regfile_2r1w regfile (
        .clk(rf_intf.clk),
        .i_raddr_a(rf_intf.i_raddr1),
        .i_raddr_b(rf_intf.i_raddr2),
        .i_wen(rf_intf.i_wen),
        .i_waddr(rf_intf.i_waddr),
        .i_wdata(rf_intf.i_wdata),

        .o_rdata_a(rf_intf.o_rdata1),
        .o_rdata_b(rf_intf.o_rdata2)
    ); */

    mem_sync_sp_intf #(
        .DEPTH(2048),
        .DATA_WIDTH(32),
        .INIT_FILE("codemem.hex")
    ) imem_intf (
        .clk(clk)
    );

    mem_sync_sp imem (imem_intf);


    /* STAGE 1 (IF/ID) */
    always_ff @(posedge clk) begin : stage_1_if_id
        if (!rst_) begin
            REG_IFID <= 'b0;
            REG_PC <= REG_PC_FIRST_LEGAL_ADDRESS;
        end
        else begin
            REG_IFID[0 +: IMEM_DATA_WIDTH] <= im_rdata;
        end
    end : stage_1_if_id

    always_comb begin : wire_assignments
        im_addr = REG_PC[0 +: IMEM_ADDR_WIDTH];
    end : wire_assignments


    /* STAGE 2 (ID/EX) */
    /* always_ff @(posedge clk) begin : stage_2_id_ex
        if (!rst_) begin
            REG_IDEX <= 'b0;
        end
        else begin
            REG_IDEX <= REG_IFID;
        end
    end : stage_2_id_ex */


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
