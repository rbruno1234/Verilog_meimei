

// 3 digit score module, 8x8 pixel digits

module score #(parameter xloc=40,
	      parameter yloc=40)
   (
    input	clk, // 100 MHz system clock
    input	pixpulse, // every 4 clocks for 25MHz pixel rate
    input	rst,
    input [9:0]	hcount, // x-location where we are drawing
    input [9:0]	vcount, // y-location where we are drawing
    input [7:0]	score,
    output	draw_score 
    );

   reg [2:0]	row;
   reg [3:0]	digit;
   wire [11:0]	score_bcd;
   
   (*rom_style = "block" *) reg [7:0] chr_pix;
   
   always @(posedge clk)
     begin
	case ({1'b0,digit,row})  // each digit is 8 rows, 8 bits each row
	  8'h00: chr_pix <= 8'b00000000;
	  8'h01: chr_pix <= 8'b00111100;
	  8'h02: chr_pix <= 8'b01000010;
	  8'h03: chr_pix <= 8'b01000010;
	  8'h04: chr_pix <= 8'b01000010;
	  8'h05: chr_pix <= 8'b01000010;
	  8'h06: chr_pix <= 8'b01000010;
	  8'h07: chr_pix <= 8'b00111100;
	  //1
	  8'h08: chr_pix <= 8'b00000000;
	  8'h09: chr_pix <= 8'b00110000;
	  8'h0a: chr_pix <= 8'b01010000;
	  8'h0b: chr_pix <= 8'b00010000;
	  8'h0c: chr_pix <= 8'b00010000;
	  8'h0d: chr_pix <= 8'b00010000;
	  8'h0e: chr_pix <= 8'b00010000;
	  8'h0f: chr_pix <= 8'b01111100;
	  //2
	  8'h10: chr_pix <= 8'b00000000;
	  8'h11: chr_pix <= 8'b00011000;
	  8'h12: chr_pix <= 8'b00100100;
	  8'h13: chr_pix <= 8'b01000010;
	  8'h14: chr_pix <= 8'b10000010;
	  8'h15: chr_pix <= 8'b00000100;
	  8'h16: chr_pix <= 8'b00001000;
	  8'h17: chr_pix <= 8'b01111100;
	  //3
	  8'h18: chr_pix <= 8'b00000000;
	  8'h19: chr_pix <= 8'b00111000;
	  8'h1a: chr_pix <= 8'b01000100;
	  8'h1b: chr_pix <= 8'b00000100;
	  8'h1c: chr_pix <= 8'b00011000;
	  8'h1d: chr_pix <= 8'b00001000;
	  8'h1e: chr_pix <= 8'b00000100;
	  8'h1f: chr_pix <= 8'b00111000;
	  //4
	  8'h20: chr_pix <= 8'b00000000;
	  8'h21: chr_pix <= 8'b00100100;
	  8'h22: chr_pix <= 8'b00100100;
	  8'h23: chr_pix <= 8'b00111100;
	  8'h24: chr_pix <= 8'b00000100;
	  8'h25: chr_pix <= 8'b00000100;
	  8'h26: chr_pix <= 8'b00000100;
	  8'h27: chr_pix <= 8'b00000100;
	  //5
	  8'h28: chr_pix <= 8'b00000000;
	  8'h29: chr_pix <= 8'b01111110;
	  8'h2a: chr_pix <= 8'b01000000;
	  8'h2b: chr_pix <= 8'b01000000;
	  8'h2c: chr_pix <= 8'b01011100;
	  8'h2d: chr_pix <= 8'b01100010;
	  8'h2e: chr_pix <= 8'b00000010;
	  8'h2f: chr_pix <= 8'b00011100;
	  //6
	  8'h30: chr_pix <= 8'b00001000;
	  8'h31: chr_pix <= 8'b00010000;
	  8'h32: chr_pix <= 8'b00100000;
	  8'h33: chr_pix <= 8'b00111000;
	  8'h34: chr_pix <= 8'b00100100;
	  8'h35: chr_pix <= 8'b00100100;
	  8'h36: chr_pix <= 8'b00100100;
	  8'h37: chr_pix <= 8'b00011000;
	  //7
	  8'h38: chr_pix <= 8'b00000000;
	  8'h39: chr_pix <= 8'b00000000;
	  8'h3a: chr_pix <= 8'b01111110;
	  8'h3b: chr_pix <= 8'b01000010;
	  8'h3c: chr_pix <= 8'b00000010;
	  8'h3d: chr_pix <= 8'b00000010;
	  8'h3e: chr_pix <= 8'b00000010;
	  8'h3f: chr_pix <= 8'b00000010;
	  //8
	  8'h40: chr_pix <= 8'b00000000;
	  8'h41: chr_pix <= 8'b00011000;
	  8'h42: chr_pix <= 8'b00100100;
	  8'h43: chr_pix <= 8'b00100100;
	  8'h44: chr_pix <= 8'b00011000;
	  8'h45: chr_pix <= 8'b00100100;
	  8'h46: chr_pix <= 8'b00100100;
	  8'h47: chr_pix <= 8'b00011000;	
	  //9
	  8'h48: chr_pix <= 8'b00000000;
	  8'h49: chr_pix <= 8'b00000000;
	  8'h4a: chr_pix <= 8'b00111110;
	  8'h4b: chr_pix <= 8'b01000010;
	  8'h4c: chr_pix <= 8'b00111110;
	  8'h4d: chr_pix <= 8'b00000010;
	  8'h4e: chr_pix <= 8'b00000010;
	  8'h4f: chr_pix <= 8'b00000010;  
	  // fill in the values for the rest of the numbers
	  
	endcase // case ({digit,row})
     end
	  
 
   assign draw_score_100 = (vcount >= yloc-7 && vcount <= yloc && hcount < xloc+8 && hcount>=xloc) ? chr_pix[7-(hcount-xloc)]:0;  // when we are in the 100's digit region, use chr_pix[?] to draw the pixels
   
   assign draw_score_10 =(vcount >= yloc-7 && vcount <= yloc && hcount < xloc+16 && hcount>=xloc+8) ? chr_pix[7-(hcount-(xloc+8))]:0; // when we are in the 10's digit region, use chr_pix[?] to draw the pixels
		       
   assign draw_score_1 = (vcount >= yloc-7 && vcount <= yloc && hcount < xloc+24 && hcount>=xloc+16) ? chr_pix[7-(hcount-(xloc+16))]:0; // when we are in the 1's digit region, use chr_pix[?] to draw the pixels

   assign draw_score = draw_score_100 | draw_score_10 | draw_score_1;  // draw all of the score pixels

   doubdab_8bits udd (.b_in (score), .bcd_out (score_bcd));

   // hcount goes from 0=left to 640=right
   // vcount goes from 0=top to 480=bottom
   always @(posedge clk or posedge rst)
     begin
	if (rst) begin
	   digit <= 0;
	   row <= 0;
	end else if (pixpulse) begin  // only make changes when pixpulse is high
	      if (vcount >= yloc-7 && vcount <= yloc) begin
	      // update row and digit as we scan through the region that has the score
		 row <= 7 - (yloc - vcount); 
		 if (hcount == xloc)
		   digit <= score_bcd[11:8]; // when we reach xloc, set the digit to the 100's place
		 else if (hcount == xloc + 8)
		   digit <= score_bcd[7:4]; // when we reach xloc+8, set the digit to the 10's place
		 else if (hcount == xloc + 16)
		   digit <= score_bcd[3:0]; // when we reach xloc+16, set the digit to the 1's place
	      end
	end
     end	      
   
endmodule // score
