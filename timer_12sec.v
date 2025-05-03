`timescale 1ns / 1ps

module timer_12sec (clk, countdown);

   input		      clk;
   output reg [6:0]	      countdown = 0;

   wire			      pulse;

   pulse_0p1sec u1 (.clk(clk), .pulse(pulse));
   
   always @(posedge clk)
     begin
	if (pulse) begin
	  if (countdown == 0)
	    countdown <= 120;  // start at 12 seconds, in units of 10ths of a second
	  else
	    countdown <= countdown - 1;
	end
     end

endmodule
   
