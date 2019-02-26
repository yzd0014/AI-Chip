module pebble_game(
	input clock,
	input reset,
	input play,
	input player_position,
	output wire [1:0] winner,
	output wire [3:0] pos1, pos2, pos3, pos4
);
wire [3:0] i_pos1, i_pos2, i_pos3, i_pos4;
wire [1:0] PC_en, PL_en;
wire game_over;
wire illegal_move;
wire player_play, computer_play;

fsm_controller fsm_controller_unit(clock, reset, play, game_over, illegal_move, player_play, computer_play);
min_max min_max_unit(computer_play, pos1, pos2, pos3, pos4, PC_en);
position_decoder position_decoder_unit(player_position, player_play, PL_en);
position_updater position_updater_unit(PC_en, PL_en, pos1, pos2, pos3, pos4, i_pos1, i_pos2, i_pos3, i_pos4);
winner_detector winner_detector_unit(pos1, pos2, game_over, winner);
illegal_move_detector illegal_move_detector_unit(pos3, pos4, PL_en, illegal_move);
position_registors position_registors_unit(clock, reset, i_pos1, i_pos2, i_pos3, i_pos4, pos1, pos2, pos3, pos4);
endmodule

module min_max(
input enable,
input [3:0] i_pos1, i_pos2, i_pos3, i_pos4,
output [1:0] out_en
);
wire [3:0] lvl1 [7:0];
wire [3:0] lvl2 [15:0];
wire [3:0] lvl3 [31:0];
wire [3:0] lvl4 [63:0];
wire [3:0] lvl5 [127:0];

wire [3:0] utility_value_lvl5 [31:0];
wire [3:0] utility_value_lvl4 [15:0];
wire [3:0] utility_value_lvl3 [8:0];
wire [3:0] utility_value_lvl2 [4:0];
wire [3:0] utility_value_lvl1 [2:0];

wire [1:0] en_opt1;
wire [1:0] en_opt2;
wire [1:0] en_place_holder;

wire [1:0] temp;

