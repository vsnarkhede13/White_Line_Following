/* 
 * e-Yantra Summer Internship Programme 2019
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * File name: ADC.v
 * Module: ADC
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
 */
`timescale 1ns/1ps

module ADC(
				input clock_in,								// Clock from FPGA Board
				input enable_conversion,					// To enable A/D Conversion - Active Low
				input reset,
				input [2:0] channel_select,				// TO select one of the 8 channels

				input miso,										// From DOUT Pin in ADC (MISO)
				output reg adc_chip_enable,				// Active-low Chip Select output
				output adc_serial_clk,						// Serial Clock for ADC
				output reg mosi,								// To DIN Pin in ADC (MOSI)
				output reg [11:0] reading					// To analog value
			  ); 

	// Declarations
	reg [4:0] clock_division_counter;	
	reg [3:0] serial_clock_counter;
	reg [11:0] digital_data_storage;

	
	assign adc_serial_clk = clock_division_counter[4];

	// Initializing the nets
	initial
	begin
		clock_division_counter = 5'b0;
		serial_clock_counter = 4'b0;
		digital_data_storage = 12'b0;
	end

	// ---------------------------- Chip Select ---------------------------- //

	always @ (posedge enable_conversion or negedge reset)
	begin
		// Active-Low Reset switch
		if(~ reset)
			adc_chip_enable	<=	1'b1;
		
		// Enable the ADC Chip upon depressed enabled switch
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
		// If reset is pressed, reset counter
		if (adc_chip_enable)
			clock_division_counter <= 5'b0;
		// Keep the counter running
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
		// If reset, input to ADC is 0.
		if (adc_chip_enable)
			mosi <= 1'b0;
			
		else
		begin
			// Since data is to be sent at positive edge, keep data ready when clock is low.
			if (~ adc_serial_clk)
			begin
				// Depending on the serial clock counter, send the required data.
				case (serial_clock_counter)
						// Channel select data to be sent in Big-Endian format
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
		// Reset condition
		if (adc_chip_enable)
		begin
			digital_data_storage <= 12'b0;
		end
		
		else 
		begin
			if (adc_serial_clk)
			begin
				// Receive data when Serial clock counter is greater than 3.
				if (serial_clock_counter > 4'b0011)
					// Received data in big endian format
					digital_data_storage <= {digital_data_storage[10:0], miso};
			
				else if(serial_clock_counter == 4'b0001)
					// Once all data is received, copy to reading (output)
					reading <= digital_data_storage[11:0];
			end
		end
	end

	// --------------------------------------------------------------------- //

endmodule 