/* e-Yantra Summer Internship Programme
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * Author: Karthik K Bhat
 * File name: line_sensor_interface.v
 * Module: line_sensor_interface
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
 */
`timescale 1ns/1ps

module line_sensor_interface1(
							input clock_in,								// Clock from FPGA Board
							input enable_conversion,					// To enable A/D Conversion - Active Low
							input reset,
							
							input miso,										// From DOUT Pin in ADC (MISO)
							output reg adc_chip_enable,				// Active-low Chip Select output
							output adc_serial_clk,						// Serial Clock for ADC
							output reg mosi,								// To DIN Pin in ADC (MOSI)
							output [7:0] line
						  ); 

						  
	reg [3:0] channel_select;											// To keep track of the line sensor channels
	reg [3:0] serial_clock_counter;									// SCK Clock counter
	reg [24:0] clock_division_counter;								// Clock division
	reg [11:0] line_sensor_reading [2:0];							// To store line sensor readings
	reg [11:0] data_buffer;												// Data buffer
	reg [1:0] output_counter;

	assign adc_serial_clk = clock_division_counter[4];
	assign line = line_sensor_reading[output_counter][11:4];

	initial
	begin
		channel_select = 3'b0;
		clock_division_counter = 25'b0;
		serial_clock_counter = 4'b0;
		
		data_buffer = 12'b0;
		
		line_sensor_reading[0] = 12'b0;
		line_sensor_reading[1] = 12'b0;
		line_sensor_reading[2] = 12'b0;
		output_counter = 2'b0;
	end
	
	always @ (posedge clock_division_counter[24])
	begin
		if(output_counter > 2'b10)
			output_counter <= 2'b0;
		else
			output_counter <= output_counter + 1'b1;
	end
	
	
	// ---------------------------- Chip Select ---------------------------- //

	always @ (posedge enable_conversion or negedge reset)
	begin
		if(~ reset)
			adc_chip_enable	<=	1'b1;								// Active-Low Signal
			
		else if(enable_conversion)
		begin
				adc_chip_enable	<=	1'b0;
		end
	end

	// --------------------------------------------------------------------- //
	
	
	// ------------------------ Clock Division Code ------------------------ //

	/* 
	 * The ADC requires Serial Clock of 0.8 MHz to 3.2 MHz frequencies.
	 * Clock division here is for 50 MHz (from De0 Nano Board) to 3.125 MHz
	 */

	always @ (posedge clock_in or posedge adc_chip_enable) 
	begin
		if (adc_chip_enable)
			clock_division_counter <= 25'b0;
		else
			clock_division_counter <= clock_division_counter + 1'b1;
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
		if (adc_chip_enable)
			mosi <= 1'b0;
		else
		begin
			if (~ adc_serial_clk)
			begin
				case (serial_clock_counter)
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
		if (adc_chip_enable)
		begin
			data_buffer <= 12'b0;
			
			line_sensor_reading[0] <= 12'b0;
			line_sensor_reading[1] <= 12'b0;
			line_sensor_reading[2] <= 12'b0;
		end
		
		else 
		begin
			if (adc_serial_clk)
			begin
				// Receive data when Serial clock counter is greater than 3.
				if (serial_clock_counter > 4'b0011)
					data_buffer <= {data_buffer[10:0], miso};
				
				else if(serial_clock_counter == 4'b0001)
				begin
					line_sensor_reading[channel_select] <= data_buffer;
				end
				
				else 
				begin
					data_buffer <= 12'b0;
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