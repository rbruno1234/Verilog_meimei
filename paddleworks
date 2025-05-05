`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2025 06:10:50 PM
// Design Name: 
// Module Name: paddle
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

module paddle #(parameter xloc_start=320,
	      parameter yloc_start=240,
	      parameter xdir_start=0,
	      parameter ydir_start=0)
   (
    input [4:0]  press,
    input	     clk, // 100 MHz system clock
    input	     pixpulse, // every 4 clocks for 25MHz pixel rate
    input	     rst,
    input [9:0]	     hcount, // x-location where we are drawing
    input [9:0]	     vcount, // y-location where we are drawing
    input	     empty, // is this pixel empty
    input	     move, // signal to update the location of the ball
    output	     draw_ball, // is the ball being drawn here?
    output reg [9:0] xloc, // x-location of the ball
    output reg [9:0] yloc // y-location of the ball
    );

   reg [6:0]			 occupied_lft;
   reg [6:0]			 occupied_rgt;
   reg [16:0]			 occupied_bot;
   reg [16:0]			 occupied_top;
   reg				 xdir, ydir;
   reg				 update_neighbors;

   wire				 blk_lft_up, blk_lft_dn, blk_rgt_up, blk_rgt_dn;
   wire				 blk_up_lft, blk_up_rgt, blk_dn_lft, blk_dn_rgt;
   wire				 corner_lft_up, corner_rgt_up, corner_lft_dn, corner_rgt_dn;
   
   // are we pointing at a pixel in the ball?
   // this will make a square ball...
   assign draw_ball = (hcount <= xloc+7) & (hcount >= xloc-7) & (vcount <= yloc+2) & (vcount >= yloc-2) ?  1 : 0;

   // hcount goes from 0=left to 640=right
   // vcount goes from 0=top to 480=bottom
   
   // keep track of the neighboring pixels to detect a collision
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   occupied_lft <= 7'b0;
	   occupied_rgt <= 7'b0;
	   occupied_bot <= 17'b0;
	   occupied_top <= 17'b0;
	end else if (pixpulse) begin  // only make changes when pixpulse is high
	   if (update_neighbors) begin
	      occupied_lft <= 7'b0;
	      occupied_rgt <= 7'b0;
	      occupied_bot <= 17'b0;
	      occupied_top <= 17'b0;
	   end else if (~empty) begin
	      if (vcount >= yloc-3 && vcount <= yloc+3) 
		if (hcount == xloc+8)
		  occupied_rgt[(yloc-vcount+3)] <= 1'b1;  // LSB is at bottom
		else if (hcount == xloc-8)
		  occupied_lft[(yloc-vcount+3)] <= 1'b1;
	      
	      if (hcount >= xloc-8 && hcount <= xloc+8) 
		if (vcount == yloc+3)
		  occupied_bot[(xloc-hcount+8)] <= 1'b1;  // LSB is at right
		else if (vcount == yloc-3)
		  occupied_top[(xloc-hcount+8)] <= 1'b1;
	   end
	end
     end	      


   assign blk_lft_up = |occupied_lft[5:2];  // upper left pixels are blocked
   assign blk_lft_dn = |occupied_lft[4:1];  // lower left pixels are blocked
   assign blk_rgt_up = |occupied_rgt[5:2];  // upper right pixels are blocked
   assign blk_rgt_dn = |occupied_rgt[4:1];  // lower right pixels are blocked

   assign blk_up_lft = |occupied_top[15:2];  // left-side top pixels are blocked
   assign blk_up_rgt = |occupied_top[14:1];  // right-side top pixels are blocked
   assign blk_dn_lft = |occupied_bot[15:2];  // left-side bottom pixels are blocked
   assign blk_dn_rgt = |occupied_bot[14:1];  // right-side bottom pixels are blocked

   assign corner_lft_up = occupied_lft[6] & ~blk_up_lft & ~blk_lft_up;   // only left top corner is blocked
   assign corner_rgt_up = occupied_rgt[6] & ~blk_up_rgt & ~blk_rgt_up;   // only right top corner is blocked
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
	end else if (pixpulse) begin
	   update_neighbors <= 0; // default
	   if (move) begin

	      case ({press})
		4'b0001: begin  // heading to the left and up
		  if (~occupied_rgt)begin
		      xloc <= xloc + 1;
		      end
		   end
		4'b0010: begin  // heading to the left and down
		   // complete this code
		   if (~occupied_lft)begin
		      xloc <= xloc - 1;
		      end
		end
		4'b0100: begin  // heading to the right and up
		   // complete this code
		   if (~occupied_top)begin
		      yloc <= yloc - 1;
		      end
		end
		4'b1000: begin  // heading to the right and down
		   // complete this code
		   if (~occupied_bot)begin
		      yloc <= yloc + 1;
		      end
		end
	      endcase 

	      update_neighbors <= 1;
	   end 
	end 
     end
   
endmodule // ball

