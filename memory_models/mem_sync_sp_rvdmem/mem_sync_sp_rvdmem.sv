interface mem_sync_sp_rvdmem_intf #(
	parameter DEPTH       = 2048,
	parameter DATA_WIDTH  = 64,
	parameter ADDR_WIDTH  = DATA_WIDTH,   // address size equals data size
	parameter DATA_BYTES  = DATA_WIDTH/8,
	parameter INIT_ZERO   = 0,
	parameter INIT_FILE   = "codemem.hex",
	parameter INIT_START  = 0,
	parameter INIT_END    = DEPTH-1
) (
	input wire clk
);

	logic [ADDR_WIDTH-1:0] i_addr;
	logic [DATA_WIDTH-1:0] i_wdata;
	logic [DATA_BYTES-1:0] i_wen;
	logic [DATA_WIDTH-1:0] o_rdata;

endinterface : mem_sync_sp_rvdmem_intf


module mem_sync_sp_rvdmem(mem_sync_sp_rvdmem_intf intf);

//---------------------------------------------------------------------------//
// CUSTOM CODE FOR RISCV SIMULATION
function sim_control;
	input[intf.DATA_WIDTH-1:0] data;
	input[intf.ADDR_WIDTH-1:0] addr;
	begin
		if ( intf.i_addr == 'h40 ) begin
			$write("%c",data[7:0]);
			sim_control = 1;
		end
		else if ( intf.i_addr == 'h50 ) begin
			sim_control = 1;
			$display("Simulation finished at time (%0t) with write to halt address (h%0h = %0d)!",$time,addr, data);
			$display("main() return value = %0d", data);
			$finish;
		end
		else begin
			sim_control = 0;
		end
	end
endfunction

logic [intf.DATA_WIDTH-1:0] cycle = 0;
always @(posedge intf.clk) begin
	cycle <= cycle + 1;
end

function [intf.DATA_WIDTH-1:0] sim_cycle;
	input[intf.ADDR_WIDTH-1:0] addr;
	input rd;
	begin
		sim_cycle = 0;
		if ( rd ) begin
			if ( intf.i_addr == 'h60 ) begin
				$display("time %t cycle %d",$time,cycle);
				sim_cycle = 1;
			end
		end
	end
endfunction

//---------------------------------------------------------------------------//

localparam ADDR_SIZE = $clog2(intf.DEPTH);  	 // 12
localparam ADDR_LOW  = $clog2(intf.DATA_BYTES);  // 3
localparam ADDR_HIGH = ADDR_SIZE + ADDR_LOW - 1; // 14
logic [ADDR_SIZE-1:0] addr;
assign addr = intf.i_addr[ADDR_HIGH : ADDR_LOW];


logic [intf.DATA_WIDTH-1:0] mem [0 : intf.DEPTH-1];

// WRITE_FIRST MODE
always @(posedge intf.clk) begin
	// do not perform writes on sim_control addresses
	if ( (intf.i_wen != 0) && !sim_control(intf.i_wdata, intf.i_addr) )
		for (int i=0 ; i<intf.DATA_BYTES; i++) begin
			if ( intf.i_wen[i] ) begin
				mem[addr][8*i +: 8] = intf.i_wdata[8*i +: 8];
			end
		end

	intf.o_rdata = mem[addr];

	// override with cycle value when reading from the sim cycle address
	if ( sim_cycle(intf.i_addr, (intf.i_wen==0)) ) begin
		intf.o_rdata = cycle;
	end
end

// initialize memory from file
initial begin
	if ( !intf.INIT_ZERO ) begin
		$readmemh(intf.INIT_FILE, mem, intf.INIT_START, intf.INIT_END);
	end
	else begin
		for (int i=0 ; i<intf.DEPTH; i++) begin
			mem[i] = 0;
		end
	end
end

endmodule
