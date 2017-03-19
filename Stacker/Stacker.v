// Part 2 skeleton
include "vga_adapter/vga_adapter.v";
include "vga_adapter/vga_address_translator.v";
include "vga_adapter/vga_controller.v";
include "vga_adapter/vga_pll.v";

module part2
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input CLOCK_50;				//	50 MHz
	input[9:0]SW;
	input[3:0]KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
   
	
	
	
	wire [8:0] xconnect,yconnect;
	wire [9:0] levels;
	control c0(.go(KEY[3]),. ResetN(KEY[0]),.clk(CLOCK_50),.enable(KEY[1]),.ldaluout(aout),.x(xconnect),.y(yconnect));
	
	datapath l1(,.Colour(colour) ,.ResetN(KEY[0]),. in_y(yconnect),. in(xconnect),. OutX(x),. OutY(y),. clk,. ldaluout(auot),. enable(),. blockenabled(level[0]));
	
	
    
endmodule


	
/*
	This will make the blocks based

*/
module datapath(Colour, ResetN, in_y,in, OutX, OutY, OutC,clk, ldaluout, enable, blockenabled);
	input ResetN, clk, ctrlA, enable, ldaluout;
	input [2:0] Colour;
	input [6:0] in;
	input in_y;
	input blockenabled
	output reg [7:0] OutX;
	output reg [6:0] OutY;
	output reg [2:0] OutC;
	reg [8:0] ox;
	reg [7:0] oy;
	reg [2:0] oc;
	reg [8:0] oxout;
	reg [7:0] oyout;
	reg [6:0]counterx,countery;
	// Draw the 48x48 square

	always @(posedge clk)
	begin : ALU
		if (!ResetN || blockenabled = 1'b0)
			oxout <= 0;
			oyout <= 0;
			counterx <= 0;
			countery <= 0;
			
		if (enable == 1'b0 && (counterx != 7'd48 || countery != 7'd48))
			begin
				if (counterx < 7'd48)
					begin
						oxout = oxout + 1'b1;
						counterx = counterx + 1'b1;
					end
				if (counterx == 7'd48)
					begin
						oxout = 0;
						counterx = 0;
						countery = countery + 1'b1;
					end
			end
	end
				
	always @(posedge clk)
	begin
		if (!ResetN)
			begin
				ox <= 8'd0;
				oy <= 7'd0;
				oc <= 0;

			end
		else
			begin
				ox <= ldaluout ? {1'b0,in} : ox;
				oy <= enable ? in : oy;
				oc <= Colour;
			end
	end
	// Output result register
	always @ (posedge clk) begin
		if (!ResetN)
			begin
				OutX <= 0;
				OutY <= 0;
				OutC <= 0;
		end
		else
			begin
				OutX <= ox + oxout;
				OutY <= oy + oyout;
				OutC <= oc;
			end
	end
	 
endmodule

/*
	Instructs where to draw the blocks
	
*/

module blockmovement(clk,out_enable, out_y, out_x, colour,reset);
	output reg out_y;
	output reg out_x;
	reg x;
	if (!reset)
	
	
	
endmodule

module control(go, ResetN, clk,enable, enable2,ldaluout, stopbutton, levelen,x,y);
	output reg [8:0] x,y;
	output reg enable2;
	output reg ldaluout;
	output reg [9:0] levelen;
	reg [4:0] current_state, next_state;
	input go, clk, ResetN, enable;
	always@(posedge clk)
   begin: state_FFs
       if(!ResetN)
           current_state <= 2'b00;
       else
           current_state <= next_state;
   end // state_FFS
	localparam LEVEL_1 = 5'd0, LEVEL_1_MOVE = 5'd1,
				  LEVEL_2 = 5'd3, LEVEL_2_MOVE = 5'd4,
				  LEVEL_3 = 5'd5, LEVEL_3_MOVE = 5'd6;
				  LEVEL_4 = 5'd7, LEVEL_4_MOVE = 5'd8;
				  LEVEL_5 = 5'd9, LEVEL_5_MOVE = 5'd10,
				  LEVEL_6 = 5'd11, LEVEL_6_MOVE = 5'd12,
				  LEVEL_7 = 5'd13, LEVEL_7_MOVE = 5'd14, 
				  LEVEL_8 = 5'd15, LEVEL_8_MOVE = 5'd16,
				  LEVEL_9 = 5'd17, LEVEL_9_MOVE = 5'd18,
				  LEVEL_10 = 5'd19, LEVEL_10_MOVE = 5'd20;

	reg anchor;
	reg location;
	
	reg [5:0]counter;
	reg direction;
	reg anchor;
	always @(posedge clk) // Store result in one array
	begin
		if (!ResetN)
			counter <= 0;
			direction <= 0;
			anchor <= 0;
		if (stopbutton == 1'b1) // keeping looping until we press the buttan
			if (direction == 0) // right
				counter = counter + 1'b1;
			else if (direction == 1)
				counter == counter - 1'b1;//
			if (counter == 0 || counter == 5'd16) // end
				direction = ~direction	// change directions
		else
			anchor <= counter; // Anchor the value here
	end
	always @(*)
	begin
		if (!ResetN)
			levelen <= 0;
		case(current_state)
			LEVEL_1: begin 
							//clock speed
							y = 9'd480;
							x = 0;
							levelen[0] <= 1'b1;
						end
			LEVEL_1_MOVE: if begin end	// 
			LEVEL_2: begin 
							// clock speed
							y = 9'd432;
							x = 0;
							levelen[1] <= 1'b1;
						end
			LEVEL_2_MOVE: if begin end
			LEVEL_3: if begin 
							// clock speed
							y = 9'd384;
							x = 0;
							levelen[2] <= 1'b1;
							end
			LEVEL_3_MOVE: if begin end
			LEVEL_4: if begin 
							// clock speed
							y = 9'd336;
							x = 0;
							levelen[3] <= 1'b1;
							end
			LEVEL_4_MOVE: if begin end
			LEVEL_5: if begin 
							// clock speed
							y = 9'd288;
							x = 0;
							levelen[4] <= 1'b1;
							end
			LEVEL_5_MOVE: if begin end
			LEVEL_6: if begin 
							// clock speed
							y = 9'd240;
							x = 0;
							levelen[5] <= 1'b1;
							end
			LEVEL_6_MOVE: if begin end
			LEVEL_7: if begin 
							// clock speed
							y = 9'd192;
							x = 0;
							levelen[6] <= 1'b1;
							end
			LEVEL_7_MOVE: if begin end
			LEVEL_8:  if begin 
								// clock speed
								y = 9'd144;
								x = 0;
								levelen[7] <= 1'b1;
							 end
			LEVEL_8_MOVE: if begin end
			LEVEL_9: if begin
								// clock speed
								y = 9'd96;
								x = 0;
								levelen[8] <= 1'b1;
							end
			LEVEL_9_MOVE: if begin end
			LEVEL_10: if begin 
								//clock speed
								y = 9'd48;
								x = 0;
								levelen[9] <= 1'b1;
							end
			LEVEL_10_MOVE: if begin end
		endcase
	end
	
	always@(*)
	begin: state_table
		ldaluout = 0;
		ControlA = 1'b0;
		ControlB = 1'b0;
		enable2 = 1'b0;
		case(current_state)
			LEVEL_1: next_state = stopbutton ? LEVEL_1 : LEVEL_1_MOVE; // stay on level 1 until they press a button
			LEVEL_1_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_2; // Level 1 move is responsible for setting the inital values the block can be at we will keep those for all iterations
			LEVEL_2: next_state = stopbutton ? LEVEL_2 : LEVEL_2_MOVE; // 
			LEVEL_2_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_3; // if the anchor does not equal the counter they missed
			LEVEL_3: next_state = stopbutton ? LEVEL_3 : LEVEL_3_MOVE; // 
			LEVEL_3_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_4; // 
			LEVEL_4: next_state = stopbutton ? LEVEL_4 : LEVEL_4_MOVE; // 
			LEVEL_4_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_5; // 
			LEVEL_5: next_state = stopbutton ? LEVEL_5 : LEVEL_5_MOVE; // 
			LEVEL_5_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_6; // 
			LEVEL_6: next_state = stopbutton ? LEVEL_6 : LEVEL_6_MOVE; // 
			LEVEL_6_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_7; // 
			LEVEL_7: next_state = stopbutton ? LEVEL_7 : LEVEL_7_MOVE; // 
			LEVEL_7_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_8; // 
			LEVEL_8: next_state = stopbutton ? LEVEL_8 : LEVEL_8_MOVE; // 
			LEVEL_8_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_9; //
			LEVEL_9: next_state = stopbutton ? LEVEL_9 : LEVEL_9_MOVE; // 
			LEVEL_9_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_10; //
			LEVEL_10: next_state = stopbutton ? LEVEL_10 : LEVEL_10_MOVE; // 
			LEVEL_10_MOVE: next_state = (anchor == counter) ? LEVEL_1 : LEVEL_10; // 
		endcase
	end
endmodule 