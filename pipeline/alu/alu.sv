`ifndef CH0RE_PIPELINE_ALU_SV
`define CH0RE_PIPELINE_ALU_SV

typedef enum logic [1:0] {

    nop = 2'h0,
    add = 2'h1,
    sub = 2'h2
} alu_op_t;

module alu #(
    parameter WIDTH = 6
) (
    input logic clk,
    input logic rst_n,

    input alu_op_t op_in,
    input logic valid_in,

    input logic [WIDTH - 1 : 0] sa_in,
    input logic [WIDTH - 1 : 0] sb_in,

    output logic valid_out,

    output logic [WIDTH - 1 : 0] out
);

   //

endmodule: alu

`endif /* CH0RE_PIPELINE_ALU_SV */

