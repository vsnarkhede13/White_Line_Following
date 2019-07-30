//////////////////////////////////////////////////////////////////////////////////
// e-Yantra Summer Internship Programme
// Project Title: Robot Design using FPGA
// Members: Karthik K Bhat, Vishal Narkhede
// Mentors: Simranjit Singh, Lohit Penubaku
//
// Design Name: fpga_robot.v
// Module Name: fpga_robot
// Target Devices: EP4CE22F17C6 (DE0-Nano Board)
// Tool Versions: Quartus Prime 18.1 Lite
// Description: 
//
// Dependencies: 
// 	1. adc_interface.v
// 	2.	display_values.v
// 	3. motor_control.v
// 	4. get_robot_orientation.v
// 	5. movements.v
//  
// Comments:
// 	1. Need to optimize clocks in modules
//////////////////////////////////////////////////////////////////////////////////

module fpga_robot(
						input clock,
						
						input start_bot,
						input reset,

						// ----------------------- ADC ----------------------- //
						input adc_miso,
						output adc_sck,
						output adc_ce,
						output adc_mosi,
						
						// --------------------- Display --------------------- //
						
						output lcd_rs, lcd_rw, lcd_e,
						output [7:0] lcd_data,
						
						// --------------------- Motors ---------------------- //
						
						input motor_left_a, motor_left_b,
						input motor_right_a, motor_right_b,
						//input [2:0] movement_direction,
						input mode,
						
						output motor_left_enable, motor_right_enable, 
						output motor_left_forward, motor_left_backward,
						output motor_right_forward, motor_right_backward,
						
						// ---------------------- Test ----------------------- //
						output [7:0] leds
					  );
	
	wire [2:0] movement_direction;
	wire [11:0] sensor_value_2, sensor_value_1, sensor_value_0;
	wire [7:0] left_motor_velocity, right_motor_velocity;	
	wire [7:0] left_motor_duty_cycle, right_motor_duty_cycle;
	wire [3:0] bot_orientation;
	
	//assign leds = sensor_value_1[11:4];
	
	reg [15:0] clock_division_counter;
	
	// ------------------------ Clock Division Code ------------------------ //
	
	initial 
	begin
		clock_division_counter <= 0;
	end

	always @ (posedge clock or negedge reset) 
	begin
		if (~ reset)
			clock_division_counter <= 4'b0;
		else
			clock_division_counter <= clock_division_counter + 1'b1;
	end

	// --------------------------------------------------------------------- //
	
	adc_interface line_sensor_module(
												clock_division_counter[4], start_bot, reset, adc_miso,
												adc_sck, adc_ce, adc_mosi, sensor_value_0, sensor_value_2, sensor_value_1
											  );
	
	display_values lcd_module(
									  clock, reset, sensor_value_0, sensor_value_1, sensor_value_2,
									  0, movement_direction, bot_orientation,
									  lcd_data, lcd_rw, lcd_e, lcd_rs
									 );
							
	set_direction robot_movement_direction(
														reset, movement_direction,
														motor_left_forward, motor_left_backward,
														motor_right_forward, motor_right_backward
													  );
	
	motor_encoder left_motor_encoder(
												clock_division_counter[3], reset,
												motor_left_a, motor_left_b,
												left_motor_velocity			
											  );
									  
	motor_encoder right_motor_encoder(
												 clock_division_counter[3], reset,
												 motor_right_a, motor_right_b,
												 right_motor_velocity						
												);
									  
	get_robot_orientation line_orientation(
														sensor_value_2, sensor_value_1, sensor_value_0,
														bot_orientation
													  );
																	
	
	move_robot line_encoder(
								   clock_division_counter[15], reset, start_bot,
									0,//mode, 
								   left_motor_velocity, right_motor_velocity, bot_orientation,
								   movement_direction, left_motor_duty_cycle, right_motor_duty_cycle
								  );
	
	
	motor_pwm left_motor(
								clock_division_counter[12], reset,
								left_motor_duty_cycle, motor_left_enable
							  );
							  
	motor_pwm right_motor(
								 clock_division_counter[12], reset,
								 right_motor_duty_cycle, motor_right_enable
								);
		
endmodule 
