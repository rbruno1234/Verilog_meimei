`timescale 1ns / 1ps

module pulse_0p1sec (
		     input clk,
		     output reg pulse
		     );
   
   // 100MHz clock divide by 10 million - needs 24 bits
   // to simulate faster, define a smaller divider
`ifndef SYNTHESIS
   localparam	MAXDIV = 99999;
`else
   localparam	MAXDIV = 9999999;
`endif

   reg [23:0]		div_cnt = 0;
   
   always @(posedge clk)
     begin
	if (div_cnt >= MAXDIV)
	  begin
	     div_cnt <= 0;
	     pulse <= 1;
	  end
	else
	  begin
	     div_cnt <= div_cnt + 1;
	     pulse <= 0;
	  end
     end

`ifndef SYNTHESIS
   always @(posedge clk)
     begin
	if (pulse) $display("0.1sec pulse");
     end
`endif
   
endmodule

