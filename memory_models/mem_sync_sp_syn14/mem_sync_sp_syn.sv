`timescale 1ns/100fs

module mem_sync_sp_syn #(
  parameter DEPTH       = 2048,
  parameter ADDR_WIDTH  = $clog2(DEPTH),
  parameter DATA_WIDTH  = 32,
  parameter DATA_BYTES  = DATA_WIDTH/8,
  parameter INIT_ZERO   = 0,
  parameter INIT_FILE   = "mem.hex",
  parameter INIT_START  = 0,
  parameter INIT_END    = DEPTH-1
) (
  input                         clk,

  input      [ADDR_WIDTH-1:0]   i_addr,
  input      [DATA_WIDTH-1:0]   i_wdata,
  input      [DATA_BYTES-1:0]   i_wen,
  output reg [DATA_WIDTH-1:0]   o_rdata
);

generate
  if ( DATA_WIDTH == 32 ) begin
    bit [31:0] rdata0;
    bit [31:0] rdata1;
    bit [31:0] rdata2;
    bit [31:0] rdata3;

    SRAM1RW512x8 sram00 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b00)), .WEB(~i_wen[0]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[ 7: 0]), .O(rdata0[ 7: 0]) );
    SRAM1RW512x8 sram01 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b00)), .WEB(~i_wen[1]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[15: 8]), .O(rdata0[15: 8]) );
    SRAM1RW512x8 sram02 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b00)), .WEB(~i_wen[2]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[23:16]), .O(rdata0[23:16]) );
    SRAM1RW512x8 sram03 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b00)), .WEB(~i_wen[3]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[31:24]), .O(rdata0[31:24]) );
    SRAM1RW512x8 sram10 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b01)), .WEB(~i_wen[0]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[ 7: 0]), .O(rdata1[ 7: 0]) );
    SRAM1RW512x8 sram11 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b01)), .WEB(~i_wen[1]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[15: 8]), .O(rdata1[15: 8]) );
    SRAM1RW512x8 sram12 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b01)), .WEB(~i_wen[2]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[23:16]), .O(rdata1[23:16]) );
    SRAM1RW512x8 sram13 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b01)), .WEB(~i_wen[3]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[31:24]), .O(rdata1[31:24]) );
    SRAM1RW512x8 sram20 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b10)), .WEB(~i_wen[0]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[ 7: 0]), .O(rdata2[ 7: 0]) );
    SRAM1RW512x8 sram21 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b10)), .WEB(~i_wen[1]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[15: 8]), .O(rdata2[15: 8]) );
    SRAM1RW512x8 sram22 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b10)), .WEB(~i_wen[2]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[23:16]), .O(rdata2[23:16]) );
    SRAM1RW512x8 sram23 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b10)), .WEB(~i_wen[3]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[31:24]), .O(rdata2[31:24]) );
    SRAM1RW512x8 sram30 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b11)), .WEB(~i_wen[0]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[ 7: 0]), .O(rdata3[ 7: 0]) );
    SRAM1RW512x8 sram31 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b11)), .WEB(~i_wen[1]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[15: 8]), .O(rdata3[15: 8]) );
    SRAM1RW512x8 sram32 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b11)), .WEB(~i_wen[2]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[23:16]), .O(rdata3[23:16]) );
    SRAM1RW512x8 sram33 ( .CE(clk), .OEB(1'b0), .CSB(~(i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2]==2'b11)), .WEB(~i_wen[3]), .A(i_addr[ADDR_WIDTH-3:0]), .I(i_wdata[31:24]), .O(rdata3[31:24]) );


    assign o_rdata = (i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2] == 2'b11 ) ? rdata3 :
                     (i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2] == 2'b10 ) ? rdata2 :
                     (i_addr[ADDR_WIDTH-1:ADDR_WIDTH-2] == 2'b01 ) ? rdata1 : rdata0;
  end
  else begin
    bit [63:0] rdata0;
    bit [63:0] rdata1;
    SRAM1RW512x8 sram00 ( .CE(clk), .OEB(1'b0), .CSB( i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[0]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[ 7: 0]), .O(rdata0[ 7: 0]) );
    SRAM1RW512x8 sram01 ( .CE(clk), .OEB(1'b0), .CSB( i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[1]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[15: 8]), .O(rdata0[15: 8]) );
    SRAM1RW512x8 sram02 ( .CE(clk), .OEB(1'b0), .CSB( i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[2]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[23:16]), .O(rdata0[23:16]) );
    SRAM1RW512x8 sram03 ( .CE(clk), .OEB(1'b0), .CSB( i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[3]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[31:24]), .O(rdata0[31:24]) );
    SRAM1RW512x8 sram04 ( .CE(clk), .OEB(1'b0), .CSB( i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[4]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[39:32]), .O(rdata0[39:32]) );
    SRAM1RW512x8 sram05 ( .CE(clk), .OEB(1'b0), .CSB( i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[5]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[47:40]), .O(rdata0[47:40]) );
    SRAM1RW512x8 sram06 ( .CE(clk), .OEB(1'b0), .CSB( i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[6]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[55:48]), .O(rdata0[55:48]) );
    SRAM1RW512x8 sram07 ( .CE(clk), .OEB(1'b0), .CSB( i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[7]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[63:56]), .O(rdata0[63:56]) );
    SRAM1RW512x8 sram10 ( .CE(clk), .OEB(1'b0), .CSB(~i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[0]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[ 7: 0]), .O(rdata1[ 7: 0]) );
    SRAM1RW512x8 sram11 ( .CE(clk), .OEB(1'b0), .CSB(~i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[1]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[15: 8]), .O(rdata1[15: 8]) );
    SRAM1RW512x8 sram12 ( .CE(clk), .OEB(1'b0), .CSB(~i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[2]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[23:16]), .O(rdata1[23:16]) );
    SRAM1RW512x8 sram13 ( .CE(clk), .OEB(1'b0), .CSB(~i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[3]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[31:24]), .O(rdata1[31:24]) );
    SRAM1RW512x8 sram14 ( .CE(clk), .OEB(1'b0), .CSB(~i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[4]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[39:32]), .O(rdata1[39:32]) );
    SRAM1RW512x8 sram15 ( .CE(clk), .OEB(1'b0), .CSB(~i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[5]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[47:40]), .O(rdata1[47:40]) );
    SRAM1RW512x8 sram16 ( .CE(clk), .OEB(1'b0), .CSB(~i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[6]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[55:48]), .O(rdata1[55:48]) );
    SRAM1RW512x8 sram17 ( .CE(clk), .OEB(1'b0), .CSB(~i_addr[ADDR_WIDTH-1:0]), .WEB(~i_wen[7]), .A(i_addr[ADDR_WIDTH-2:0]), .I(i_wdata[63:56]), .O(rdata1[63:56]) );

    assign o_rdata = (i_addr[ADDR_WIDTH-1]) ? rdata1 : rdata0;

  end
endgenerate

endmodule
