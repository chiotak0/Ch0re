`timescale 1ns/1ps

`include "ch0re_types.sv"
`include "debug_prints.sv"

module tb_ch0re_pipeline5st();

    logic clk;
    logic rst_n;

    ch0re_pipeline5st #(
        .IMEM_FILE("../code/example0/example0.imem.dat"),
        .DMEM_FILE("../code/example0/example0.dmem.dat"),
        .IMEM_START('h150)
    ) dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    always #10 clk = ~clk;

    initial begin

        clk = 0;

        rst_n = 1'b0;

        `DBP_PRINT_CURR();
        $write("asserting 'rst_n' (time: %0t)\n", $time);

        #5 rst_n = 1'b1;

        `DBP_PRINT_CURR();
        $write("deasserting 'rst_n' (time: %0d)\n", $time);

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        $finish();
    end

endmodule: tb_ch0re_pipeline5st

