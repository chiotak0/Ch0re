`timescale 1ns/100ps

`include "ch0re_types.sv"
`include "debug_prints.sv"

program tb_ch0re_pipeline5st(
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

endprogram: tb_ch0re_pipeline5st

