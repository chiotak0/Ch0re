`ifndef CH0RE_TESTBENCH_SV
`define CH0RE_TESTBENCH_SV

`timescale 1ns/100ps


module testbench();

    localparam CLOCK_PERIOD = 20; // <=> 50MHz clock

    logic clk;
    logic rst_;

    initial begin
        clk = 1'b0;
        forever #(CLOCK_PERIOD / 2) clk = ~clk;
    end

    pipeline_5st #(
        .IMEM_DEPTH(16),
        .IMEM_FILE("code/example0/example0.imem.dat")
    ) dut (
        .clk(clk),
        .rst_(rst_)
    );

    tb_pipeline_5st tb_pl5st(.*);

endmodule : testbench

`endif /* CH0RE_TESTBENCH_SV */