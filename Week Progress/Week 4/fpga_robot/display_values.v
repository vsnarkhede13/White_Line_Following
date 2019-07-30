//////////////////////////////////////////////////////////////////////////////////
// e-Yantra Summer Internship Programme
// Project Title: Robot Design using FPGA
// Members: Karthik K Bhat, Vishal Narkhede
// Mentors: Simranjit Singh, Lohit Penubaku
//
// Design Name: display_values.v
// Module Name: display_values
// Target Devices: EP4CE22F17C6 (DE0-Nano Board)
// Tool Versions: Quartus Prime 18.1 Lite
// Description:
// 
// Dependencies: 
// 	1. LCD_controller.v
//
// Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module	display_values(
					  input iCLK,
					  input iRST_N,
					  input [11:0] value0, value1, value2,
					  input [2:0] left_motor, right_motor,
					  input [2:0] movement,
					  //input [7:0] movement_direction,
					  output [7:0]LCD_DATA,
					  output LCD_RW, LCD_EN, LCD_RS
					 );

	reg [7:0] th[2:0];
	reg [7:0] h[2:0];
	reg [7:0] t[2:0];
	reg [7:0] u[2:0];
	
	reg [7:0] test0;
	reg [7:0] test1[3:0];
	reg [7:0] test2[3:0];
	
	reg	[5:0]	LUT_INDEX;
	reg	[8:0]	LUT_DATA;
	reg	[2:0]	mLCD_ST;
	reg	[17:0]	mDLY;
	reg			mLCD_Start;
	reg	[7:0]	mLCD_DATA;
	reg			mLCD_RS;
	
	wire		mLCD_Done;
	
	parameter	LCD_INTIAL	=	0;
	parameter	LCD_LINE1	=	5;
	parameter	LCD_CH_LINE	=	LCD_LINE1+16;
	parameter	LCD_LINE2	=	LCD_LINE1+16+1;
	parameter	LUT_SIZE	=	LCD_LINE1+32+1;
	
	
	always @ (value0 or value1 or value2)
	begin
		th[0] = {1'b1, ((value0 / 1000) + 8'h30)};
		h[0] = { 1'b1, (((value0 / 100) % 10) + 8'h30)};
		t[0] = { 1'b1, (((value0 / 10) % 10) +8'h30)};
		u[0] = { 1'b1, ((value0 % 10) +8'h30)};
		
		th[1] = {1'b1, ((value1 / 1000) + 8'h30)};
		h[1] = { 1'b1, (((value1 / 100) % 10) + 8'h30)};
		t[1] = { 1'b1, (((value1 / 10) % 10) +8'h30)};
		u[1] = { 1'b1, ((value1 % 10) +8'h30)};
		
		th[2] = {1'b1, ((value2 / 1000) + 8'h30)};
		h[2] = { 1'b1, (((value2 / 100) % 10) + 8'h30)};
		t[2] = { 1'b1, (((value2 / 10) % 10) +8'h30)};
		u[2] = { 1'b1, ((value2 % 10) +8'h30)};
		
		test0 = { 1'b1, ((movement % 10) +8'h30)};
		
		test1[3] = {1'b1, ((left_motor / 1000) + 8'h30)};
		test1[2] = { 1'b1, (((left_motor / 100) % 10) + 8'h30)};
		test1[1] = { 1'b1, (((left_motor / 10) % 10) +8'h30)};
		test1[0] = { 1'b1, ((left_motor % 10) +8'h30)};
		
		test2[3] = {1'b1, ((right_motor / 1000) + 8'h30)};
		test2[2] = { 1'b1, (((right_motor / 100) % 10) + 8'h30)};
		test2[1] = { 1'b1, (((right_motor / 10) % 10) +8'h30)};
		test2[0] = { 1'b1, ((right_motor % 10) +8'h30)};
		
	end
	
	always @ (posedge iCLK or negedge iRST_N)
	begin

		if(!iRST_N)
		begin
			LUT_INDEX	<=	0;
			mLCD_ST		<=	0;
			mDLY		<=	0;
			mLCD_Start	<=	0;
			mLCD_DATA	<=	0;
			mLCD_RS		<=	0;
		end
		else
				begin
					case(mLCD_ST)
						0:	begin
								mLCD_DATA	<=	LUT_DATA[7:0];
								mLCD_RS		<=	LUT_DATA[8];
								mLCD_Start	<=	1;
								mLCD_ST		<=	1;
							end
						1:	begin
								if(mLCD_Done)
								begin
									mLCD_Start	<=	0;
									mLCD_ST		<=	2;					
								end
							end
						2:	begin
								if(mDLY<18'h1FFFE)
								mDLY	<=	mDLY+1;
								else
								begin
									mDLY	<=	0;
									mLCD_ST	<=	3;
								end
							end
						3:	begin
								LUT_INDEX	<=	LUT_INDEX+1;
								mLCD_ST	<=	0;
							end
						endcase
				end
	end

	
	always
	begin
		case(LUT_INDEX)
			
			LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
			LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
			LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
			LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
			LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
			//	Line 1
			LCD_LINE1+0:	LUT_DATA	<=	{1'b1, th[0]};			// C
			LCD_LINE1+1:	LUT_DATA	<=	{1'b1, h[0]};			// 1
			LCD_LINE1+2:	LUT_DATA	<=	{1'b1, t[0]};			// :
			LCD_LINE1+3:	LUT_DATA	<=	{1'b1, u[0]};	// Thousandth value of Sensor 1
			LCD_LINE1+4:	LUT_DATA	<=	9'h120;	// Hundredth value of Sensor 1
			LCD_LINE1+5:	LUT_DATA	<=	{1'b1, th[1]};	// Tenth value of Sensor 1
			LCD_LINE1+6:	LUT_DATA	<=	{1'b1, h[1]};	// Units value of Sensor 1
			LCD_LINE1+7:	LUT_DATA	<=	{1'b1, t[1]};			// Space
			LCD_LINE1+8:	LUT_DATA	<=	{1'b1, u[1]};			// C
			LCD_LINE1+9:	LUT_DATA	<=	9'h120;			// 2
			LCD_LINE1+10:	LUT_DATA	<=	{1'b1, th[2]};			// :
			LCD_LINE1+11:	LUT_DATA	<=	{1'b1, h[2]};	// Thousandth value of Sensor 2
			LCD_LINE1+12:	LUT_DATA	<=	{1'b1, t[2]};	// Hundredth value of Sensor 2
			LCD_LINE1+13:	LUT_DATA	<=	{1'b1, u[2]};	// Tenth value of Sensor 2
			LCD_LINE1+14:	LUT_DATA	<=	9'h120;	// Units value of Sensor 2
			LCD_LINE1+15:	LUT_DATA	<=	9'h120;
			//	Change Line
			LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;			//	Line 2
			
			LCD_LINE2+0:	LUT_DATA	<=	9'h120;
			LCD_LINE2+1:	LUT_DATA	<=	9'h120;
			LCD_LINE2+2:	LUT_DATA	<=	9'h120;
			LCD_LINE2+3:	LUT_DATA	<=	9'h120;// {1'b1, test1[3]};
			LCD_LINE2+4:	LUT_DATA	<=	9'h120;//{1'b1, test1[2]};	// Hundredth value of Sensor 3
			LCD_LINE2+5:	LUT_DATA	<=	9'h120;//{1'b1, test1[1]};	// Tenth value of Sensor 3
			LCD_LINE2+6:	LUT_DATA	<=	9'h120;//{1'b1, test1[0]};	// Units value of Sensor 3
			LCD_LINE2+7:	LUT_DATA	<=	9'h120;
			LCD_LINE2+8:	LUT_DATA	<=	9'h120;
			LCD_LINE2+9:	LUT_DATA	<=	9'h120;//{1'b1, test2[3]}; // For testing
			LCD_LINE2+10:	LUT_DATA	<=	9'h120;//{1'b1, test2[2]};
			LCD_LINE2+11:	LUT_DATA	<=	{1'b1, test2[0]};
			LCD_LINE2+12:	LUT_DATA	<=	9'h120;//{1'b1, test2[0]};
			LCD_LINE2+13:	LUT_DATA	<=	9'h120;
			LCD_LINE2+14:	LUT_DATA	<=	9'h120;
			LCD_LINE2+15:	LUT_DATA	<=	{1'b1, test0};
			default:		LUT_DATA	<=	9'h120;
		endcase
	end

	LCD_Controller u0(
							.iDATA(mLCD_DATA),
							.iRS(mLCD_RS),
							.iStart(mLCD_Start),
							.oDone(mLCD_Done),
							.iCLK(iCLK),
							.iRST_N(iRST_N),
							
							.LCD_DATA(LCD_DATA),
							.LCD_RW(LCD_RW),
							.LCD_EN(LCD_EN),
							.LCD_RS(LCD_RS)
						  );

endmodule