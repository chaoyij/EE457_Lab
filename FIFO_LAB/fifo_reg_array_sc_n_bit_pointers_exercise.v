//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 Gandhi Puvvada, EE-Systems, VSoE, USC
//
// This design exercise, its solution, and its test-bench are confidential items.
// They are University of Southern California's (USC's) property. All rights are reserved.
// Students in our courses have right only to complete the exercise and submit it as part of their course work.
// They do not have any right on our exercise/solution or even on their completed solution as the solution contains our exercise.
// Students would be violating copyright laws besides the University's Academic Integrity rules if they post or convey to anyone
// either our exercise or our solution or their solution. 
// 
// THIS COPYRIGHT NOTICE MUST BE RETAINED AS PART OF THIS FILE (AND ITS SOLUTION AND/OR ANY OTHER DERIVED FILE) AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////
//
// A student would be violating the University's Academic Integrity rules if he/she gets help in writing or debugging the code 
// from anyone other than the help from his/her lab partner or his/her teaching team members in completing the exercise(s). 
// However he/she can discuss with fellow students the method of solving the exercise. 
// But writing the code or debugging the code should not be with the help of others. 
// One should never share the code or even look at the code of others (code from classmates or seniors 
// or any code or solution posted online or on GitHub).
// 
// THIS NOTICE OF ACADEMIC INTEGRITY MUST BE RETAINED AS PART OF THIS FILE (AND ITS SOLUTION AND/OR ANY OTHER DERIVED FILE) AT ALL TIMES.
//
//////////////////////////////////////////////////////////////////////////////



// File name: 	: fifo_reg_array_sc_n_bit_pointers_exercise.v (sc = single clock)
// Design       : fifo_reg_array_sc 
// Author       : Gandhi Puvvada
// Date			: 10/24/2014, 2/16/2020
// Here, we use only n-bit pointers for wrptr and rdptr, instead of (n+1)-bit pointers.
// Signals almost_empty and almost_full are used so that when the two pointers meet, we know, whether the fifo is actually
// full or empty. Note that this method works only for single clock fifo.
// Modified on 10/30/2014: signal "depth" is added to the port list
// Modified on 2/16/2020: Threshold checking for almost empty and almost full was simplified.

`timescale 1 ns/100 ps

module fifo_reg_array_sc (clk, reset, data_in, wen, ren, data_out, depth, empty, full);

parameter DATA_WIDTH = 16;
parameter ADDR_WIDTH = 4;

input clk, reset;
input wen, ren; // the read or write request for CPU
input [DATA_WIDTH-1:0] data_in;

output [DATA_WIDTH-1:0] data_out;
output [ADDR_WIDTH-1:0] depth;
output empty, full;

reg [ADDR_WIDTH-1:0] rdptr, wrptr; //read pointer and write pointer of FIFO
wire [ADDR_WIDTH-1:0] depth;
wire wenq, renq;// read and write enable for FIFO
reg full, empty;

reg [DATA_WIDTH-1:0] Reg_Array [(2**ADDR_WIDTH)-1:0];// FIFO array
reg AE_AF_flag; // zero means almost empty and one means almost full
wire  raw_almost_empty, raw_almost_full;


wire [ADDR_WIDTH-1:0] N_zeros = {(ADDR_WIDTH){1'b0}};


assign depth = wrptr - rdptr;


// task #1: complete the two assign statements using as few and as small gates as possible 
// (and using as few higher-order bits of depth as possible).
assign raw_almost_full  = (depth[2] & depth[1]);
assign raw_almost_empty = (~depth[2] & depth[1]);


always@(*)
begin
	empty = 1'b0;
	full = 1'b0;
//task #2: fill in the conditions for signal "empty" and "full".
	if ( (depth == N_zeros) & (AE_AF_flag == 1'b0)  )
		empty = 1'b1;
	if ( (depth == N_zeros) & (AE_AF_flag == 1'b1)  ) 
		full = 1'b1;
end

assign wenq = (~full) & wen;// only if the FIFO is not full and there is write request from CPU, we enable the write to FIFO.
assign renq = (~empty)& ren;// only if the FIFO is not empty and there is read request from CPU, we enable the read to FIFO.
assign data_out = Reg_Array[rdptr];

always@(posedge clk, posedge reset)
begin
    if (reset)
		begin
			wrptr <= N_zeros;
			rdptr <= N_zeros;
			AE_AF_flag <= 1'b0;
		end
	else
		begin
// task #3: complete these two if statements.  You may want to refer to the n-plus-1 pointer design
			if (wenq) 
				begin

				Reg_Array[wrptr[ADDR_WIDTH-1:0]] <= data_in;  // we use the lower N bits of the (N+1)-bit pointer as index to the 2**N array.
				wrptr <= wrptr + 1;
				
				end
			if (renq)
				begin

				rdptr <= rdptr + 1;
				
				end
			
// task #4: complete set and reset of AE_AF_flag (zero means almost empty and one means almost full).
			if (raw_almost_full)
					AE_AF_flag <= 1'b1;
			if (raw_almost_empty)
					AE_AF_flag <= 1'b0;
		end
end

endmodule // fifo_reg_array_sc
