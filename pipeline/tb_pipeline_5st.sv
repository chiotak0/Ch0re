`ifndef CH0RE_TEST_PIPELINE_5ST_SV
`define CH0RE_TEST_PIPELINE_5ST_SV

// `include "pipeline/rtl/pipeline_5st.sv"

program tb_pipeline_5st(
    input logic clk,
    output logic rst_
);

    initial begin

        $display("[\033[1;32mINFO\033[0m]: \033[2m%m\033[0m\n");

        #1 rst_ = 1'b0;

        @(posedge clk);

        #1 rst_ = 1'b1;

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        $finish();
    end

endprogram: tb_pipeline_5st

`endif /* CH0RE_TEST_PIPELINE_5ST_SV */
