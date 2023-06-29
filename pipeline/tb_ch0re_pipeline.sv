`timescale 1ns/1ps

`include "ch0re_types.sv"
`include "pipeline/pipeline_reg_info.sv"
`include "debug_prints.sv"

`define EXMEMR_ALU_OUT   0+:64
`define EXMEMR_LSU_OP    133+:2

// `define DEBUG

module tb_ch0re_pipeline();

    logic clk;
    logic rst_n;

    ch0re_pipeline #(
        // .IMEM_FILE("../code/example3/coremark.imem.dat"),
        // .DMEM_FILE("../code/example3/coremark.dmem.dat"),
        .IMEM_FILE("../code/compliance_tests/or.imem.dat"),
        .DMEM_FILE("../code/compliance_tests/or.dmem.dat"),
        .IMEM_START('h100)
        // .IMEM_END('h160 - 'h1)
    ) dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    always #10 clk = ~clk;

    initial begin

        clk = 0;

        `DBP_PRINT_CURR();
        $write("asserting 'rst_n' (time: %0t)\n", $time);
        rst_n = 1'b0;
        @(posedge clk);

        `DBP_PRINT_CURR();
        $write("deasserting 'rst_n' (time: %0t)\n", $time);
        #1;
        rst_n = 1'b1;

        for(;;) @(posedge clk);
        // run_print_pipeline(200);

        `DBP_PRINT_CURR();
        $write({`DBP_SUCCESS, "\n"});

        $finish();
    end

    final begin
        `DBP_PRINT_CURR();
        $write("last test '%0d'\n", dut.regfile.rf[REG_X28_T3]);
    end

    task run_print_pipeline(input int total_cycles);

        alu_op_e aop;
        lsu_op_e lop;
        alu_mux1_sel_e am1s;
        alu_mux2_sel_e am2s;
        data_type_e dt;
        iformat_e ifmt;

        ++total_cycles;

        for (int cycle = 2; cycle <= total_cycles; ++cycle) begin

            @(posedge clk);

            `ifdef DEBUG
            $display("cycle = '%0d'", cycle);
            `endif


            /* STAGE-1 */

            `ifdef DEBUG
            $display({`DBP_BOLD, `DBP_FGREEN, "STAGE-1:", `DBP_RST});
            $display("  - dut.PCR = h%0h (%0d) [t%0t]", dut.PCR, dut.PCR, $time);
            `endif


            /* STAGE-2 */

            `ifdef DEBUG
            $display({`DBP_BOLD, `DBP_FGREEN, "STAGE-2:", `DBP_RST});
            $display("  - dut.IFIDR = h%0h (%0d)\n", dut.IFIDR, dut.IFIDR);
            $display("  - dut.idec.DISNIR = 1'b%1b", dut.idec.DISNIR);
            $display("  - dut.idec_intf.i_instr = h%0h", dut.idec_intf.i_instr);
            $display("  - dut.idec_intf.o_pl_stall = 1'b%0b\n", dut.idec_intf.o_pl_stall);

            $display("  - dut.idec_intf.o_rf_waddr = %0d", dut.idec_intf.o_rf_waddr);
            $display("  - dut.idec_intf.o_rf_raddr1 = %0d", dut.idec_intf.o_rf_raddr1);
            $display("  - dut.idec_intf.o_rf_raddr2 = %0d\n", dut.idec_intf.o_rf_raddr2);

            $display("  - dut.idec_intf.o_alu_mux1_sel = %0s", dut.idec_intf.o_alu_mux1_sel);
            $display("  - dut.idec_intf.o_alu_mux2_sel = %0s\n", dut.idec_intf.o_alu_mux2_sel);

            $display("  - dut.idec_intf.o_lsu_op = %0s", dut.idec_intf.o_lsu_op);
            $display("  - dut.idec_intf.o_alu_op = %0s", dut.idec_intf.o_alu_op);
            $display("  - dut.idec_intf.o_instr_format = %0s", dut.idec_intf.o_instr_format);
            `endif


            /* STAGE-3 */

            `ifdef DEBUG
            aop = alu_op_e'(dut.IDEXR[`IDEXR_ALU_OP]);
            am1s = alu_mux1_sel_e'(dut.IDEXR[`IDEXR_ALU_MUX1_SEL]);
            am2s = alu_mux2_sel_e'(dut.IDEXR[`IDEXR_ALU_MUX2_SEL]);
            dt = data_type_e'(dut.IDEXR[`IDEXR_DATA_TYPE]);
            lop = lsu_op_e'(dut.IDEXR[`IDEXR_LSU_OP]);
            ifmt = iformat_e'(dut.IDEXR[`IDEXR_IFORMAT]);

            $display({`DBP_BOLD, `DBP_FGREEN, "STAGE-3:", `DBP_RST});
            $display("  - dut.STALLR = 1'b%0b", dut.STALLR);
            $display("  - dut.IDEXR[`IDEXR_IMM] = h%0h (%0d)", dut.IDEXR[`IDEXR_IMM], dut.IDEXR[`IDEXR_IMM]);
            $display("  - dut.IDEXR[`IDEXR_RS1] = h%0h (%0d)", dut.IDEXR[`IDEXR_RS1], dut.IDEXR[`IDEXR_RS1]);
            $display("  - dut.IDEXR[`IDEXR_RS2] = h%0h (%0d)", dut.IDEXR[`IDEXR_RS2], dut.IDEXR[`IDEXR_RS2]);
            $display("  - dut.IDEXR[`IDEXR_PC] = h%0h (%0d)", dut.IDEXR[`IDEXR_PC], dut.IDEXR[`IDEXR_PC]);
            $display("  - dut.IDEXR[`IDEXR_RD] = %0d", dut.IDEXR[`IDEXR_RD]);
            $display("  - dut.IDEXR[`IDEXR_ALU_OP] = %0s", aop.name());
            $display("  - dut.IDEXR[`IDEXR_ALU_MUX1_SEL] = %0s (%0d)", am1s.name(), dut.IDEXR[`IDEXR_ALU_MUX1_SEL]);
            $display("  - dut.IDEXR[`IDEXR_ALU_MUX2_SEL] = %0s (%0d)", am2s.name(), dut.IDEXR[`IDEXR_ALU_MUX1_SEL]);
            $display("  - dut.IDEXR[`IDEXR_DATA_TYPE] = %0s", dt.name());
            $display("  - dut.IDEXR[`IDEXR_BRANCH_TARGET] = h%0h (%0d)", dut.IDEXR[`IDEXR_BRANCH_TARGET], dut.IDEXR[`IDEXR_BRANCH_TARGET]);
            $display("  - dut.IDEXR[`IDEXR_LSU_OP] = %0s", lop.name());
            $display("  - dut.IDEXR[`IDEXR_WEN] = %0d", dut.IDEXR[`IDEXR_WEN]);
            $display("  - dut.IDEXR[`IDEXR_IFORMAT] = %0s", ifmt.name());
            `endif


            /* STAGE-4 */

            `ifdef DEBUG
            lop = lsu_op_e'(dut.EXMEMR[`EXMEMR_LSU_OP]);
            dt = data_type_e'(dut.EXMEMR[`EXMEMR_DATA_TYPE]);
            ifmt = iformat_e'(dut.EXMEMR[`EXMEMR_IFORMAT]);

            $display({`DBP_BOLD, `DBP_FGREEN, "STAGE-4:", `DBP_RST});
            $display("  - dut.dmem_intf.i_addr = h%0h", dut.dmem_intf.i_addr);
            $display("  - dut.EXMEMR[`EXMEMR_ALU_OUT] = h%0h (%0d)", dut.EXMEMR[`EXMEMR_ALU_OUT], dut.EXMEMR[`EXMEMR_ALU_OUT]);
            $display("  - dut.EXMEMR[`EXMEMR_RS2] = %0d", dut.EXMEMR[`EXMEMR_RS2]);
            $display("  - dut.EXMEMR[`EXMEMR_RD] = %0d", dut.EXMEMR[`EXMEMR_RD]);
            $display("  - dut.EXMEMR[`EXMEMR_LSU_OP] = %0s", lop.name());
            $display("  - dut.EXMEMR[`EXMEMR_DATA_TYPE] = %0s", dt.name());
            $display("  - dut.EXMEMR[`EXMEMR_WEN] = %0d", dut.EXMEMR[`EXMEMR_WEN]);
            $display("  - dut.EXMEMR[`EXMEMR_IFORMAT] = %0s", ifmt.name());
            `endif


            /* STAGE-5 */

            `ifdef DEBUG
            lop = lsu_op_e'(dut.MEMWBR[`MEMWBR_LSU_OP]);
            dt = data_type_e'(dut.MEMWBR[`MEMWBR_DATA_TYPE]);

            $display({`DBP_BOLD, `DBP_FGREEN, "STAGE-5:", `DBP_RST});
            $display("  - dut.wb_data = h%0h (%0d)", dut.wb_data, dut.wb_data);
            $display("  - dut.MEMWBR[`MEMWBR_ALU_OUT] = h%0h (%0d)", dut.MEMWBR[`MEMWBR_ALU_OUT], dut.MEMWBR[`MEMWBR_ALU_OUT]);
            $display("  - dut.MEMWBR[`MEMWBR_LSU_OP] = %0s", lop.name());
            $display("  - dut.MEMWBR[`MEMWBR_RD] = %0d", dut.MEMWBR[`MEMWBR_RD]);
            $display("  - dut.MEMWBR[`MEMWBR_WEN] = %0d", dut.MEMWBR[`MEMWBR_WEN]);
            $display("  - dut.MEMWBR[`MEMWBR_DATA_TYPE] = %0s", dt.name());

            $display();
            `endif

        end

    endtask

endmodule: tb_ch0re_pipeline

