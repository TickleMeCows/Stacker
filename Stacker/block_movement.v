module block_movement(clk, enable, out_y, out_x, colour);

endmodule

//block is 48x48  
//at every clock pulse, we move the block over 48 pixels
//until it hits  640, then start subtracting until it hits 0, rince and repeat.


module control(clk, out_x, add_x ):

input clk;
input [9:0] out_x;
output [9:0] add_x;

reg current_state, next_state, x_state;
assign x_state = (x == 10'b1001000110) ? 1'b1 : 1'b0;

localparam  adding = 1'b0,
			subtracting = 1'b1; 
			
always(*)
 begin: state_table 
        case (current_state)
			adding: next_state = (x_state & current_state) ? subtracting : adding;
			subtracting: next_state = (x_state & current_state) ? subtracting : adding;
        default: next_state = adding;
        endcase
    end // state_table

always(*)

reg [9:0] x_out = 10'b0;

 begin: enable_signals 
        case (current_state)
			adding: begin 
			add_x = 10'b0000110000; //48
			end
			
			subtracting: begin
			add_x = 10'b1111010000; //-48
			end
        endcase
    end // state_table
endmodule 

module datapath();

endmodule