assign out_en = (enable == 1'b1)?temp:2'd0;

assign en_opt1 = 2'b01;
assign en_opt2 = 2'b10;
assign en_place_holder = 2'b00;

//lvl 1
position_updater position_updater_lvl1_0(en_opt1, en_place_holder, i_pos1, i_pos2, i_pos3, i_pos4, lvl1[0], lvl1[1], lvl1[2], lvl1[3]);
position_updater position_updater_lvl1_1(en_opt2, en_place_holder, i_pos1, i_pos2, i_pos3, i_pos4, lvl1[4], lvl1[5], lvl1[6], lvl1[7]);

//lvl2
position_updater position_updater_lvl2_0(en_place_holder, en_opt1, lvl1[0], lvl1[1], lvl1[2], lvl1[3], lvl2[0], lvl2[1], lvl2[2], lvl2[3]);
position_updater posistion_updater_lvl2_1(en_place_holder, en_opt2, lvl1[0], lvl1[1], lvl1[2], lvl1[3], lvl2[4], lvl2[5], lvl2[6], lvl2[7]);

position_updater position_updater_lvl2_2(en_place_holder, en_opt1, lvl1[4], lvl1[5], lvl1[6], lvl1[7], lvl2[8], lvl2[9], lvl2[10], lvl2[11]);
position_updater position_updater_lvl2_3(en_place_holder, en_opt2, lvl1[4], lvl1[5], lvl1[6], lvl1[7], lvl2[12], lvl2[13], lvl2[14], lvl2[15]);

genvar i;
//lvl3
generate
	for(i = 0; i < 8; i = i + 1)begin: new_board_lvl3
		if(i % 2 == 0)begin: u3
			position_updater position_updater_lvl3(en_opt1, en_place_holder, lvl2[i/2*4], lvl2[i/2*4+1], lvl2[i/2*4+2], lvl2[i/2*4+3], lvl3[i*4], lvl3[i*4+1], lvl3[i*4+2], lvl3[i*4+3]);
		end
		else begin: u3
			position_updater position_updater_lvl3(en_opt2, en_place_holder, lvl2[i/2*4], lvl2[i/2*4+1], lvl2[i/2*4+2], lvl2[i/2*4+3], lvl3[i*4], lvl3[i*4+1], lvl3[i*4+2], lvl3[i*4+3]);
		end
	end
endgenerate

//lvl4
generate
	for(i = 0; i < 16; i = i + 1)begin: new_board_lvl4
		if(i % 2 == 0)begin: u4
			position_updater position_updater_lvl4(en_place_holder, en_opt1, lvl3[i/2*4], lvl3[i/2*4+1], lvl3[i/2*4+2], lvl3[i/2*4+3], lvl4[i*4], lvl4[i*4+1], lvl4[i*4+2], lvl4[i*4+3]);
		end
		else begin: u4
			position_updater position_updater_lvl4(en_place_holder, en_opt2, lvl3[i/2*4], lvl3[i/2*4+1], lvl3[i/2*4+2], lvl3[i/2*4+3], lvl4[i*4], lvl4[i*4+1], lvl4[i*4+2], lvl4[i*4+3]);
		end
	end
endgenerate

//lvl5
generate
	for(i = 0; i < 32; i = i + 1)begin: new_board_lvl5
		if(i % 2 == 0)begin: u5
			position_updater position_updater_lvl5(en_opt1, en_place_holder, lvl4[i/2*4], lvl4[i/2*4+1], lvl4[i/2*4+2], lvl4[i/2*4+3], lvl5[i*4], lvl5[i*4+1], lvl5[i*4+2], lvl5[i*4+3]);
		end
		else begin: u5
			position_updater position_updater_lvl5(en_opt2, en_place_holder, lvl4[i/2*4], lvl4[i/2*4+1], lvl4[i/2*4+2], lvl4[i/2*4+3], lvl5[i*4], lvl5[i*4+1], lvl5[i*4+2], lvl5[i*4+3]);
		end
	end
endgenerate

//lvl5
generate
	for(i = 0; i < 32; i = i + 1)begin: utility_lvl5
		heuristic get_utility_lvl5(lvl5[i*4], lvl5[i*4+1], utility_value_lvl5[i]);
	end
endgenerate

//lvl4
generate
	for(i = 0; i < 16; i = i + 1)begin: utility_lvl4
		max_comparator get_max_lvl4(lvl4[i*4], lvl4[i*4+1], utility_value_lvl5[i*2], utility_value_lvl5[i*2+1], utility_value_lvl4[i]);
	end
endgenerate

//lvl3
generate
	for(i = 0; i < 8; i = i + 1)begin: utility_lvl3
		min_comparator get_min_lvl3(lvl3[i*4+2], lvl3[i*4+3], utility_value_lvl4[i*2], utility_value_lvl4[i*2+1], utility_value_lvl3[i]);
	end
endgenerate

//lvl2
generate
	for(i = 0; i < 4; i = i + 1)begin: utility_lvl2
		max_comparator get_max_lvl2(lvl2[i*4], lvl2[i*4+1], utility_value_lvl3[i*2], utility_value_lvl3[i*2+1], utility_value_lvl2[i]);
	end
endgenerate

//lvl1
generate
	for(i = 0; i < 2; i = i + 1)begin: utility_lvl1
		min_comparator get_min_lvl1(lvl1[i*4+2], lvl1[i*4+3], utility_value_lvl2[i*2], utility_value_lvl2[i*2+1], utility_value_lvl1[i]);
	end
endgenerate

top_comparator top_comparator_unit(i_pos1, i_pos2, utility_value_lvl1[0], utility_value_lvl1[1], temp);

endmodule

module top_comparator(
input [3:0] i_pos1, i_pos2,
input [3:0] utility_a, utility_b,
output reg [1:0] out_en
);
always @(*)
begin
	if(i_pos1 == 4'b0000 && i_pos2 == 4'b0000)begin
		out_en <= 2'b00;
	end
	else if(i_pos1 == 4'b0000 && i_pos2 != 4'b0000)begin
		out_en <= 2'b10;
	end
	else if(i_pos1 != 4'b0000 && i_pos2 == 4'b0000)begin
		out_en <= 2'b01;
	end
	else begin
		if(utility_a >= utility_b)
			out_en <= 2'b01;
		else
			out_en <= 2'b10;
	end
end

endmodule

module max_comparator(
input [3:0] i_pos1, i_pos2, 
input [3:0] utility_a, utility_b,
output reg [3:0] o_utility
);
always @(*)
begin
	if(i_pos1 == 4'b0000 && i_pos2 == 4'b0000)
		o_utility <= 4'b0000;
	else if(i_pos1 + i_pos2 == 4'b1000)
		o_utility <= 4'b1000;	
	else 
		if(i_pos1 == 4'b0000 && i_pos2 != 4'b0000)
			o_utility <= utility_b;
		else if(i_pos1 != 4'b0000 && i_pos2 == 4'b0000)
			o_utility <= utility_a;
		else
			if(utility_a > utility_b)
				o_utility <= utility_a;
			else
				o_utility <= utility_b;	
	
end
endmodule

module min_comparator(
input [3:0] i_pos3, i_pos4,
input [3:0] utility_a, utility_b,
output reg [3:0] o_utility
);
always @(*)
begin
	if(i_pos3 == 4'b0000 && i_pos4 == 4'b0000)
		o_utility <= 4'b1000;
	else if(i_pos3 + i_pos4 == 4'b1000)
		o_utility <= 4'b0000;	
	else 
		if(i_pos3 == 4'b0000 && i_pos4 != 4'b0000)
			o_utility <= utility_b;
		else if(i_pos3 != 4'b0000 && i_pos4 == 4'b0000)
			o_utility <= utility_a;
		else
			if(utility_a > utility_b)
				o_utility <= utility_b;
			else
				o_utility <= utility_a;	

end
endmodule


module heuristic(
input [3:0] i_pos1, i_pos2,
output reg [3:0] utility
);
always @(*)
	utility <= i_pos1 + i_pos2;
endmodule


module position_registors(
input clock,
input reset,
input [3:0] i_pos1, i_pos2, i_pos3, i_pos4,
output reg [3:0] o_pos1, o_pos2, o_pos3, o_pos4
);
always @(posedge clock, posedge reset)
begin
	if(reset) begin
		o_pos1 <= 4'd2;
		o_pos2 <= 4'd2;
		o_pos3 <= 4'd2;
		o_pos4 <= 4'd2;
	end
	else begin
		o_pos1 <= i_pos1;
		o_pos2 <= i_pos2;
		o_pos3 <= i_pos3;
		o_pos4 <= i_pos4;
	end
end
endmodule

module position_updater(
input [1:0] PC_en,
input [1:0] PL_en,
input [3:0] i_pos1, i_pos2, i_pos3, i_pos4,
output reg [3:0] o_pos1, o_pos2, o_pos3, o_pos4
);
always @(*)
begin
	case({PL_en, PC_en})
		4'b0001:begin
			case(i_pos1 % 4'd4)
			4'd0: begin
			o_pos1 <= i_pos1 / 4'd4;
			o_pos2 <= i_pos2 + i_pos1 / 4'd4;
			o_pos3 <= i_pos3 + i_pos1 / 4'd4;
			o_pos4 <= i_pos4 + i_pos1 / 4'd4;
			end
			4'd1: begin
			o_pos1 <= i_pos1 / 4'd4;
			o_pos2 <= i_pos2 + i_pos1 / 4'd4 + 4'd1;
			o_pos3 <= i_pos3 + i_pos1 / 4'd4;
			o_pos4 <= i_pos4 + i_pos1 / 4'd4;
			end 
			4'd2: begin
			o_pos1 <= i_pos1 / 4'd4;
			o_pos2 <= i_pos2 + i_pos1 / 4'd4 + 4'd1;
			o_pos3 <= i_pos3 + i_pos1 / 4'd4 + 4'd1;
			o_pos4 <= i_pos4 + i_pos1 / 4'd4;
			end
			4'd3: begin
			o_pos1 <= i_pos1 / 4'd4;
			o_pos2 <= i_pos2 + i_pos1 / 4'd4 + 4'd1;
			o_pos3 <= i_pos3 + i_pos1 / 4'd4 + 4'd1;
			o_pos4 <= i_pos4 + i_pos1 / 4'd4 + 4'd1;
			end
			default:begin
			o_pos1<=4'bxxxx;
			o_pos2<=4'bxxxx;
			o_pos3<=4'bxxxx;
			o_pos4<=4'bxxxx;
			end
			endcase
		end
		4'b0010:begin
			case(i_pos2 % 4'd4)
			4'd0: begin
			o_pos1 <= i_pos1 + i_pos2 / 4'd4;
			o_pos2 <= i_pos2 / 4'd4;
			o_pos3 <= i_pos3 + i_pos2 / 4'd4;
			o_pos4 <= i_pos4 + i_pos2 / 4'd4;
			end
			4'd1: begin
			o_pos1 <= i_pos1 + i_pos2 / 4'd4;
			o_pos2 <= i_pos2 / 4'd4;
			o_pos3 <= i_pos3 + i_pos2 / 4'd4 + 4'd1;
			o_pos4 <= i_pos4 + i_pos2 / 4'd4;
			end 
			4'd2: begin
			o_pos1 <= i_pos1 + i_pos2 / 4'd4;
			o_pos2 <= i_pos2 / 4'd4;
			o_pos3 <= i_pos3 + i_pos2 / 4'd4 + 4'd1;
			o_pos4 <= i_pos4 + i_pos2 / 4'd4 + 4'd1;
			end
			4'd3: begin
			o_pos1 <= i_pos1 + i_pos2 / 4'd4 + 4'd1;
			o_pos2 <= i_pos2 / 4'd4;
			o_pos3 <= i_pos3 + i_pos2 / 4'd4 + 4'd1;
			o_pos4 <= i_pos4 + i_pos2 / 4'd4 + 4'd1;
			end
			default:begin
			o_pos1<=4'bxxxx;
			o_pos2<=4'bxxxx;
			o_pos3<=4'bxxxx;
			o_pos4<=4'bxxxx;
			end
			endcase
		end
		4'b0100:begin
			case(i_pos3 % 4'd4)
			4'd0: begin
			o_pos1 <= i_pos1 + i_pos3 / 4'd4;
			o_pos2 <= i_pos2 + i_pos3 / 4'd4;
			o_pos3 <= i_pos3 / 4'd4;
			o_pos4 <= i_pos4 + i_pos3 / 4'd4;
			end
			4'd1: begin
			o_pos1 <= i_pos1 + i_pos3 / 4'd4;
			o_pos2 <= i_pos2 + i_pos3 / 4'd4;
			o_pos3 <= i_pos3 / 4'd4;
			o_pos4 <= i_pos4 + i_pos3 / 4'd4 + 4'd1;
			end 
			4'd2: begin
			o_pos1 <= i_pos1 + i_pos3 / 4'd4 + 4'd1;
			o_pos2 <= i_pos2 + i_pos3 / 4'd4;
			o_pos3 <= i_pos3 / 4'd4;
			o_pos4 <= i_pos4 + i_pos3 / 4'd4 + 4'd1;
			end
			4'd3: begin
			o_pos1 <= i_pos1 + i_pos3 / 4'd4 + 4'd1;
			o_pos2 <= i_pos2 + i_pos3 / 4'd4 + 4'd1;
			o_pos3 <= i_pos3 / 4'd4;
			o_pos4 <= i_pos4 + i_pos3 / 4'd4 + 4'd1;
			end
			default:begin
			o_pos1<=4'bxxxx;
			o_pos2<=4'bxxxx;
			o_pos3<=4'bxxxx;
			o_pos4<=4'bxxxx;
			end
			endcase
		end
		4'b1000:begin
			case(i_pos4 % 4'd4)
			4'd0: begin
			o_pos1 <= i_pos1 + i_pos4 / 4'd4;
			o_pos2 <= i_pos2 + i_pos4 / 4'd4;
			o_pos3 <= i_pos3 + i_pos4 / 4'd4;
			o_pos4 <= i_pos4 / 4'd4;
			end
			4'd1: begin
			o_pos1 <= i_pos1 + i_pos4 / 4'd4 + 4'd1;
			o_pos2 <= i_pos2 + i_pos4 / 4'd4;
			o_pos3 <= i_pos3 + i_pos4 / 4'd4;
			o_pos4 <= i_pos4 / 4'd4;
			end 
			4'd2: begin
			o_pos1 <= i_pos1 + i_pos4 / 4'd4 + 4'd1;
			o_pos2 <= i_pos2 + i_pos4 / 4'd4 + 4'd1;
			o_pos3 <= i_pos3 + i_pos4 / 4'd4;
			o_pos4 <= i_pos4 / 4'd4;
			end
			4'd3: begin
			o_pos1 <= i_pos1 + i_pos4 / 4'd4 + 4'd1;
			o_pos2 <= i_pos2 + i_pos4 / 4'd4 + 4'd1;
			o_pos3 <= i_pos3 + i_pos4 / 4'd4 + 4'd1;
			o_pos4 <= i_pos4 / 4'd4;
			end
			default:begin
			o_pos1<=4'bxxxx;
			o_pos2<=4'bxxxx;
			o_pos3<=4'bxxxx;
			o_pos4<=4'bxxxx;
			end
			endcase
		end
		4'b0000: begin
			o_pos1<=i_pos1;
			o_pos2<=i_pos2;
			o_pos3<=i_pos3;
			o_pos4<=i_pos4;
		end
		default:begin
			o_pos1<=4'bxxxx;
			o_pos2<=4'bxxxx;
			o_pos3<=4'bxxxx;
			o_pos4<=4'bxxxx;
		end
	endcase	
end
endmodule

module input_registor(
	input reset,
	input play,
	input set_zero,
	output reg play_intermediate
);
always @(posedge play, posedge reset, posedge set_zero)
begin
	if(set_zero)
		play_intermediate <= 1'b0;
	else if(reset)
		play_intermediate <= 1'b0;
	else	
		play_intermediate <= 1'b1;
end
endmodule

module fsm_controller(
	input clock,
	input reset,
	input play,
	input game_over,
	input illegal_move,
	output reg player_play,
	output reg computer_play
	);
parameter IDLE = 2'b00;
parameter ACTIVE = 2'b01;
parameter AI = 2'b10;
parameter GAME_OVER = 2'b11;
reg [1:0] current_state, next_state;
wire play_intermediate;
reg set_zero;

input_registor input_unit(reset, play, set_zero, play_intermediate);

always @(posedge clock, posedge reset)
begin
	if(reset)
		current_state <= IDLE;
	else 	
		current_state <= next_state;
end

always @(*)
begin
	case(current_state)
	IDLE: begin
		if(reset == 1'b0 && play_intermediate == 1'b1 && game_over == 1'b0)
			next_state <= ACTIVE;
		else if(game_over == 1'b1)
			next_state <= GAME_OVER;
		else 
			next_state <= IDLE;
		
		player_play <= 1'b0;
		computer_play <= 1'b0;
		set_zero <= 1'b0;	
	end
	ACTIVE: begin
		if(illegal_move == 1'b0) next_state <= AI;
		else next_state <= IDLE;
		
		player_play <= 1'b1;
		computer_play<= 1'b0;
		set_zero <= 1'b1;
	end
	AI: begin
		if(game_over == 1'b0) begin
			next_state <= IDLE;
			computer_play <= 1'b1;
		end
		else begin
			next_state <= GAME_OVER;
			computer_play <= 1'b0;	
		end

		player_play <= 1'b0;
		set_zero <= 1'bx;	
	end
	GAME_OVER: begin
		if(reset == 1'b1) next_state <= IDLE; 		
		else next_state <= GAME_OVER;

		player_play <= 1'b0;
		computer_play <= 1'b0;
		set_zero <= 1'bx;	
	end 
	endcase
end
endmodule

module position_decoder(
	input in,
	input enable,
	output wire [1:0] out_en

);
reg[2:0] temp;
assign out_en = (enable == 1'b1)?temp:2'd0;
always @(*)
begin
	case(in)
		1'b0: temp <= 2'b01;
		1'b1: temp <= 2'b10;
	endcase
end
endmodule

module illegal_move_detector(
	input [3:0] i_pos3, i_pos4,
	input [1:0] PL_en,
	output reg illegal_move
);
always @(*)
begin
	case(PL_en)
		2'b01:begin
			if(i_pos3 == 1'd0) illegal_move <= 1'b1;
			else illegal_move <= 1'b0;
		end 
		2'b10:begin
			if(i_pos4 == 1'd0) illegal_move <= 1'b1;
			else illegal_move <= 1'b0;
		end
		2'b00: illegal_move <= 1'b0;
		default: illegal_move <= 1'bx;
	endcase	
end
endmodule

module winner_detector(
	input [3:0] i_pos1, i_pos2,
	output reg game_over,
	output reg [1:0] winner
);
always @(*)
begin
	if(i_pos1 == 4'b0000 && i_pos2 == 4'b0000) begin
		winner <= 2'b10;
		game_over <= 1'b1;
	end
	else if(i_pos1 + i_pos2 == 4'b1000) begin
		winner <= 2'b01;
		game_over <= 1'b1;
	end
	else begin
		winner <= 2'b00;
		game_over <= 1'b0;
	end
end
endmodule 
