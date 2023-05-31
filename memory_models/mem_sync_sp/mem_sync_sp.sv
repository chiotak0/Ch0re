`ifndef CH0RE_MEM_SYNC_SP
`define CH0RE_MEM_SYNC_SP

interface mem_sync_sp_intf #(
	parameter DEPTH       = 2048,
	parameter ADDR_WIDTH  = $clog2(DEPTH),
	parameter DATA_WIDTH  = 64,
	parameter DATA_BYTES  = DATA_WIDTH / 8,
	parameter INIT_ZERO   = 0,
	parameter INIT_FILE   = "codemem.hex",
	parameter INIT_START  = 0,
	parameter INIT_END    = DEPTH - 1
) (
	input wire clk
);
	logic [ADDR_WIDTH - 1 : 0] i_addr;
	logic [DATA_WIDTH - 1 : 0] i_wdata;
	logic [DATA_BYTES - 1 : 0] i_wen;

	logic [DATA_WIDTH - 1 : 0] o_rdata;

endinterface : mem_sync_sp_intf


module mem_sync_sp(mem_sync_sp_intf intf);

	logic [intf.DATA_WIDTH - 1 : 0] mem [0 : intf.DEPTH - 1];

	// WRITE_FIRST MODE
	always @(posedge intf.clk) begin
		for (int i = 0 ; i < intf.DATA_BYTES; ++i) begin
			if ( intf.i_wen[i] ) begin
				mem[intf.i_addr][8 * i +: 8] = intf.i_wdata[8*i +: 8];
			end
		end

		intf.o_rdata = mem[intf.i_addr];
	end

	// initialize memory from file
	initial begin
		if ( !intf.INIT_ZERO ) begin
			$readmemh(intf.INIT_FILE, mem, intf.INIT_START, intf.INIT_END);
		end
		else begin
			for (int i = 0 ; i < intf.DEPTH; ++i) begin
				mem[i] = 0;
			end
		end
	end

endmodule

`endif /* CH0RE_MEM_SYNC_SP */
