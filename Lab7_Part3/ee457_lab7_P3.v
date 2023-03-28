//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2010 Gandhi Puvvada, EE-Systems, VSoE, USC
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


// File: ee457_lab7_P3.v (incomplete file for students to complete)
// Written by Gandhi Puvvada, July 18, 2010, March 5, 2011
// Components defined in ee457_lab7_components.v are instantiated here.
//  Five stages: IF, ID, EX1, EX2, WB
 
// This design supports SUB3, ADD4, ADD1, and MOV instructions.
//
//--Note to students-------------------------------------------------
// Please go through the code completely. Also go through the related 
// files ee457_lab7_components.v and ee457_lab7_P3_tb.v, which are 
// provided to you in completed form.
// Then complete the areas marked as "Task #".
// Use signal names defined here. Try to avoid defining new signals.
// In instantiating lower-level components, unused inputs are driven 
// with zeros and unused outputs are left open.
// As an example, consider the instantiation of the register file.
// Two of the three read ports are not used. The first read port,
// which is not used, is connected as follows:
//  .r1a(4'b0000),.r1d(),
// The "unused-ports" part of the design is complete and you do not 
// need to modify/complete it.
// If we leave connections for you to complete, we use "complete_it"
// as shown below for the register file.
// .wa(complete_it),.wd(complete_it),.reg_write(complete_it),
//-------------------------------------------------------------------

