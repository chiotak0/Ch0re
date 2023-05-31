`ifndef CH0RE_TESTBENCH_SV
`define CH0RE_TESTBENCH_SV

`timescale 1ns/100ps

`include "pipeline/rtl/pipeline_5st.sv"
`include "pipeline/test/tb_pipeline_5st.sv"

module testbench();

    localparam CLOCK_PERIOD = 20; // <=> 50MHz clock

    logic clk;
    logic rst_;

    initial begin
        clk = 1'b0;
        rst_ = 1'b1;

        forever #(CLOCK_PERIOD / 2) clk = ~clk;
    end

    pipeline_5st pl5st(
        .clk(clk),
        .rst_(rst_)
    );

endmodule : testbench

`endif /* CH0RE_TESTBENCH_SV */