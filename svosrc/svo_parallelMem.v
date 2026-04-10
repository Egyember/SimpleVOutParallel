/*
 *  SVO - Simple Video Out FPGA Core
 *
 *  Copyright (C) 2014  Clifford Wolf <clifford@clifford.at>
 *  
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1ns / 1ps
`include "svo_defines.vh"

module svo_parallelMem #( `SVO_DEFAULT_PARAMS ) (
	input clk, resetn,

	// output stream
	//   tuser[0] ... start of frame
	output wire out_axis_tvalid,	//color output valid
	input wire out_axis_tready,	//next stage waits for color
	output wire [SVO_BITS_PER_PIXEL-1:0] out_axis_tdata, //color data
	output reg [0:0] out_axis_tuser, //timeing


input wire in_axis_tvalid,	//input color  valid
output wire in_axis_tready, //need color

output reg [`SVO_XYBITS-1:0] hcursor,
output reg [`SVO_XYBITS-1:0] vcursor,

input wire [SVO_BITS_PER_RED-1:0] r,
input wire [SVO_BITS_PER_GREEN-1:0] g,
input wire [SVO_BITS_PER_BLUE-1:0] b
);
`SVO_DECLS


assign out_axis_tdata = {b, g, r};
assign out_axis_tvalid = in_axis_tvalid;
assign in_axis_tready = out_axis_tready;

initial begin
		hcursor <= 0;
		vcursor <= 0;
		out_axis_tuser <= 0;
end

always @(posedge in_axis_tvalid or negedge resetn) begin
	if (!resetn) begin
		hcursor <= 0;
		vcursor <= 0;
		out_axis_tuser <= 0;
	end else begin
		out_axis_tuser[0] <= (hcursor==0) && (vcursor==0);

		if (hcursor == SVO_HOR_PIXELS-1) begin
			hcursor <= 0;
			if (vcursor == SVO_VER_PIXELS-1) begin
				vcursor <= 0;
			end else begin
				vcursor <= vcursor + 1;
			end
		end else begin
			hcursor <= hcursor + 1;
		end
	end
end

endmodule
