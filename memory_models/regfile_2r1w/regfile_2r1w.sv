`ifndef REGFILE_2R1W_SV
`define REGFILE_2R1W_SV

interface regfile_2r1w_intf #(
	parameter DATA_WIDTH = 32,
	parameter REG_FILE_SIZE = 32
) (
	input wire clk
);
	localparam REG_FILE_ADDR_WIDTH = $clog2(REG_FILE_SIZE);

	logic [REG_FILE_ADDR_WIDTH - 1 : 0] i_raddr1;
	logic [REG_FILE_ADDR_WIDTH - 1 : 0] i_raddr2;

	logic [REG_FILE_ADDR_WIDTH - 1 : 0] i_waddr;
	logic [DATA_WIDTH - 1 : 0] i_wdata;
	logic i_wen;

	logic [DATA_WIDTH - 1 : 0] o_rdata1;
	logic [DATA_WIDTH - 1 : 0] o_rdata2;

	clocking CBrf @(posedge clk);
		output i_raddr1, i_raddr2, i_waddr, i_wdata, i_wen;
		input o_rdata1, o_rdata2;
	endclocking

endinterface : regfile_2r1w_intf


module regfile_2r1w (regfile_2r1w_intf intf);

	localparam DH = 1;

	logic [intf.DATA_WIDTH - 1 : 0] rf [0 : intf.REG_FILE_SIZE - 1];
	logic wen;

	assign wen = intf.i_wen & ~(intf.i_waddr == 0);

	always @(posedge intf.clk) begin
		if ( wen ) begin
			rf[intf.i_waddr] <= intf.i_wdata;
		end
	end

	assign #DH intf.o_rdata1 = rf[intf.i_raddr1];
	assign #DH intf.o_rdata2 = rf[intf.i_raddr2];

	initial begin
		for (int i = 0 ; i < intf.REG_FILE_SIZE; ++i) begin
			rf[i] = 0;
		end
	end

endmodule

`endif /* REGFILE_2R1W_SV */
