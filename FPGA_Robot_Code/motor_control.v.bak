/* e-Yantra Summer Internship Programme
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * Author: Karthik K Bhat
 * File name: robot_movements.v
 * Modules: robot_movements, motor_drive
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
 */

 /* Robot Directions:
  *	0 -> Stop
  *	1 -> Forward
  * 2 -> Backward
  * 3 -> Left
  * 4 -> Right
  */
module set_direction(
							input reset,
							input [2:0] robot_direction,
							//input motor_left_a, motor_left_b,
							//input motor_right_a, motor_right_b,
							
							output reg motor_left_forward, motor_left_backward,
							output reg motor_right_forward, motor_right_backward
						  );
						  
	always @ (robot_direction or reset)
	begin
	
		if (~ reset)
		begin
			motor_left_forward <= 1'b0;
			motor_left_backward <= 1'b0;
			
			motor_right_forward <= 1'b0;
			motor_right_backward <= 1'b0;
		end
		
		else
		begin
			case (robot_direction)
				3'b001:												// Forward Condition
				begin
					motor_left_forward <= 1'b1;
					motor_left_backward <= 1'b0;
					
					motor_right_forward <= 1'b1;
					motor_right_backward <= 1'b0;
				end		
				
				3'b010:												// Backward Condition
				begin
					motor_left_forward <= 1'b0;
					motor_left_backward <= 1'b1;
					
					motor_right_forward <= 1'b0;
					motor_right_backward <= 1'b1;
				end
				
				3'b011:												// Left Condition
				begin
					motor_left_forward <= 1'b0;
					motor_left_backward <= 1'b1;
					
					motor_right_forward <= 1'b1;
					motor_right_backward <= 1'b0;
				end
				
				3'b100:												// Right Condition
				begin
					motor_left_forward <= 1'b1;
					motor_left_backward <= 1'b0;
					
					motor_right_forward <= 1'b0;
					motor_right_backward <= 1'b1;
				end
				
				default:												// Stop Condition
				begin
					motor_left_forward <= 1'b0;
					motor_left_backward <= 1'b0;
					
					motor_right_forward <= 1'b0;
					motor_right_backward <= 1'b0;
				end	
			endcase
		end
	end
	
endmodule

module motor_pwm(
					  input clock_in, reset,
					  input [7:0] duty_cycle,
						
					  output reg motor_enable
					 );
	reg [6:0] pwm_counter;
	reg [17:0] clock_division_counter;
	
	// ------------------------ Clock Division Code ------------------------ //

	/* 
	 * The ADC requires Serial Clock of 0.8 MHz to 3.2 MHz frequencies.
	 * Clock division here is for 50 MHz (from De0 Nano Board) to 3.125 MHz
	 */

	always @ (posedge clock_in or negedge reset) 
	begin
		if (~ reset)
			clock_division_counter <= 18'b0;
		else
			clock_division_counter <= clock_division_counter + 1'b1;
	end

	// --------------------------------------------------------------------- //
	
	
	// --------------------------- PWM Generator --------------------------- //
	
	always @ (posedge clock_division_counter[13] or negedge reset)
	begin
		if (~ reset)
		begin 
			pwm_counter <= 7'd0;
			motor_enable <= 1'd0;
		end
		
		else
		begin 
			pwm_counter <= pwm_counter + 1;
			motor_enable = (pwm_counter < duty_cycle)? 1:0;
			if (pwm_counter >= 7'd255)
				pwm_counter <= 7'd0;
		end
			
	end
	
	// --------------------------------------------------------------------- //
	
endmodule 



module motor_enocder(
							input reset
							input [2:0] robot_direction,
							input motor_left_a, motor_left_b,
							input motor_right_a, motor_right_b
						  );
	integer left_motor_pulse_count, right_motor_pulse_count;
	
	always @ (direction)
	begin
		left_motor_pulse_count <= 0;
		right_motor_pulse_count <= 0;
	end	

	always @ (posedge motor_left_a or negedge reset)
	begin
		if (~ reset)
			left_motor_pusle_count <= 0;
			
		else if (motor_left_b)							// Counter-Clock wise
			left_motor_pulse_count <= left_motor_pulse_count - 1;

		else if (~ motor_left_b)						// Clock wise
			left_motor_pulse_count <= left_motor_pulse_count + 1;
	end
	
	always @ (posedge motor_right_a or negedge reset)
	begin
		if (~ reset)
			right_motor_pusle_count <= 6'b0;

		else if (motor_left_b)							// Counter-Clock wise
			right_motor_pulse_count <= right_motor_pulse_count - 1;			

		else if (~ motor_left_b)						// Clock wise
			right_motor_pulse_count <= right_motor_pulse_count + 1;
	end 
	
endmodule 