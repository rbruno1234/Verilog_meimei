

// breakable block

module block #(parameter xloc=120,
	      parameter	yloc=100,
	      parameter	xsize_div_2 = 20,
	      parameter	ysize_div_2 = 10)
   (
    input	     clk, // 100 MHz system clock
    input	     pixpulse, // every 4 clocks for 25MHz pixel rate
    input	     rst,
    input [9:0]	     hcount, // x-location where we are drawing
    input [9:0]	     vcount, // y-location where we are drawing
    input	     empty, // is this pixel empty
    input	     move, // signal to update the status of the block
    input	     unbreak,  // reset the block
    output	     draw_block, // is the block being drawn here?
    output reg	     broken // is this block broken
    );

   reg [ysize_div_2*2:0]			 occupied_lft;
   reg [ysize_div_2*2:0]			 occupied_rgt;
   reg [xsize_div_2*2:0]			 occupied_bot;
   reg [xsize_div_2*2:0]			 occupied_top;

   wire				 blk_lft, blk_rgt;
   wire				 blk_up, blk_dn;
   
   assign draw_block = (hcount <= xloc+xsize_div_2) & (hcount >= xloc-xsize_div_2) & 
			(vcount <= yloc+ysize_div_2) & (vcount >= yloc-ysize_div_2) ?  ~broken : 0;

   // hcount goes from 0=left to 640=right
   // vcount goes from 0=top to 480=bottom
   
   // keep track of the neighboring pixels to detect a collision
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   occupied_lft <= 0;
	   occupied_rgt <= 0;
	   occupied_bot <= 0;
	   occupied_top <= 0;
	end else if (pixpulse) begin  // only make changes when pixpulse is high
	   if (vcount >= yloc-(ysize_div_2+1) && vcount <= yloc+(ysize_div_2+1)) 
	     if (hcount == xloc+(xsize_div_2+1))
	       occupied_rgt[(yloc-vcount+(ysize_div_2+1))] <= ~empty;  // LSB is at bottom
	     else if (hcount == xloc-(xsize_div_2+1))
	       occupied_lft[(yloc-vcount+(ysize_div_2+1))] <= ~empty;
	      
	   if (hcount >= xloc-(xsize_div_2+1) && hcount <= xloc+(xsize_div_2+1)) 
	     if (vcount == yloc+(ysize_div_2+1))
	       occupied_bot[(xloc-hcount+(xsize_div_2+1))] <= ~empty;  // LSB is at right
	     else if (vcount == yloc-(ysize_div_2+1))
	       occupied_top[(xloc-hcount+(xsize_div_2+1))] <= ~empty;
	end
     end	      

   assign blk_lft = |occupied_lft;  // upper left pixels are blocked
   assign blk_rgt = |occupied_rgt;  // upper right pixels are blocked

   assign blk_up = |occupied_top;  // left-side top pixels are blocked
   assign blk_dn = |occupied_bot;  // left-side bottom pixels are blocked

   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   broken <= 0;
	end else if (pixpulse) begin
	   if (unbreak) begin
	      broken <= 0;
	   end
	   if (move) begin
	      if (blk_lft | blk_dn | blk_up | blk_rgt) begin
		 broken <= 1;
	      end
	   end 
	end 
     end
   
endmodule 
