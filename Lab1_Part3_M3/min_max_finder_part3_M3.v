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



// EE457 RTL Exercises
// min_max_finder_part3_M3.v (Part 3 method 3 (compared to method 1) uses a flag to merge CMx and CMxF and also CMn and CMnF)
// Written by Gandhi Puvvada
// June 5, 2010, 
// Given an array of 16 unsigned 8-bit numbers, we need to find the maximum and the minimum number
 

`timescale 1 ns / 100 ps

module min_max_finder_part3_M3 (Max, Min, Start, Clk, Reset, 
				           Qi, Ql, Qcmx, Qcmn, Qd);

input Start, Clk, Reset;
output [7:0] Max, Min;
output Qi, Ql, Qcmx, Qcmn, Qd;

reg [7:0] M [0:15]; 

reg [4:0] state;
reg       Flag; // The Flag is special to M3 and M4 of Part 3 
reg [7:0] Max;
reg [7:0] Min;
reg [3:0] I;

localparam 
INI  = 	5'b00001, // "Initial" state
LOAD = 	5'b00010, // "Load Max and Min with 1st Element" state
CMx = 	5'b00100, // "Compare each number with Max and Update Max if needed" state
CMn = 	5'b01000, // "Compare each number with Min and Update Min if needed" state
DONE = 	5'b10000; // "Done finding Min and Max" state
         
         
assign {Qd,  Qcmn, Qcmx, Ql, Qi} = state;  

always @(posedge Clk, posedge Reset) 

  begin  : CU_n_DU
    if (Reset)
       begin
         state <= INI;
         I <= 4'bXXXX;   // to avoid recirculating mux controlled by Reset 
	      Max <= 8'bXXXXXXXX;
	      Min <= 8'bXXXXXXXX;
		  Flag <= 1'bX;
	    end
    else
       begin
           case (state)
	        INI	: 
	          begin
		         // RTL operations in the Data Path            	              
		        I <= 0;
				Flag <= 0;
		         // state transitions in the control unit
		         if (Start)
		           state <= LOAD;
	          end
	        LOAD	:
	          begin
		           // RTL operations in the Data Path  
		           Max <= M[I]; // Load M[I] into Max
		           Min <= M[I]; // Load M[I] into Min
		           I <= I + 1;  // Increment I
		           // state transitions in the control unit
		           state <= CMx; // Transit unconditionally to the CMx state         
 	          end
	        
	        CMx :
	          begin 
	            // RTL operations in the Data Path   		                  
                if (M[I] >= Max)
                    begin
                        Max <= M[I];
                        I <= I + 1;
                        Flag <= 0;
                    end
                else if (Flag == 0)
                    begin
                        Flag <= 1;
                    end
                else
                    begin
                        I <= I + 1;
                        Flag <= 0;
                    end

				// state transitions in the control unit    
                if ((M[I] < Max) && (Flag == 0))
                    state <= CMn;
                else if (((M[I] >= Max) || (Flag == 1)) && (I == 15))
                    state <= DONE;
			  end
			  
	        CMn :
	          begin 
	             // RTL operations in the Data Path   		                  
                if (M[I] <= Min)
                    begin
                        Min <= M[I];
                        I <= I + 1;
                        Flag <= 0;
                    end
                else if (Flag == 0)
                    begin
                        Flag <= 1;
                    end
                else
                    begin
                        I <= I + 1;
                        Flag <= 0;
                    end
                    
				 // state transitions in the control unit
                if ((M[I] > Min) && (Flag == 0))
                    state <= CMx;
                else if (((M[I] <= Min) || (Flag == 1)) && (I == 15))
                    state <= DONE;
			  end

	        DONE	:
	          begin  
		         // state transitions in the control unit
		           state <= INI; // Transit to INI state unconditionally
		       end    
      endcase
    end 
  end 
endmodule  // min_max_finder_part3_M3 


