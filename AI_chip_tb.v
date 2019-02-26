`timescale 1ns/1ns
module pebble_game_test_bench;
reg clock;
reg reset;
reg play;
reg player_position;

wire [3:0] pos1;
wire [3:0] pos2;
wire [3:0] pos3;
wire [3:0] pos4;
wire [1:0] winner;

pebble_game unit_test(clock, reset, play, player_position, winner, pos1, pos2, pos3, pos4);

initial begin
clock = 0;
forever #50 clock = ~clock;
end

initial begin
play = 1'b0;
reset = 1'b1;
player_position = 2'd0;
#100;
reset = 1'b0;
#100;
play = 1'b1;
player_position = 1'b1;
#200;
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b1;
#200
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b0;
#200
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b0;
#200
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b1;
#200
play = 1'b0;

#200
reset = 1'b1;

#50
reset = 1'b0;
play = 1'b1; 
player_position = 1'b0;
#300
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b0;
#300
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b0;
#300
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b1;
#300
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b1;
#300
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b0;
#300
play = 1'b0;

#200
play = 1'b1;
player_position = 1'b1;
#300
play = 1'b0;
end

endmodule
