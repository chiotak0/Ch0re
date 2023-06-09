`timescale 1ns/100fs

interface mem_sync_sp_syn_intf #(
  parameter DEPTH       = 2048,
  parameter ADDR_WIDTH  = $clog2(DEPTH),
  parameter DATA_WIDTH  = 32,
  parameter DATA_BYTES  = DATA_WIDTH/8,
) (
  input logic clk
);

  logic [ADDR_WIDTH-1:0] i_addr;
  logic [DATA_WIDTH-1:0] i_wdata;
  logic [DATA_BYTES-1:0] i_wen;
  logic [DATA_WIDTH-1:0] o_rdata;

  /* modport slave(
	input i_addr, i_wdata, i_wen,
	output o_rdata
  );

  modport master(
	output i_addr, i_wdata, i_wen,
	input o_rdata
  ); */

endinterface

module mem_sync_sp_syn (mem_sync_sp_syn_intf intf);

	generate

		if ( intf.DATA_WIDTH == 32 ) begin

			/* word = 4-Bytes */

			bit [31:0] rdata0;
			bit [31:0] rdata1;
			bit [31:0] rdata2;
			bit [31:0] rdata3;

			/* 4 rows of 4 sram chips */

			SRAM1RW512x8 sram00 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b00)), .WEB(~intf.i_wen[0]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[ 7: 0]), .O(rdata0[ 7: 0]) );
			SRAM1RW512x8 sram01 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b00)), .WEB(~intf.i_wen[1]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[15: 8]), .O(rdata0[15: 8]) );
			SRAM1RW512x8 sram02 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b00)), .WEB(~intf.i_wen[2]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[23:16]), .O(rdata0[23:16]) );
			SRAM1RW512x8 sram03 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b00)), .WEB(~intf.i_wen[3]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[31:24]), .O(rdata0[31:24]) );

			SRAM1RW512x8 sram10 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b01)), .WEB(~intf.i_wen[0]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[ 7: 0]), .O(rdata1[ 7: 0]) );
			SRAM1RW512x8 sram11 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b01)), .WEB(~intf.i_wen[1]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[15: 8]), .O(rdata1[15: 8]) );
			SRAM1RW512x8 sram12 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b01)), .WEB(~intf.i_wen[2]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[23:16]), .O(rdata1[23:16]) );
			SRAM1RW512x8 sram13 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b01)), .WEB(~intf.i_wen[3]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[31:24]), .O(rdata1[31:24]) );

			SRAM1RW512x8 sram20 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b10)), .WEB(~intf.i_wen[0]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[ 7: 0]), .O(rdata2[ 7: 0]) );
			SRAM1RW512x8 sram21 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b10)), .WEB(~intf.i_wen[1]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[15: 8]), .O(rdata2[15: 8]) );
			SRAM1RW512x8 sram22 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b10)), .WEB(~intf.i_wen[2]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[23:16]), .O(rdata2[23:16]) );
			SRAM1RW512x8 sram23 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b10)), .WEB(~intf.i_wen[3]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[31:24]), .O(rdata2[31:24]) );

			SRAM1RW512x8 sram30 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b11)), .WEB(~intf.i_wen[0]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[ 7: 0]), .O(rdata3[ 7: 0]) );
			SRAM1RW512x8 sram31 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b11)), .WEB(~intf.i_wen[1]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[15: 8]), .O(rdata3[15: 8]) );
			SRAM1RW512x8 sram32 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b11)), .WEB(~intf.i_wen[2]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[23:16]), .O(rdata3[23:16]) );
			SRAM1RW512x8 sram33 ( .CE(intf.clk), .OEB(1'b0), .CSB(~(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2]==2'b11)), .WEB(~intf.i_wen[3]), .A(intf.i_addr[intf.ADDR_WIDTH-3:0]), .I(intf.i_wdata[31:24]), .O(rdata3[31:24]) );


			assign intf.o_rdata = (intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2] == 2'b11 ) ? rdata3 :
							(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2] == 2'b10 ) ? rdata2 :
							(intf.i_addr[intf.ADDR_WIDTH-1:intf.ADDR_WIDTH-2] == 2'b01 ) ? rdata1 : rdata0;
		end
		else begin

			/* word = 8-Bytes */

			bit [63:0] rdata0;
			bit [63:0] rdata1;

			/* 2 rows of 8 sram chips */

			SRAM1RW512x8 sram00 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[0]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[ 7: 0]), .O(rdata0[ 7: 0]) );
			SRAM1RW512x8 sram01 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[1]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[15: 8]), .O(rdata0[15: 8]) );
			SRAM1RW512x8 sram02 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[2]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[23:16]), .O(rdata0[23:16]) );
			SRAM1RW512x8 sram03 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[3]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[31:24]), .O(rdata0[31:24]) );
			SRAM1RW512x8 sram04 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[4]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[39:32]), .O(rdata0[39:32]) );
			SRAM1RW512x8 sram05 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[5]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[47:40]), .O(rdata0[47:40]) );
			SRAM1RW512x8 sram06 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[6]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[55:48]), .O(rdata0[55:48]) );
			SRAM1RW512x8 sram07 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[7]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[63:56]), .O(rdata0[63:56]) );

			SRAM1RW512x8 sram10 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[0]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[ 7: 0]), .O(rdata1[ 7: 0]) );
			SRAM1RW512x8 sram11 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[1]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[15: 8]), .O(rdata1[15: 8]) );
			SRAM1RW512x8 sram12 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[2]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[23:16]), .O(rdata1[23:16]) );
			SRAM1RW512x8 sram13 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[3]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[31:24]), .O(rdata1[31:24]) );
			SRAM1RW512x8 sram14 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[4]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[39:32]), .O(rdata1[39:32]) );
			SRAM1RW512x8 sram15 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[5]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[47:40]), .O(rdata1[47:40]) );
			SRAM1RW512x8 sram16 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[6]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[55:48]), .O(rdata1[55:48]) );
			SRAM1RW512x8 sram17 ( .CE(intf.clk), .OEB(1'b0), .CSB(~intf.i_addr[intf.ADDR_WIDTH-1]), .WEB(~intf.i_wen[7]), .A(intf.i_addr[intf.ADDR_WIDTH-2:0]), .I(intf.i_wdata[63:56]), .O(rdata1[63:56]) );

			assign intf.o_rdata = (intf.i_addr[intf.ADDR_WIDTH-1]) ? rdata1 : rdata0;

		end
	endgenerate

endmodule
