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

    alu_op_t op_in_r;
    logic valid_in_r;

    logic [WIDTH - 1 : 0] sa_in_r;
    logic [WIDTH - 1 : 0] sb_in_r;
    logic [WIDTH - 1 : 0] result;

    // Register all inputs
    always_ff @(posedge clk) begin: reset_inout_handling
        if ( !rst_n ) begin
            op_in_r <= nop;
            sa_in_r <= 'b0;
            sb_in_r <= 'b0;
            valid_in_r <= 1'b0;

            out <= 'b0;
            valid_out <= 'b0;
        end
        else begin
            op_in_r <= op_in;
            sa_in_r <= sa_in;
            sb_in_r <= sb_in;
            valid_in_r <= valid_in;

            out <= result;
            valid_out <= valid_in_r;
        end
    end: reset_inout_handling

    // Compute the result
    always_comb begin: result_computation
        if ( valid_in_r ) begin
            case ( op_in_r )
                add: result = sa_in_r + sb_in_r;
                sub: result = sa_in_r + (~sb_in_r + 1'b1);
                default: result = 'b0;
            endcase
        end
        else begin
            result = 'b0;
        end
    end: result_computation

endmodule: alu

`endif /* CH0RE_PIPELINE_ALU_SV */