`timescale 1 ns / 100 ps

module ee457_lab7_P3 (CLK,RSTB);
input CLK,RSTB;

// Local signals -- listed stage-wise
// IF stage signals
wire [7:0] PC_OUT;
wire [31:0] IF_INSTR;
// ID stage signals
wire STALL,STALL_B,ID_MOV,ID_SUB3,ID_ADD4,ID_ADD1,ID_MOV_OUT,ID_SUB3_OUT,ID_ADD4_OUT,ID_ADD1_OUT,ID_XMEX1,ID_XMEX2;
wire [3:0] ID_XA,ID_RA; // 4-bit source register and write register IDs
wire [15:0] ID_XD;
wire [31:0] ID_INSTR, ID_INSTR_or_BUBBLE;
// EX1 stage signals
wire EX1_MOV,EX1_SUB3,EX1_ADD4,EX1_ADD1,PRIORITY,FORW1,SKIP1,EX1_XMEX1,EX1_XMEX2;
wire [3:0] EX1_RA; // 4-bit write register ID
wire [15:0] EX1_XD,EX1_PRIO_XD,EX1_ADDER_IN,EX1_ADDER_OUT,EX1_XD_OUT;
wire [31:0] EX1_INSTR;
// EX2 stage signals
wire EX2_MOV,EX2_SUB3,EX2_ADD4,EX2_ADD1,FORW2,SKIP2,EX2_XMEX1,EX2_WRITE;
wire [3:0] EX2_RA; // 4-bit write register ID
wire [15:0] EX2_XD,EX2_ADDER_IN,EX2_ADDER_OUT,EX2_XD_OUT;
wire [31:0] EX2_INSTR;
// WB stage signals
wire WB_WRITE;
wire [3:0] WB_RA; // 4-bit write register ID
wire [15:0] WB_RD;
wire [31:0] WB_INSTR;

//Instantiating lower-level components plus coding other pieces of combinational logic 

//  Task #3 Complete the enable pin connection on the PC
// module pc (en,clk,rstb,pco);
pc PC(.en(STALL_B),.clk(CLK),.rstb(RSTB),.pco(PC_OUT[7:0]));
//--IF-----------------------------------------------------------------
// module ins_mem(a,d_out);
ins_mem INS_MEM(.a(PC_OUT[5:0]),.d_out(IF_INSTR));

//  Task #4 Complete the enable pin connection on the IF_ID register
// module pipe_if_id_P3(rstb,clk,en,id_xa,id_ra,add1,add4,sub3,mov,instr_in,instr_out);
pipe_if_id_P3 IF_ID(.rstb(RSTB),.clk(CLK),.en(STALL_B),.id_xa(ID_XA),.id_ra(ID_RA),
                    .add1(ID_ADD1),.add4(ID_ADD4),.sub3(ID_SUB3),.mov(ID_MOV),.instr_in(IF_INSTR),.instr_out(ID_INSTR));
//--ID-----------------------------------------------------------------

//  Task #1 Complete the connections to the register file
//  Carefully consider whether the register file write port is driven by 
//  the signals in the ID stage or the signals in WB stage.

// module register_file (r1a,r2a,r3a,wa,wd,reg_write,r1d,r2d,r3d,clk);
register_file REG_FILE(.r1a(4'b0000),.r2a(4'b0000),.r3a(ID_XA),.wa(WB_RA),.wd(WB_RD),
                       .reg_write(WB_WRITE),.r1d(),.r2d(),.r3d(ID_XD),.clk(CLK));

// module comp_station_P3(ex2_ra,ex1_ra,id_xa,xmex2,xmex1);
comp_station_P3 COMP_STATION (.ex2_ra(EX2_RA),.ex1_ra(EX1_RA),.id_xa(ID_XA),
                              .xmex2(ID_XMEX2),.xmex1(ID_XMEX1));

//  Task #2 Complete the following continuous assign statements describing the combinational 
//  logic in ID stage to produce stall and also inject a bubble into EX1 stage if needed 							  
assign STALL = (ID_XMEX1) & (ID_SUB3 | ID_ADD1) & (EX1_ADD4 | EX1_ADD1);
assign STALL_B = ~ STALL;
assign ID_MOV_OUT  = (STALL_B) & (ID_MOV);
assign ID_SUB3_OUT = (STALL_B) & (ID_SUB3);
assign ID_ADD4_OUT = (STALL_B) & (ID_ADD4);
assign ID_ADD1_OUT = (STALL_B) & (ID_ADD1);
assign ID_INSTR_or_BUBBLE = STALL ? 
		{ID_MOV_OUT,ID_SUB3_OUT,ID_ADD4_OUT,ID_ADD1_OUT,20'hFFFFF,ID_INSTR[7:0]} // 20'hFFFFF lets the testbench distinguish a bubble from a NOP
		: 
		{ID_MOV_OUT,ID_SUB3_OUT,ID_ADD4_OUT,ID_ADD1_OUT,ID_INSTR[27:0]};
		
		
//  Task #5 Complete the enable pin connection on the ID_EX1 register  .en(complete_it)
//  If you want to keep it enabled permanently, you can do: .en(1'b1)		
// module pipe_reg2(rstb,clk,en,
// 		vec16_in1,vec16_in2,vec16_in3,vec16_out1,vec16_out2,vec16_out3,
// 		vec4_in1,vec4_in2,vec4_out1,vec4_out2,
// 		bit_in1,bit_in2,bit_in3,bit_in4,bit_in5,bit_in6,bit_out1,bit_out2,bit_out3,bit_out4,bit_out5,bit_out6,instr_in,instr_out);
pipe_reg2 ID_EX1(.rstb(RSTB),.clk(CLK),.en(1'b1),
	.vec16_in1(16'h0000),.vec16_in2(16'h0000),.vec16_in3(ID_XD),.vec16_out1(),.vec16_out2(),.vec16_out3(EX1_XD),
	.vec4_in1(ID_RA),.vec4_in2(4'b0000),.vec4_out1(EX1_RA),.vec4_out2(),
	.bit_in1(ID_MOV_OUT),.bit_in2(ID_SUB3_OUT),.bit_in3(ID_ADD4_OUT),.bit_in4(ID_ADD1_OUT),.bit_in5(ID_XMEX1),.bit_in6(ID_XMEX2),
	.bit_out1(EX1_MOV),.bit_out2(EX1_SUB3),.bit_out3(EX1_ADD4),.bit_out4(EX1_ADD1),.bit_out5(EX1_XMEX1),.bit_out6(EX1_XMEX2),
	.instr_in(ID_INSTR_or_BUBBLE),.instr_out(EX1_INSTR)
	);    
//--EX1-----------------------------------------------------------------

//  Task #6 Complete the following continuous assign statements describing the combinational 
//  logic in EX1 stage to produce PRIORITY, FORW1, and SKIP1 and use them to select data. 

assign PRIORITY = (EX1_XMEX1) & (EX2_SUB3 | EX2_MOV); // Priority between forwarding help from the EX2 stage and the WB stage
assign FORW1 = (PRIORITY) | (EX1_XMEX2 & WB_WRITE); // Decide whether to receive any forwarding help or carry EX1_XD
assign EX1_PRIO_XD = PRIORITY ? EX2_XD : WB_RD; // EX1_PRIO_XD = The output the mux controlled by the selection line PRIORITY
assign EX1_ADDER_IN = FORW1 ? EX1_PRIO_XD : EX1_XD; // EX1_ADDER_IN = The output the forwarding mux which is the input to the adder in EX1
assign EX1_ADDER_OUT = EX1_ADDER_IN + (-3); // Subtract 3
assign SKIP1 = EX1_MOV | EX1_ADD4;          // Decide whether to skip the subtractor result
assign EX1_XD_OUT = SKIP1 ? EX1_ADDER_IN : EX1_ADDER_OUT; // mux to skip the subtractor result, (i.e. select between EX1_ADDER_IN  EX1_ADDER_OUT) Note: EX1_XD_OUT = Data going out of EX1

//  Task #7 Complete the enable pin connection on the EX1_EX2 register  .en(complete_it)
//  If you want to keep it enabled permanently, you can do: .en(1'b1)
//  Also complete .bit_in5(complete_it) and  .bit_out5(complete_it) to carry an important
//  register ID matching signal into EX2. Is it ID_XMEX1 or ID_XMEX2 or EX1_XMEX1 or EX1_XMEX2)?

// module pipe_reg2(rstb,clk,en,
// 		vec16_in1,vec16_in2,vec16_in3,vec16_out1,vec16_out2,vec16_out3,
// 		vec4_in1,vec4_in2,vec4_out1,vec4_out2,
// 		bit_in1,bit_in2,bit_in3,bit_in4,bit_in5,bit_in6,bit_out1,bit_out2,bit_out3,bit_out4,bit_out5,bit_out6,instr_in,instr_out);
pipe_reg2 EX1_EX2(.rstb(RSTB),.clk(CLK),.en(1'b1),
	.vec16_in1(16'h0000),.vec16_in2(16'h0000),.vec16_in3(EX1_XD_OUT),.vec16_out1(),.vec16_out2(),.vec16_out3(EX2_XD),
	.vec4_in1(EX1_RA),.vec4_in2(4'b0000),.vec4_out1(EX2_RA),.vec4_out2(),
	.bit_in1(EX1_MOV),.bit_in2(EX1_SUB3),.bit_in3(EX1_ADD4),.bit_in4(EX1_ADD1),.bit_in5(complete_it),.bit_in6(1'b0),
	.bit_out1(EX2_MOV),.bit_out2(EX2_SUB3),.bit_out3(EX2_ADD4),.bit_out4(EX2_ADD1),.bit_out5(complete_it),.bit_out6(),
	.instr_in(EX1_INSTR),.instr_out(EX2_INSTR)
	);    
//--EX2-----------------------------------------------------------------

//  Task #8 Complete the following continuous assign statements describing the combinational 
//  logic in EX2 stage to produce FORW2 and SKIP2 and use them to select data. 

assign FORW2 = (EX2_XMEX1) & (EX2_MOV | EX2_ADD4) & (WB_WRITE);  // Is it a case of forwarding date from the WB stage
assign EX2_ADDER_IN = FORW2 ? WB_RD : EX2_XD;  // select between EX2_XD and WB_BD
assign EX2_ADDER_OUT = EX2_ADDER_IN + (+4);     // Add 4
assign SKIP2 = EX2_MOV | EX2_SUB3;              // Is it a case of skipping the ADD4 operation
assign EX2_XD_OUT = SKIP2 ? EX2_ADDER_IN : EX2_ADDER_OUT;  // Skip add4 result if needed (i.e. select between EX2_ADDER_IN  EX2_ADDER_OUT)
assign EX2_WRITE = EX2_MOV | EX2_SUB3 | EX2_ADD4 | EX2_ADD1;  // Produce one signal out of EX2_MOV,EX2_SUB3,EX2_ADD4,EX2_ADD1


//  Task #9 Complete the enable pin connection on the EX2_WB register  .en(complete_it)
//  If you want to keep it enabled permanently, you can do: .en(1'b1)
//  Also complete the .bit_in1(complete_it) input corresponding to the .bit_out1(WB_WRITE) output

// module pipe_reg2(rstb,clk,en,
// 		vec16_in1,vec16_in2,vec16_in3,vec16_out1,vec16_out2,vec16_out3,
// 		vec4_in1,vec4_in2,vec4_out1,vec4_out2,
// 		bit_in1,bit_in2,bit_in3,bit_in4,bit_in5,bit_in6,bit_out1,bit_out2,bit_out3,bit_out4,bit_out5,bit_out6,instr_in,instr_out);
pipe_reg2 EX2_WB(.rstb(RSTB),.clk(CLK),.en(1'b1),
	.vec16_in1(16'h0000),.vec16_in2(16'h0000),.vec16_in3(EX2_XD_OUT),.vec16_out1(),.vec16_out2(),.vec16_out3(WB_RD),
	.vec4_in1(EX2_RA),.vec4_in2(4'b0000),.vec4_out1(WB_RA),.vec4_out2(),
	.bit_in1(complete_it),.bit_in2(1'b0),.bit_in3(1'b0),.bit_in4(1'b0),.bit_in5(1'b0),.bit_in6(1'b0),
	.bit_out1(WB_WRITE),.bit_out2(),.bit_out3(),.bit_out4(),.bit_out5(),.bit_out6(),
	.instr_in(EX2_INSTR),.instr_out(WB_INSTR)
	);
//--WB-----------------------------------------------------------------
// There is no explicit logic here. 
// The writing associated with the WB is taken care in the coding of the register file

endmodule // ee457_lab7_P3 
