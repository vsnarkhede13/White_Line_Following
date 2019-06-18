module	LCD_ADC (	//	Host Side
					iCLK,iRST_N,channel,value0,value1,value2,
					//	LCD Side
					LCD_DATA,LCD_RW,LCD_EN,LCD_RS,th,h,t,u);
	//	Host Side
	input			iCLK,iRST_N;
	input  		[2:0]channel;
	input [11:0]value0;
	input [11:0]value1;
	input [11:0]value2;
	//	LCD Side
	output	[7:0]	LCD_DATA;
	output			LCD_RW,LCD_EN,LCD_RS;
	//	Internal Wires/Registers
	output     	[7:0]th[2:0] ;
	output    	[7:0]h[2:0] ;
	output    	[7:0]t[2:0] ;
	output    	[7:0]u[2:0] ;
	wire 	[11:0]v1;
	reg	[5:0]	LUT_INDEX;
	reg	[8:0]	LUT_DATA;
	reg	[5:0]	mLCD_ST;
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
	integer r;
	
	/*always @ (value0 or value1 or value2)
	begin
		th[0] <= {1'b1,((value0 / 1000) + 8'h30)};
		h[0] <= { 1'b1,(((value0 / 100) % 10) + 8'h30)};
		t[0] <= { 1'b1,(((value0 / 10)%10) + 8'h30)};
		u[0] <= { 1'b1,((value0 % 10) + 8'h30)};
		
		th[1] <= {1'b1,((value1 / 1000) + 8'h30)};
		h[1] <= { 1'b1,(((value1 / 100) % 10) + 8'h30)};
		t[1] <= { 1'b1,(((value1 / 10)%10) + 8'h30)};
		u[1] <= { 1'b1,((value1 % 10) + 8'h30)};
		
		th[2] <= {1'b1,((value2 / 1000) + 8'h30)};
		h[2] <= { 1'b1,(((value2 / 100) % 10) + 8'h30)};
		t[2] <= { 1'b1,(((value2 / 10)%10) + 8'h30)};
		u[2] <= { 1'b1,((value2 % 10) + 8'h30)};
	end*/
	dec2hex c1 (
		.count(value0),
		.th(th[0]),
		.h(h[0]),
		.t(t[0]),
		.u(u[0]));
	dec2hex c2 (
		.count(value1),
		.th(th[1]),
		.h(h[1]),
		.t(t[1]),
		.u(u[1]));
	dec2hex c3 (
		.count(value2),
		.th(th[2]),
		.h(h[2]),
		.t(t[2]),
		.u(u[2]));
		
	

	always @ (posedge iCLK or negedge iRST_N )
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
			if(LUT_INDEX == LCD_LINE2+15)
				LUT_INDEX = LCD_LINE1+0;
			else
				if(LUT_INDEX<LUT_SIZE)
			//if((LUT_INDEX<LUT_SIZE)||(LUT_INDEX == LCD_LINE1+3)||(LUT_INDEX == LCD_LINE1+4)||(LUT_INDEX == LCD_LINE1+5)||(LUT_INDEX == LCD_LINE1+6)||(LUT_INDEX == LCD_LINE1+11)||(LUT_INDEX == LCD_LINE1+12)||(LUT_INDEX == LCD_LINE1+13)||(LUT_INDEX == LCD_LINE1+14)||(LUT_INDEX == LCD_LINE2+3)||(LUT_INDEX == LCD_LINE2+4)||(LUT_INDEX == LCD_LINE2+5)||(LUT_INDEX == LCD_LINE2+6))
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
						if(mDLY<18'h3FFFE)
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
	end

	always @ (value0 or value1 or value2)
	begin
		case(LUT_INDEX)
		//	Initial
		LCD_INTIAL+0:	LUT_DATA	<=	9'h038;
		LCD_INTIAL+1:	LUT_DATA	<=	9'h00C;
		LCD_INTIAL+2:	LUT_DATA	<=	9'h001;
		LCD_INTIAL+3:	LUT_DATA	<=	9'h006;
		LCD_INTIAL+4:	LUT_DATA	<=	9'h080;
		//	Line 1
		LCD_LINE1+0:	LUT_DATA	<=	9'h143;
		LCD_LINE1+1:	LUT_DATA	<=	9'h131;	
		LCD_LINE1+2:	LUT_DATA	<=	9'h13A;
		LCD_LINE1+3:	LUT_DATA	<=	{1'b1, th[0]};
		LCD_LINE1+4:	LUT_DATA	<=	{1'b1, h[0]};
		LCD_LINE1+5:	LUT_DATA	<=	{1'b1, t[0]};
		LCD_LINE1+6:	LUT_DATA	<=	{1'b1, u[0]};
		LCD_LINE1+7:	LUT_DATA	<=	9'h120;
		LCD_LINE1+8:	LUT_DATA	<=	9'h143;
		LCD_LINE1+9:	LUT_DATA	<=	9'h132;
		LCD_LINE1+10:	LUT_DATA	<=	9'h13A;
		LCD_LINE1+11:	LUT_DATA	<=	{1'b1, th[1]};
		LCD_LINE1+12:	LUT_DATA	<=	{1'b1, h[1]};
		LCD_LINE1+13:	LUT_DATA	<=	{1'b1, t[1]};
		LCD_LINE1+14:	LUT_DATA	<=	{1'b1, u[1]};
		LCD_LINE1+15:	LUT_DATA	<=	9'h120;
		//	Change Line
		LCD_CH_LINE:	LUT_DATA	<=	9'h0C0;
		//	Line 2
		LCD_LINE2+0:	LUT_DATA	<=	9'h143;	
		LCD_LINE2+1:	LUT_DATA	<=	9'h133;
		LCD_LINE2+2:	LUT_DATA	<=	9'h13A;
		LCD_LINE2+3:	LUT_DATA	<=	{1'b1, th[2]};
		LCD_LINE2+4:	LUT_DATA	<=	{1'b1, h[2]};
		LCD_LINE2+5:	LUT_DATA	<=	{1'b1, t[2]};
		LCD_LINE2+6:	LUT_DATA	<=	{1'b1, u[2]};
		LCD_LINE2+7:	LUT_DATA	<=	9'h120;  
		LCD_LINE2+8:	LUT_DATA	<=	9'h120;  
		LCD_LINE2+9:	LUT_DATA	<=	9'h120;  
		LCD_LINE2+10:	LUT_DATA	<=	9'h120; 
		LCD_LINE2+11:	LUT_DATA	<=	9'h120;
		LCD_LINE2+12:	LUT_DATA	<=	9'h120;
		LCD_LINE2+13:	LUT_DATA	<=	9'h120;
		LCD_LINE2+14:	LUT_DATA	<=	9'h120;
		LCD_LINE2+15:	begin 
								LUT_DATA	<=	9'h120;
								//LUT_INDEX <= LCD_LINE1+0;
							end
		default:		LUT_DATA	<=	9'h120;
		endcase
	end

	LCD_Controller 		u0	(	//	Host Side
								.iDATA(mLCD_DATA),
								.iRS(mLCD_RS),
								.iStart(mLCD_Start),
								.oDone(mLCD_Done),
								.iCLK(iCLK),
								.iRST_N(iRST_N),
								//	LCD Interface
								.LCD_DATA(LCD_DATA),
								.LCD_RW(LCD_RW),
								.LCD_EN(LCD_EN),
								.LCD_RS(LCD_RS)	);

endmodule