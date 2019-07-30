/* 
 * e-Yantra Summer Internship Programme 2019
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * File name: LCD_Interfacing_8bit.v
 * Module: LCD_Interfacing_8bit
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
 */
`timescale 1ns/1ps

module LCD_Interfacing_8bit(
							input clock_in,								// Clock from FPGA Board
							input reset,									// Reset to refresh LCD 
							inout [7:0] LCD_DATA,						// 8 bit LCD data
							output LCD_EN,									// LCD enable bit
							output LCD_ON,									// Backlight switch
							output LCD_RS,									// LCD register select bit
							output LCD_RW									// LCD read-write bit
						  ); 


	wire 					  [7:0]	   lcd_data; 
	wire       							LCD_RW_1;
	wire       							LCD_EN_1;
	wire       							LCD_RS_1;
	wire		  							DLY_RST;
	assign 							   LCD_DATA = lcd_data;	
	assign 							   LCD_RW   = LCD_RW_1;
	assign 							   LCD_EN   = LCD_EN_1;
	assign 							   LCD_RS   = LCD_RS_1; 
	assign 							   LCD_ON   = 1'b1;

	// --------------------------------------------------------------------- //
	
	Reset_Delay		r0	(
						   .iCLK(clock_in),
							.oRESET(DLY_RST),
							.iRST_n(reset) 	
						);
						
	// --------------------------------------------------------------------- //
	LCD_ADC 		u5	(	
							.iCLK    (clock_in),
							.iRST_N  (DLY_RST),
							.LCD_DATA(lcd_data),
							.LCD_RW  (LCD_RW_1),
							.LCD_EN  (LCD_EN_1),
							.LCD_RS  (LCD_RS_1)
						);

endmodule 