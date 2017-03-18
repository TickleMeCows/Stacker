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
	/*vga_adapter VGA(
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
			*/
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    wire a,b, aout;
	 wire drawsquare;
    // Instansiate datapath
	// datapath d0(...);
	datapath d0(.Colour(SW[9:7]),.ResetN(KEY[0]),.in(SW[6:0]),.ldaluout(aout),.OutX(x),.OutY(y),.OutC(colour),.clk(CLOCK_50),.ctrlA(a),.enable(KEY[1]));
    // Instansiate FSM control
	control c0(.go(KEY[3]),. ResetN(KEY[0]),. ControlA(a),. ControlB(b),.clk(CLOCK_50),.enable(KEY[1]),.ldaluout(aout));
    // control c0(...);
    
endmodule

module datapath(Colour, ResetN, in, OutX, OutY, OutC,clk, ldaluout,ctrlA, enable);
	input ResetN, clk, ctrlA, enable, ldaluout;
	input [2:0] Colour;
	input [6:0] in;
	output reg [7:0] OutX;
	output reg [6:0] OutY;
	output reg [2:0] OutC;
	reg [8:0] ox;
	reg [7:0] oy;
	reg [2:0] oc;
	reg [8:0] oxout;
	reg [7:0] oyout;
	reg [2:0]counterx,countery;
	
	always @(posedge clk)
	 begin : ALU
		if (enable == 1'b0 && countery != 3'b101) begin // when we press key[1]
			if (counterx < 3'b100) // increment x
				begin
					oxout = oxout + 1'b1;
					counterx = counterx + 1'b1;
				end
			else if (counterx == 3'b100)
				begin
					oxout = oxout - 1'b1;
					oyout = oyout + 1'b1;
					countery = countery + 1'b1;
					counterx = counterx + 1'b1;
				end
			else if (counterx < 4'b1000)
				begin
					oxout = oxout - 1'b1;
					counterx = counterx + 1'b1;
				end
			else if (counterx == 4'b1001)
				begin
					counterx = 0;
					oyout = oyout + 1'b1;
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
				counterx <= 0;
				countery <= 0;
				oxout <= 0;
				oyout <= 0;
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
        else;
				begin
						OutX <= ox + oxout;
						OutY <= oy + oyout;
						OutC <= oc;
				end
    end
	 
	 
endmodule

module control(go, ResetN, ControlA, ControlB, clk,enable, enable2,ldaluout);
	output reg enable2;
	output reg ldaluout;
	reg [3:0] current_state, next_state;
	input go, clk, ResetN, enable;
	output reg ControlA, ControlB;
	always@(posedge clk)
   begin: state_FFs
       if(!ResetN)
           current_state <= 2'b00;
       else
           current_state <= next_state;
   end // state_FFS
	
	always@(*)
	begin: state_table
		ldaluout = 0;
		ControlA = 1'b0;
		ControlB = 1'b0;
		enable2 = 1'b0;
		case(current_state)
			3'b000: next_state = go ? 3'b000: 3'b001; // Load X until
			3'b001: next_state = go ? 3'b010: 3'b001; // Load X until 
			3'b010: next_state = enable ? 3'b010: 3'b011; // Increment X hold it's value until we press key[1]
			3'b011: next_state = enable ? 3'b011: 3'b010; // Increment Y hold it's value until we press key[1]
		endcase
		
		case(current_state)
			3'b000: begin ControlA = 1'b0; ldaluout = 1;end
			3'b010: begin ControlA = 1'b1; enable2 = 1; ldaluout = 0;end
			3'b011: begin ControlA = 1'b0; enable2 = 1; ldaluout = 0;end
		endcase
	end
endmodule 