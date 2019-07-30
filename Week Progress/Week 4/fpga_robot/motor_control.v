//////////////////////////////////////////////////////////////////////////////////
// e-Yantra Summer Internship Programme
// Project Title: Robot Design using FPGA
// Members: Karthik K Bhat, Vishal Narkhede
// Mentors: Simranjit Singh, Lohit Penubaku
//
// Design Name: motor_control.v
// Module Name: 1. set_direction
//					 2. motor_pwm
//					 3. motor_encoder
// Target Devices: EP4CE22F17C6 (DE0-Nano Board)
// Tool Versions: Quartus Prime 18.1 Lite
// Description:
// 
// Dependencies:
//
// Comments:
//
//////////////////////////////////////////////////////////////////////////////////

/* 
 * Module: set_direction
 * Purpose: To set the direction of rotation of the motors of the robots using the H-Bridge inputs.
 * Inputs: reset, robot directions
 * Ouputs: H-bridge direction inputs (IN1, IN2, IN3, IN4) for 2 motors.
 */
  
module set_direction(
							input reset,
							input [2:0] robot_direction,
							
							output reg motor_left_forward, motor_left_backward,
							output reg motor_right_forward, motor_right_backward
						  );
	/* 
	 * robot_direction:
    *		0 -> Stop
    *		1 -> Forward
    * 	2 -> Backward
    * 	3 -> Left
    * 	4 -> Right
    */					  
	always @ (robot_direction or reset)
	begin
		// Asynchronous reset. Switch set all outputs to low. Motors are stopped.
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


/* 
 * Module: motor_pwm
 * Purpose: To generate PWM signal. To control the speed of the motors through the enable pin of the H-Bridge.
 * Inputs: Reset, Clock (of PWM frequency), duty cycle (8-bit) 
 * Ouputs: PWM signal
 */

module motor_pwm(
					  input clock_in, reset,
					  input [7:0] duty_cycle,
						
					  output reg motor_enable
					 );
	reg [7:0] pwm_counter;

	// To switch off the motor initially
	initial 
	begin
		motor_enable = 0;
	end	
	
	// --------------------------- PWM Generator --------------------------- //
	always @ (posedge clock_in or negedge reset)
	begin
		// Synchronous reset, Reset the pwm counter and set the output to low.
		if (~ reset)
		begin 
			pwm_counter <= 8'd0;
			motor_enable <= 1'd0;
		end
		
		else
		begin
			// Keep incrementing the pwm counter at every positive edge of the clock.
			pwm_counter <= pwm_counter + 1;
			// Set the output to high when pwm counter is less than the duty cycle
			motor_enable = (pwm_counter < duty_cycle)? 1:0;
		end
			
	end
	
	// --------------------------------------------------------------------- //
	
endmodule 


/* 
 * Module: motor_encoder
 * Purpose: To get the input of the motor encoders and return the velocity of the motors.
 * Inputs: Reset, Clock (3 MHz), Motor encoder pins
 * Ouputs: Angular velocity of the motor (8-pin)
 */

module motor_encoder(
							input clock_in, reset,
							input motor_a, motor_b,
							output reg [7:0] motor_angular_velocity					
						  );
	
	reg velocity_updated;					// Flag for velocity updation
	reg [9:0] motor_pulse_count;			// Counter for pulse counts
	reg [11:0] clock_counter;				// Counter for sampling time
	
	// Set all the nets and output to low
	initial
	begin
	   motor_pulse_count = 0;
		clock_counter = 0;
		motor_angular_velocity = 0;
		velocity_updated = 1;
	end
	
	// For calculation of Motor Velocity.
	always @ (posedge clock_in or negedge reset)							// 3 MHz Clock
	begin
		// Synchronous Reset. Set all the flags to initial state
		if (~ reset)
		begin
			clock_counter <= 0;
			velocity_updated <= 1;
		end
		
		else
		begin
			// 
			clock_counter <= clock_counter + 1;
			// 1.11 ms sampling time - Counter = 3,333
			if (clock_counter == 3332)										
			begin
				// In Rotations per minute
				// RPM = ((motor_pulse_count / 540) * (60 / sampling_time_in_seconds))
				motor_angular_velocity <= (motor_pulse_count);
				velocity_updated <= 1;
			end
			
			// After updating the velocity, reset the counter and flag
			else if (clock_counter > 3333)
			begin
				velocity_updated <= 0;
				clock_counter <= 0;
			end
		end
			
	end

	// Quadrature motor encoder 1X method decoding
	always @ (posedge motor_a or posedge velocity_updated or negedge reset)
	begin
		// Asynchronous reset. Set the motor encoder pulse count to zero when reset is pressed or flag is set
		if ((~ reset) || velocity_updated)
			motor_pulse_count <= 0;
		else 
			// keep incrementing the counter.
			motor_pulse_count <= motor_pulse_count + 1;
	end
	
	
	
endmodule 