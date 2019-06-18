/* e-Yantra Summer Internship Programme
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * Author: Karthik K Bhat
 * File name: adc_interface.v
 * Module: adc_interface
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
 */
`timescale 1ns/1ps

module adc_interface(
							input clock_in,								// Clock from FPGA Board
							input enable_conversion,					// To enable A/D Conversion - Active Low
							input reset,
							input [2:0] channel_select,				// TO select one of the 8 channels

							input miso,										// From DOUT Pin in ADC (MISO)
							output reg adc_chip_enable,				// Active-low Chip Select output
							output adc_serial_clk,						// Serial Clock for ADC
							output reg mosi,								// To DIN Pin in ADC (MOSI)
							output reg [11:0] led_output,
							output [11:0] output_de2
						  ); 

	reg [4:0] clock_division_counter;	
	reg [3:0] serial_clock_counter;
	reg [11:0] digital_data_storage;

	assign adc_serial_clk = clock_division_counter[4];
	assign output_de2 = led_output;

	initial
	begin
		clock_division_counter = 5'b0;
		serial_clock_counter = 4'b0;
		digital_data_storage = 12'b0;
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
			clock_division_counter <= 5'b0;
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
			digital_data_storage <= 12'b0;
			led_output <= 12'b0;
		end
		
		else 
		begin
			if (adc_serial_clk)
			begin
				// Receive data when Serial clock counter is greater than 3.
				if (serial_clock_counter > 4'b0011)
					digital_data_storage <= {digital_data_storage[10:0], miso};
			
				else if(serial_clock_counter == 4'b0001)
					led_output <= digital_data_storage[11:0];
			end
		end
	end

	// --------------------------------------------------------------------- //

endmodule 