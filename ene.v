`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2025 01:27:46 PM
// Design Name: 
// Module Name: ene
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////




// 3x3 ball drawing and movement control 

module ene #(parameter xsize=21,
	      parameter ysize=21)
   (
    input	     clk, // 100 MHz system clock
    input	     pixpulse, // every 4 clocks for 25MHz pixel rate
    input	     rst,
    input [9:0]	     hcount, // x-location where we are drawing
    input [9:0]	     vcount, // y-location where we are drawing
    input[9:0]       xloc_start,
    input[9:0]       yloc_start,
    input[2:0]	     empty, // is this pixel empty
    input	     move, // signal to update the location of the ball
    input       xdir_start,
    input       ydir_start,
    output	     draw_ene, // is the ball being drawn here?
    output reg [9:0] xloc, // x-location of the ball
    output reg [9:0] yloc // y-location of the ball
    );

   wire emptystore=(&empty[2:0]);
   reg hit;
   reg hitstore;
   reg [xsize+1:0]			 occupied_lft;
   reg [xsize+1:0]			 occupied_rgt;
   reg [ysize+1:0]			 occupied_bot;
   reg [ysize+1:0]			 occupied_top;
   reg				 xdir,ydir;
   reg				 update_neighbors;

   wire				 blk_lft_up, blk_lft_dn, blk_rgt_up, blk_rgt_dn;
   wire				 blk_up_lft, blk_up_rgt, blk_dn_lft, blk_dn_rgt;
   wire				 corner_lft_up, corner_rgt_up, corner_lft_dn, corner_rgt_dn;
   
   // are we pointing at a pixel in the ball?
   // this will make a square ball...
   assign draw_ene = (hcount <= xloc+((xsize-1)/2)) & (hcount >= xloc-((xsize-1)/2)) & (vcount <= yloc+((ysize-1)/2)) & (vcount >= yloc-((ysize-1)/2)) ?  ~hitstore : 0;

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
	   if (update_neighbors) begin
	      occupied_lft <= 0;
	      occupied_rgt <= 0;
	      occupied_bot <= 0;
	      occupied_top <= 0;
	   end else if (~emptystore) begin
	      if (vcount >= yloc-(1+(ysize-1)/2) && vcount <= yloc+(1+(ysize-1)/2)) begin
		
		if (hcount == xloc+(1+(xsize-1)/2))begin
		  occupied_rgt[(yloc-vcount+(1+(ysize-1)/2))] <= ~emptystore;  // LSB is at bottom
		  hit<=~empty[0];
		  end
		  
		else if (hcount == xloc-(1+(xsize-1)/2)) begin
		  occupied_lft[(yloc-vcount+(1+(ysize-1)/2))] <= ~emptystore;
		  hit<=~empty[0];
		  end
		 end 
	      
	      if (hcount >= xloc-(1+(xsize-1)/2) && hcount <= xloc+(1+(xsize-1)/2)) begin
	      
		if (vcount == yloc+(1+(ysize-1)/2))begin
		  occupied_bot[(xloc-hcount+(1+(xsize-1)/2))] <= ~emptystore;  // LSB is at right
		  hit<=~empty[0];
		  end		  
		  
		else if (vcount == yloc-(1+(ysize-1)/2))begin
		  occupied_top[(xloc-hcount+(1+(xsize-1)/2))] <= ~emptystore;
		  hit<=~empty[0];
		  end
		 end
		  
	   end
	end
   end	      


   assign blk_lft_up = |occupied_lft[xsize:2];  // upper left pixels are blocked
   assign blk_lft_dn = |occupied_lft[xsize-1:1];  // lower left pixels are blocked
   assign blk_rgt_up = |occupied_rgt[xsize:2];  // upper right pixels are blocked
   assign blk_rgt_dn = |occupied_rgt[xsize-1:1];  // lower right pixels are blocked

   assign blk_up_lft = |occupied_top[ysize:2];  // left-side top pixels are blocked
   assign blk_up_rgt = |occupied_top[ysize-1:1];  // right-side top pixels are blocked
   assign blk_dn_lft = |occupied_bot[ysize:2];  // left-side bottom pixels are blocked
   assign blk_dn_rgt = |occupied_bot[ysize-1:1];  // right-side bottom pixels are blocked

   assign corner_lft_up = occupied_lft[xsize+1] & ~blk_up_lft & ~blk_lft_up;   // only left top corner is blocked
   assign corner_rgt_up = occupied_lft[xsize+1] & ~blk_up_rgt & ~blk_rgt_up;   // only right top corner is blocked
   assign corner_lft_dn = occupied_lft[0] & ~blk_dn_lft & ~blk_lft_dn;   // only left bottom corner is blocked
   assign corner_rgt_dn = occupied_rgt[0] & ~blk_dn_rgt & ~blk_rgt_dn;   // only right bottom corner is blocked
   
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   xloc <= xloc_start;
	   yloc <= yloc_start;
	   xdir <= xdir_start;
	   ydir <= ydir_start;
	   update_neighbors <= 0;
	   hitstore<=0;
	end else if (pixpulse) begin
	   update_neighbors <= 0; // default
	   if (move) begin
        
        if(hit==1)begin
        hitstore<=1;
        end        
        
	      case ({xdir,ydir})
		2'b00: begin  // heading to the left and up
		   if (blk_lft_up | corner_lft_up) begin
		      xloc <= xloc + 1;
		      xdir <= ~xdir;
		   end else begin
		      xloc <= xloc - 1;
		   end
		   if (blk_up_lft | corner_lft_up) begin
		      yloc <= yloc + 1;
		      ydir <= ~ydir;
		   end else begin
		      yloc <= yloc - 1;
		   end
		end
		2'b01: begin  // heading to the left and down
		   // complete this code
		   if (blk_lft_dn | corner_lft_dn) begin
		      xloc <= xloc + 1;
		      xdir <= ~xdir;
		   end else begin
		      xloc <= xloc - 1;
		   end
		   if (blk_dn_lft | corner_lft_dn) begin
		      yloc <= yloc - 1;
		      ydir <= ~ydir;
		   end else begin
		      yloc <= yloc + 1;
		   end
		end
		2'b10: begin  // heading to the right and up
		   // complete this code
		   if (blk_rgt_up | corner_rgt_up) begin
		      xloc <= xloc - 1;
		      xdir <= ~xdir;
		   end else begin
		      xloc <= xloc + 1;
		   end
		   if (blk_up_rgt | corner_rgt_up) begin
		      yloc <= yloc + 1;
		      ydir <= ~ydir;
		   end else begin
		      yloc <= yloc - 1;
		   end
		end
		2'b11: begin  // heading to the right and down
		   // complete this code
		   if (blk_rgt_dn | corner_rgt_dn) begin
		      xloc <= xloc - 1;
		      xdir <= ~xdir;
		   end else begin
		      xloc <= xloc + 1;
		   end
		   if (blk_dn_rgt | corner_rgt_dn) begin
		      yloc <= yloc - 1;
		      ydir <= ~ydir;
		   end else begin
		      yloc <= yloc + 1;
		   end
		end
	      endcase 

	      update_neighbors <= 1;
	   end 
	end 
     end
   
endmodule // ball
