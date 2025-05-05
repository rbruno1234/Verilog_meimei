
module top_vga(
			   input wire	     clk, // 100 MHz board clock on Nexys A7
			   input wire	     rst, // Active-high reset
			   input right,
			   input left,
			   input up,
			   input down,
			   input shoot,
			   input start,
			   // VGA outputs
			   output wire [3:0] vgaRed,
			   output wire [3:0] vgaGreen,
			   output wire [3:0] vgaBlue,
			   output wire	     hsync,
			   output wire	     vsync,
			   output reg       death
			   );
   wire [3:0] press;
   wire [9:0] hcount;
   wire [9:0] vcount;
   wire	      hblank;
   wire	      vblank;
   wire	      pixpulse;
   wire	      is_a_wall, empty, draw_ball;
   wire	      draw_ball2, draw_paddle,draw_score;
   wire [23:0] draw_block;
   wire	      move;
   reg [11:0] current_pixel;
   reg vblank_d1;
   wire unbreak;
   wire [16:0] broken;
   wire [7:0] score;
    

   localparam WALL_COLOR = 12'h00f;
   localparam BALL_COLOR = 12'h0f0;
   localparam EMPTY_COLOR = 12'hfff;
   localparam P_COLOR = 12'hf0f;
   

wire [1:0] data;
reg [1:0] LFSRhold;



LFSR3 temp (
    .clk(clk),
    .o_data(data)
    );
    
    always@(posedge clk)begin
        if(rst==1)begin
            LFSRhold <= data;
        end
    end

  
  //assign score = 8'h0f;

   //---------------------------------------------
   // VGA Timing Generator
   //---------------------------------------------
   vga_timing vga_gen (
		       .clk    (clk),
		       .pixpulse (pixpulse),
		       .rst    (rst),  //active high
		       .hcount (hcount[9:0]),
		       .vcount (vcount[9:0]),
		       .hsync  (hsync),
		       .vsync  (vsync),
		       .hblank (hblank),
		       .vblank (vblank)
		       );
wire drawbullet;
wire [9:0] paddlex,paddley;
wire  bullbroke;

//assign unbullet=bullbroke == 1 ? 1:0;

reg fuckoff=0;
   paddle #(280, 430,0,0) pad(
		  // Outputs
		  .draw_ball		(draw_paddle),
		  .xloc			(paddlex),
		  .yloc			(paddley),
		  .broken       (broken[16]),
		  // Inputs
		  .press        (press),
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty &~(|draw_block[23:0])),
		  .move			(move));


always@(posedge clk)    begin
death<=0;

    if(broken[16]==1||scorestore==3)       begin
        fuckoff<=1;
    end
    
    if(fuckoff==1)          begin
    death<=1;
    end
    
    if(~start)              begin
    fuckoff<=0;
    end
end




   bull #(5,5,0)
   (
    .clk			(clk),
	.pixpulse             (pixpulse),
	.rst            (rst),
	.shoot			(shoot),
    .hcount		(hcount[9:0]),
	.vcount		(vcount[9:0]),
    .xloc_start(paddlex),
    .yloc_start(paddley),
    .empty(empty & ~(|draw_block[23:0])), // is this pixel empty
    .move(move), // signal to update the location of the ball
    .draw_ball(drawbullet), // is the ball being drawn here?
    .xloc(), // x-location of the ball
    .yloc(), // y-location of the ball
    .broken(bullbroke)
    );

reg [5:0] scorestore;
reg [5:0] count;
always @(*) begin
scorestore=0;

for(count=0; count<16;count=count+1)
begin
        scorestore=scorestore+broken[count];
end
end
   assign score = scorestore;
   
