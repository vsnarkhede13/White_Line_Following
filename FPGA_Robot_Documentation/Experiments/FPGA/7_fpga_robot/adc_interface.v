//////////////////////////////////////////////////////////////////////////////////
// e-Yantra Summer Internship Programme
// Project Title: Robot Design using FPGA
// Members: Karthik K Bhat, Vishal Narkhede
// Mentors: Simranjit Singh, Lohit Penubaku
//
// Design Name: adc_interface.v
// Module Name: adc_interface
//
// Target Devices: EP4CE22F17C6 (DE0-Nano Board)
// Tool Versions: Quartus Prime 18.1 Lite
// Description:
// 
// Dependencies:
//
// Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ps

/* 
 * Module: adc_interface
 * Purpose: To obtain the digital values from analog sensors
 * Inputs: Clock, Enable, Reset, MISO (SPI)
 * Ouputs: SPI: SCK, CE, MOSI
 * 		  Line sensor readings
 */ 

module adc_interface(
						   input clock_in,											// Clock from FPGA Board
						   input enable_conversion,								// To enable A/D Conversion - Active Low
						   input reset,
						 	
						   input miso,													// From DOUT Pin in ADC (MISO)	
						   output adc_serial_clk,									// Serial Clock for ADC
						   output reg adc_chip_enable,							// Active-low Chip Select output
						   output reg mosi,											// To DIN Pin in ADC (MOSI)
						   output reg [11:0] line_sensor_reading_2,			// To store line sensor readings
							output reg [11:0] line_sensor_reading_1,
							output reg [11:0] line_sensor_reading_0
						  ); 

						  
	reg [3:0] channel_select;											// To keep track of the line sensor channels
	reg [3:0] serial_clock_counter;									// SCK Clock counter
	reg [11:0] data_buffer;												// Data buffer

	/* 
	 * The ADC requires Serial Clock of 0.8 MHz to 3.2 MHz frequencies.
	 * Clock division here is for 50 MHz (from De0 Nano Board) to 3.125 MHz
	 */
	assign adc_serial_clk = clock_in;

	initial
	begin
		channel_select = 3'b0;
		serial_clock_counter = 4'b0;
		
		data_buffer = 12'b0;
		
		line_sensor_reading_2 = 12'b0;
		line_sensor_reading_1 = 12'b0;
		line_sensor_reading_0 = 12'b0;
	end
	
	
	// ---------------------------- Chip Select ---------------------------- //

	always @ (posedge clock_in /*enable_conversion*/ or negedge reset)
	begin
		if(~ reset)
			adc_chip_enable	<=	1'b1;								// Active-Low Signal
			
		else //if(enable_conversion)
		begin
			adc_chip_enable	<=	1'b0;
		end
	end

	// --------------------------------------------------------------------- //

 
	// ------------------------ Serial Clock Counter ----------------------- //

	/* 
	 * Digital Data from ADC is received every 16 Serial Clock cycles.
	 * Clock Cycle #3 - #5 (Positive Edge): Address of the channel
	 * Clock Cycle #5 - #16 (Negative Edge): Digital Data out from ADC
	 */

	always @ (posedge adc_serial_clk or posedge adc_chip_enable) 
	begin
		if (adc_chip_enable)
			serial_clock_counter <= 4'b0;
		else
			serial_clock_counter <= serial_clock_counter + 1'b1;
	end

	// --------------------------------------------------------------------- //


	// ------------------------ Send Address to ADC ------------------------ //

	always @ (negedge adc_serial_clk or posedge adc_chip_enable)
	begin
		// Set the MOSI to low when reset.
		if (adc_chip_enable)
			mosi <= 1'b0;
		else
		begin
			// Set the MOSI to the data when ADC SCK is low
			if (~ adc_serial_clk)
			begin
				case (serial_clock_counter)
						// Big Endian Format
						4'b0010: mosi <= channel_select[2];
						4'b0011: mosi <= channel_select[1];
						4'b0100: mosi <= channel_select[0];
						default: mosi <= 1'b0;
				endcase
			end
		end
	end

	// --------------------------------------------------------------------- //


	// ---------------------- Receive data from ADC ------------------------ //

	always @ (posedge adc_serial_clk or posedge adc_chip_enable) 
	begin
		// Reset the nets to zero when reset
		if (adc_chip_enable)
		begin
			data_buffer <= 12'b0;
			
			line_sensor_reading_2 <= 12'b0;
			line_sensor_reading_1 <= 12'b0;
			line_sensor_reading_0 <= 12'b0;
		end
		
		// Else start receiving data after 3 SCK cycles.
		else 
		begin
			if (adc_serial_clk)
			begin
				// Receive data when Serial clock counter is greater than 3.
				if (serial_clock_counter > 4'b0011)
					data_buffer <= {data_buffer[10:0], miso};
				
				// Push the data buffer to the register during 1st cycle of SCK
				else if (serial_clock_counter == 4'b0001)
				begin
					case(channel_select)
						2'b00: line_sensor_reading_0 <= data_buffer;
						2'b01: line_sensor_reading_1 <= data_buffer;
						2'b10: line_sensor_reading_2 <= data_buffer;
					endcase
				end
				
				// When its the 2nd cycle of SCK, clear the buffer and increment the channel select.
				else if (serial_clock_counter == 4'b0010)
				begin 
					data_buffer <= 12'b0;
					// Since only 3 channels are used, reset the channel_select to zero if greater than 3.
					if (channel_select < 2'b11)
						channel_select <= channel_select + 1'b1;
					else
						channel_select <= 2'b00;
				end
			end
		end
	end

	// --------------------------------------------------------------------- //

endmodule 