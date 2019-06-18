/* e-Yantra Summer Internship Programme
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * Author: Karthik K Bhat, Vishal Narkhede
 * File name: fpga_robot.v
 * Module: fpga_robot
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
 */

 
 
 /*
  * 1. Still need to optimize clock divisions.
  */
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
						input [2:0] movement_direction,
						
						output motor_left_enable, motor_right_enable, 
						output motor_left_forward, motor_left_backward,
						output motor_right_forward, motor_right_backward,
						
						// ---------------------- Test ----------------------- //
						output [7:0] leds
					  );
					  
	wire [11:0] sensor_value_2, sensor_value_1, sensor_value_0;
	assign leds = sensor_value_0[7:0];
	reg [20:0] clock_counter;
	reg[7:0] duty_cycle;
	reg increasing;
	
	initial
	begin
		duty_cycle <= 50;
		clock_counter <= 0;
		increasing <= 1;
	end
	
	adc_interface line_sensor_module(
												clock, start_bot, reset, adc_miso,
												adc_sck, adc_ce, adc_mosi, sensor_value_2, sensor_value_1, sensor_value_0
											  );
	
	display_values lcd_module(
									  clock, reset, sensor_value_0, sensor_value_1, sensor_value_2, duty_cycle,
									  lcd_data, lcd_rw, lcd_e, lcd_rs
									 );
							
	set_direction robot_direction(
											reset, movement_direction,
											motor_left_forward, motor_left_backward,
											motor_right_forward, motor_right_backward
										  );
										  
	motor_pwm right_motor(clock, reset, 255, motor_right_enable);
	motor_pwm left_motor(clock, reset, 255, motor_left_enable);
										  
	/*
	always @ (posedge clock)
	begin
			clock_counter <= clock_counter + 1'b1;
	end
	
	always @ (posedge clock_counter [20])
	begin
		if (increasing)
			duty_cycle <= duty_cycle + 1;
		else
			duty_cycle <= duty_cycle - 1;
		if (duty_cycle >= 250)
			increasing <= 0;
		if (duty_cycle <= 50)
			increasing <= 1;
	end
	*/
	
endmodule 
