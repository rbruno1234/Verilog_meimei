module score #(parameter xloc=40,
              parameter yloc=40)
   (
    input       clk, // 100 MHz system clock
    input       pixpulse, // every 4 clocks for 25MHz pixel rate
    input       rst,
    input [9:0] hcount, // x-location where we are drawing
    input [9:0] vcount, // y-location where we are drawing
    input [1:0] score,  // 0 = GAM, 1 = OVE
    output      draw_score 
    );

   reg [2:0]   row;
   reg [3:0]   digit;
   
   (*rom_style = "block" *) reg [7:0] chr_pix;
   
   always @(posedge clk)
     begin
        case ({~score[0], digit, row})  // MSB selects between GAM and OVE
            // GAM patterns (when score[0] = 0)
            // G
            8'h00: chr_pix <= 8'b00111100;
            8'h01: chr_pix <= 8'b01000010;
            8'h02: chr_pix <= 8'b01000000;
            8'h03: chr_pix <= 8'b01001110;
            8'h04: chr_pix <= 8'b01000010;
            8'h05: chr_pix <= 8'b01000010;
            8'h06: chr_pix <= 8'b00111100;
            8'h07: chr_pix <= 8'b00000000;
            
            // A
            8'h08: chr_pix <= 8'b00011000;
            8'h09: chr_pix <= 8'b00100100;
            8'h0A: chr_pix <= 8'b01000010;
            8'h0B: chr_pix <= 8'b01111110;
            8'h0C: chr_pix <= 8'b01000010;
            8'h0D: chr_pix <= 8'b01000010;
            8'h0E: chr_pix <= 8'b01000010;
            8'h0F: chr_pix <= 8'b00000000;
            
            // M
            8'h10: chr_pix <= 8'b01000010;
            8'h11: chr_pix <= 8'b01100110;
            8'h12: chr_pix <= 8'b01011010;
            8'h13: chr_pix <= 8'b01000010;
            8'h14: chr_pix <= 8'b01000010;
            8'h15: chr_pix <= 8'b01000010;
            8'h16: chr_pix <= 8'b01000010;
            8'h17: chr_pix <= 8'b00000000;
            
            // OVE patterns (when score[0] = 1)
            // O
            8'h80: chr_pix <= 8'b00111100;
            8'h81: chr_pix <= 8'b01000010;
            8'h82: chr_pix <= 8'b01000010;
            8'h83: chr_pix <= 8'b01000010;
            8'h84: chr_pix <= 8'b01000010;
            8'h85: chr_pix <= 8'b01000010;
            8'h86: chr_pix <= 8'b00111100;
            8'h87: chr_pix <= 8'b00000000;
            
            // V
            8'h88: chr_pix <= 8'b01000010;
            8'h89: chr_pix <= 8'b01000010;
            8'h8A: chr_pix <= 8'b01000010;
            8'h8B: chr_pix <= 8'b01000010;
            8'h8C: chr_pix <= 8'b00100100;
            8'h8D: chr_pix <= 8'b00100100;
            8'h8E: chr_pix <= 8'b00011000;
            8'h8F: chr_pix <= 8'b00000000;
            
            // E
            8'h90: chr_pix <= 8'b01111110;
            8'h91: chr_pix <= 8'b01000000;
            8'h92: chr_pix <= 8'b01000000;
            8'h93: chr_pix <= 8'b01111100;
            8'h94: chr_pix <= 8'b01000000;
            8'h95: chr_pix <= 8'b01000000;
            8'h96: chr_pix <= 8'b01111110;
            8'h97: chr_pix <= 8'b00000000;
            
            default: chr_pix <= 8'b00000000;
        endcase
     end
     
   // Determine which character to display based on hcount position
   wire [3:0] current_char;
   assign current_char = (hcount >= xloc && hcount < xloc+8) ? 4'h0 :    // First character
                        (hcount >= xloc+8 && hcount < xloc+16) ? 4'h1 :  // Second character
                        (hcount >= xloc+16 && hcount < xloc+24) ? 4'h2 : // Third character
                        4'h0; // Default
   
   assign draw_score = (vcount >= yloc-7 && vcount <= yloc) && 
                      (hcount >= xloc && hcount < xloc+24) && 
                      chr_pix[7 - (hcount - xloc) % 8];
   
   // Update row and digit
   always @(posedge clk or posedge rst)
     begin
        if (rst) begin
           digit <= 0;
           row <= 0;
        end else if (pixpulse) begin
           if (vcount >= yloc-7 && vcount <= yloc) begin
              row <= 7 - (yloc - vcount);
              digit <= current_char;
           end
        end
     end
   
endmodule
