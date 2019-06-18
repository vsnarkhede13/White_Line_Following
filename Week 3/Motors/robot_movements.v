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

module robot_movements(
							  input clock_in, reset,
							  input [2:0] robot_direction,
							  //input motor_left_a, motor_left_b,
							  //input motor_right_a, motor_right_b,
								
							  output motor_left_enable, motor_right_enable, 
							  output reg motor_left_forward, motor_left_backward,
							  output reg motor_right_forward, motor_right_backward
							 );
	
	/* Robot Directions:
	 *	0 -> Stop
	 *	1 -> Forward
	 * 2 -> Backward
	 * 3 -> Left
	 * 4 -> Right
	 */
	 
	reg [7:0] left_motor_duty_cycle = 255;
   reg [7:0] right_motor_duty_cycle = 255;
	
	always @ (robot_direction)
	begin
		case (robot_direction)
			3'd0:												// Stop Condition
			begin
				motor_left_forward <= 1'b0;
				motor_left_backward <= 1'b0;
				
				motor_right_forward <= 1'b0;
				motor_right_backward <= 1'b0;
			end	
			
			3'd1:												// Forward Condition
			begin
				motor_left_forward <= 1'b1;
				motor_left_backward <= 1'b0;
				
				motor_right_forward <= 1'b1;
				motor_right_backward <= 1'b0;
			end		
			
			3'd2:												// Backward Condition
			begin
				motor_left_forward <= 1'b0;
				motor_left_backward <= 1'b1;
				
				motor_right_forward <= 1'b0;
				motor_right_backward <= 1'b1;
			end
			
			3'd3:												// Left Condition
			begin
				motor_left_forward <= 1'b0;
				motor_left_backward <= 1'b1;
				
				motor_right_forward <= 1'b1;
				motor_right_backward <= 1'b0;
			end
			
			3'd4:												// Right Condition
			begin
				motor_left_forward <= 1'b1;
				motor_left_backward <= 1'b0;
				
				motor_right_forward <= 1'b0;
				motor_right_backward <= 1'b1;
			end
		endcase
	end
	
	
					  
endmodule

module motor_pwm(
					  input pwm_clock, reset,
					  input [1:0] direction,
					  input [7:0] duty_cycle,
						
					  output reg motor_enable
					 );
	
	reg [6:0] pwm_counter;
	
	// --------------------------- PWM Generator --------------------------- //
	
	always @ (posedge pwm_clock or negedge reset)
	begin
		if (~ reset)
		begin 
			pwm_counter <= 7'b0;
			motor_enable <= 1'b0;
		end
		
		else if (pwm_counter < 7'd100)
		begin
			pwm_counter <= pwm_counter + 1;
			motor_enable <= 1'b1;
		end
			
		else
		begin
			pwm_counter <= 7'b0;
			motor_enable <= 1'b0;
		end
			
	end
	
	// --------------------------------------------------------------------- //
	
endmodule 