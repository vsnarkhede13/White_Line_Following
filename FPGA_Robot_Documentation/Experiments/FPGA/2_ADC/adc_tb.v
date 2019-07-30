`timescale 1ns/1ps

module adc_test_bench();

reg clock, enable, reset, miso;
wire adc_enable, adc_clk;
wire [11:0] digital_data;
wire [3:0] serial_clk_counter;

line_sensor_interface dut(clock, enable, reset,
								  miso, adc_enable, adc_clk,	mosi);

initial begin
	clock = 0;
	enable = 0;
	reset = 0;
	miso = 0;
end

always #10 clock = ~ clock;

initial begin
	#50
		enable = 1; 
		reset = 1;
							// 1
		miso = 0;
	#40					// 2 
		miso = 0;
	#40					// 3
		miso = 0;
	#80					// 4
	//1101 1010 0111
		miso = 1;					// Start of 1st Bit
	#40					// 5
		miso = 1;
	#40					// 6
		miso = 0;
	#40					// 7
		miso = 1;
	#40					// 8
		miso = 1;
	#40					// 9
		miso = 0;
	#40					// 10
		miso = 1;
	#40					// 11
		miso = 0;
	#40					// 12
		miso = 0;
	#40					// 13
		miso = 1;
	#40					// 14
		miso = 1;
	#40					// 15
		miso = 1;					// End of 12th Bit
	#40					// 16
		miso = 0;
	// ----------------------------------- //
	#40
		miso = 0;
	#40					// 2 
		miso = 0;
	#40					// 3
		miso = 0;
	#80					// 4
	//1011 0010 0111
		miso = 1;					// Start of 1st Bit
	#40					// 5
		miso = 0;
	#40					// 6
		miso = 1;
	#40					// 7
		miso = 1;
	#40					// 8
		miso = 0;
	#40					// 9
		miso = 0;
	#40					// 10
		miso = 1;
	#40					// 11
		miso = 0;
	#40					// 12
		miso = 0;
	#40					// 13
		miso = 1;
	#40					// 14
		miso = 1;
	#40					// 15
		miso = 1;					// End of 12th Bit
	#40					// 16
		miso = 0;
	
	// ----------------------------------- //
	#40
		miso = 0;
	#40					// 2 
		miso = 0;
	#40					// 3
		miso = 0;
	#80					// 4
	//0110 1010 1101
		miso = 0;					// Start of 1st Bit
	#40					// 5
		miso = 1;
	#40					// 6
		miso = 1;
	#40					// 7
		miso = 0;
	#40					// 8
		miso = 1;
	#40					// 9
		miso = 0;
	#40					// 10
		miso = 1;
	#40					// 11
		miso = 0;
	#40					// 12
		miso = 1;
	#40					// 13
		miso = 1;
	#40					// 14
		miso = 0;
	#40					// 15
		miso = 1;					// End of 12th Bit
	#40					// 16
		miso = 0;
end 

endmodule 