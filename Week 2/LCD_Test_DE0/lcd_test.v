module lcd_test (
					  input clk,
					  output reg lcd_rs,
					  output reg lcd_rw,
					  output reg lcd_e,
					  output reg lcd_4,
					  output reg lcd_5,
					  output reg lcd_6,
					  output reg lcd_7
					 );
	parameter n = 27;
	parameter k = 16;
	reg [n-1:0] count=0;
	reg lcd_busy=1;
	reg lcd_stb;
	reg [5:0] lcd_code;
	reg [6:0] lcd_stuff;

	always @ (posedge clk)
	begin
		count <= count + 1;
		case (count[k+8:k+3])
			0: lcd_code <= 6'b000010; // function set 
			1: lcd_code <= 6'b000010; 
			2: lcd_code <= 6'b001100; 
			3: lcd_code <= 6'b000000; // display on/off control 
			4: lcd_code <= 6'b001100; 
			5: lcd_code <= 6'b000000; // display clear 
			6: lcd_code <= 6'b000001; 
			7: lcd_code <= 6'b000000; // entry mode set 
			8: lcd_code <= 6'b000110; 
			9: lcd_code <= 6'h24; // H 
			10: lcd_code <= 6'h28; 
			11: lcd_code <= 6'h26; // e 
			12: lcd_code <= 6'h25;
			13: lcd_code <= 6'h26; // l 
			14: lcd_code <= 6'h2C; 
			15: lcd_code <= 6'h26; // l 
			16: lcd_code <= 6'h2C; 
			17: lcd_code <= 6'h26; // o 
			18: lcd_code <= 6'h2F; 
			19: lcd_code <= 6'h22; // 
			20: lcd_code <= 6'h20; 
			21: lcd_code <= 6'h25; // W 
			22: lcd_code <= 6'h27; 
			23: lcd_code <= 6'h26; // o 
			24: lcd_code <= 6'h2F; 
			25: lcd_code <= 6'h27; // r 
			26: lcd_code <= 6'h22; 
			27: lcd_code <= 6'h26; // l 
			28: lcd_code <= 6'h2C; 
			29: lcd_code <= 6'h26; // d
			30: lcd_code <= 6'h24; 
			31: lcd_code <= 6'h22; // ! 
			32: lcd_code <= 6'h21;
			default: lcd_code <= 6'b010000; 
		endcase 
		if (lcd_rw) 
			lcd_busy <= 0;
			
		lcd_stb <= ^count[k+2:k+1] & ~lcd_rw & lcd_busy; // clkrate / 2^(k+2) 
		lcd_stuff <= {lcd_stb, lcd_code};
		{lcd_e,lcd_rs,lcd_rw,lcd_7,lcd_6,lcd_5,lcd_4} <= lcd_stuff; 
	end 
endmodule 