wire [2:0] emptyinput;
assign emptyinput={empty, ~(|draw_block[23:0]), ~drawbullet};

   genvar i;
   generate
        for(i=0; i<12; i=i+1)  begin:gen
    if (i<6)
    begin 
    ene #(
        .xsize(21),
        .ysize(21)
     )
     geninst 
     (
    .clk(clk), // 100 MHz system clock
    .pixpulse(pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst(rst),
    .hcount(hcount), // x-location where we are drawing
    .vcount(vcount), // y-location where we are drawing
    .xloc_start(30+i*50),
    .yloc_start(100),
    .empty(emptyinput), // is this pixel empty ||||| empty & ~(|draw_block[23:0]) & ~drawbullet
    .move(move), // signal to update the status of the block
    .xdir_start(LFSRhold[0]),
    .ydir_start(LFSRhold[1]),
    .draw_ene(draw_block[i]), // is the block being drawn here?
    .xloc(),
    .yloc(),
    .broken(broken[i])
     );
     end
     else
     ene #(
        .xsize(21),
        .ysize(21)
     )
     geninst 
     (
    .clk(clk), // 100 MHz system clock
    .pixpulse(pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst(rst),
    .hcount(hcount), // x-location where we are drawing
    .vcount(vcount), // y-location where we are drawing
    .xloc_start(30+i*50),
    .yloc_start(50),
    .empty(emptyinput), // is this pixel empty
    .move(move), // signal to update the status of the block
    .xdir_start(LFSRhold[1]),
    .ydir_start(LFSRhold[0]),
    .draw_ene(draw_block[i]), // is the block being drawn here?
    .xloc(),
    .yloc(),
    .broken(broken[i])
     );

     end
   endgenerate      
   
 genvar j;
 generate
      for(j=13; j<16; j=j+1)  begin:genp
    begin   
      enep #(11,11)
     enepinst
     (
    .clk(clk), // 100 MHz system clock
    .pixpulse(pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst(rst),
    .hcount(hcount), // x-location where we are drawing
    .vcount(vcount), // y-location where we are drawing
    .xloc_start(50+(j-12)*150),
    .yloc_start(250),
    .xdir_start(0),
    .empty(emptyinput), // is this pixel empty
    .move(move), // signal to update the status of the block
    .draw_enep(draw_block[j]), // is the block being drawn here?
    .xloc(),
    .yloc(),
    .broken(broken[j])
    );
    end
  end
endgenerate
  
   score 
   #(40, 40) 
   score_inst
   (   
   .clk(clk),
   .pixpulse(pixpulse),
   .rst(rst),
   .vcount(vcount),
   .hcount(hcount),
   .score(score),
   .draw_score(draw_score)
   );     
        
   //assign unbreak = broken[23:0] == 24'hffffff ? 1 : 0;

   assign is_a_wall = (((hcount < 5) | (hcount > 625) | (vcount < 5) | (vcount > 475))||((hcount < 115+50*LFSRhold) && (hcount > 110+50*LFSRhold) && (vcount < 450) && (vcount > 150))||((hcount < 325+50*LFSRhold) && (hcount > 320+50*LFSRhold) && (vcount < 450) && (vcount > 150)));
   
   assign press={down, up, left, right};

   assign empty = ~is_a_wall;

   assign move = (vblank & ~vblank_d1)&start&~fuckoff;  // move balls at start of vertical blanking

   always @(posedge clk or posedge rst) begin
      if (rst) begin
	 vblank_d1 <= 0;
      end else if (pixpulse) begin
         vblank_d1 <= vblank;
      end
   end

   // Register the current pixel
   always @(posedge clk) begin
      if (pixpulse)
        current_pixel <= (is_a_wall) ? WALL_COLOR : ( (draw_ball | draw_ball2 | draw_paddle| draw_block) ? BALL_COLOR : (( draw_score|drawbullet )? P_COLOR : EMPTY_COLOR ));
   end

   // Map 12-bit to 4:4:4
   assign vgaRed   = (~hblank && ~vblank) ? current_pixel[11:8] : 4'b0;
   assign vgaGreen = (~hblank && ~vblank) ? current_pixel[7:4] : 4'b0;
   assign vgaBlue  = (~hblank && ~vblank) ? current_pixel[3:0] : 4'b0;
   
endmodule
   
