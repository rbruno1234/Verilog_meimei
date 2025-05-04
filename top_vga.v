
module top_vga(
			   input wire	     clk, // 100 MHz board clock on Nexys A7
			   input wire	     rst, // Active-high reset
			   input right,
			   input left,
			   input up,
			   input down,
			   input shoot,
			   // VGA outputs
			   output wire [3:0] vgaRed,
			   output wire [3:0] vgaGreen,
			   output wire [3:0] vgaBlue,
			   output wire	     hsync,
			   output wire	     vsync
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
   wire [23:0] broken;
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

   ball #(100,30,0,0) u_ball_1 ( 
		  // Outputs
		  .draw_ball		(draw_ball),
		  .xloc			(),
		  .yloc			(),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty & ~draw_ball2 & ~draw_paddle & ~(|draw_block[23:0]) & ~drawbullet),
		  .move			(move));
		  
    bigball #(500,300,0,0) u_ball_2 ( 
		  // Outputs
		  .draw_ball		(draw_ball2),
		  .xloc			(),
		  .yloc			(),
		  // Inputs
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty & ~draw_ball & ~draw_paddle & ~(|draw_block[23:0])& ~drawbullet),
		  .move			(move));

   paddle #(320, 430,0,0) pad(
		  // Outputs
		  .draw_ball		(draw_paddle),
		  .xloc			(paddlex),
		  .yloc			(paddley),
		  // Inputs
		  .press        (press),
		  .clk			(clk),
		  .pixpulse             (pixpulse),
		  .rst			(rst),
		  .hcount		(hcount[9:0]),
		  .vcount		(vcount[9:0]),
		  .empty		(empty & ~draw_ball & ~draw_ball2 ),
		  .move			(move));



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

for(count=0; count<24;count=count+1)
begin
        scorestore=scorestore+broken[count];
end
end
   assign score = scorestore;

   genvar i;
   generate
        for(i=0; i<24; i=i+1)  begin:block
    if (i<12)
    begin 
    block #
    (
        .xloc(30+i*50),
        .yloc(100),
        .xsize_div_2(20),
        .ysize_div_2(10)
     )
     blockinst 
     (
    .clk(clk), // 100 MHz system clock
    .pixpulse(pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst(rst),
    .hcount(hcount), // x-location where we are drawing
    .vcount(vcount), // y-location where we are drawing
    .empty(empty & ~draw_ball & ~draw_ball2 & ~drawbullet), // is this pixel empty
    .move(move), // signal to update the status of the block
    .unbreak(unbreak),  // reset the block
    .draw_block(draw_block[i]), // is the block being drawn here?
    .broken(broken[i]) // is this block broken 
     );
     end
     else begin
         block #
    (
        .xloc(30+(i-12)*50),
        .yloc(130),
        .xsize_div_2(20),
        .ysize_div_2(10)
     )
     blockinst 
     (
    .clk(clk), // 100 MHz system clock
    .pixpulse(pixpulse), // every 4 clocks for 25MHz pixel rate
    .rst(rst),
    .hcount(hcount), // x-location where we are drawing
    .vcount(vcount), // y-location where we are drawing
    .empty(empty & ~draw_ball & ~draw_ball2 & ~drawbullet), // is this pixel empty
    .move(move), // signal to update the status of the block
    .unbreak(unbreak),  // reset the block
    .draw_block(draw_block[i]), // is the block being drawn here?
    .broken(broken[i]) // is this block broken 
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
        
   assign unbreak = broken[23:0] == 24'hffffff ? 1 : 0;

   assign is_a_wall = (((hcount < 5) | (hcount > 625) | (vcount < 5) | (vcount > 475))||((hcount < 115+150*LFSRhold) && (hcount > 110+150*LFSRhold) && (vcount < 450) && (vcount > 150)));
   
   assign press={down, up, left, right};

   assign empty = ~is_a_wall;

   assign move = (vblank & ~vblank_d1);  // move balls at start of vertical blanking

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
   
