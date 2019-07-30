//////////////////////////////////////////////////////////////////////////////////
// e-Yantra Summer Internship Programme
// Project Title: Robot Design using FPGA
// Members: Karthik K Bhat, Vishal Narkhede
// Mentors: Simranjit Singh, Lohit Penubaku
//
// Design Name: movements.v
// Module Name: move_robot
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
 * Module: move_robot
 * Purpose: To control the movements of the robot based on either the motor encoder or line sensor inputs
 * Inputs: Reset, Clock, Enable, Movement Mode, Motor velocities, Robot Orientation on line
 * Ouputs: Robot Movement Direction, Left and right motor duty cycles.
 */

module move_robot(
                  input clock,
						input reset, enable,
						
						input mode,
						
						// Motor Encoder
						input [7:0] left_motor_velocity, right_motor_velocity,
						
						// Line Sensor
						input [3:0] bot_orientation,
						output reg [3:0] robot_direction,
						output reg [7:0] left_motor_duty_cycle, right_motor_duty_cycle
					  );
	/*
	 * mode:
	 * 	0 -> Line Sensor
	 * 	1 -> Motor Encoder
	 *
	 * robot_direction:
	 * 	0 -> Stop
	 * 	1 -> Forward
	 * 	2 -> Backward
	 * 	3 -> Left
	 * 	4 -> Right
	 *
	 * bot_orientation:
	 * 	1 -> Soft Left
	 * 	2 -> On-Line
	 * 	3 -> Soft Right
	 * 	4 -> Right Node
	 * 	5 -> Left Node
	 * 	6 -> T-Node
	 * 	7 -> White space
	 */
	 
	// Parameter declaration
	parameter left_base_duty_cycle = 120;			//225
	parameter right_base_duty_cycle = 85;			// 155
	parameter low_duty_cycle = 60;
	
	parameter threshold_difference = 40;
	parameter left_low_duty_cycle = 60;
	parameter right_low_duty_cycle = 43;
	parameter delta_duty_cycle = 5;
	
	/* 
	 * Last Line orientation
	 * 	0 - Left
	 * 	1 - Right
	 */
	reg last_line_orientation;
	
	// Enable control for movements
	reg start_bot;
	
	// Set the initial conditions for all the nets
	initial
	begin
	   start_bot = 0;
		last_line_orientation = 0;
		robot_direction = 0;
		left_motor_duty_cycle = 0;
		right_motor_duty_cycle = 0;
	end
	
	// Robot movement enable condition
	always @ (posedge enable or negedge reset)
	begin
		// Asynchronous reset. Reset all nets and ouputs
	   if (~ reset)
		begin
			start_bot <= 0;
		end
	 
	   else if (enable)
		begin
			start_bot <= 1;
		end 
	end
	
	
	// Forever loop
	always @ (posedge clock)
	begin
	// If enabled (start_bot is high)
	if (start_bot)
	begin
		// Motor encoder based movements.
		if (mode == 1)
		begin
			// Left motor velocity is faster (w.r.t Threshold)
			if ((left_motor_velocity - right_motor_velocity)  > threshold_difference)
			begin
				right_motor_duty_cycle <= right_base_duty_cycle;
				if (left_motor_duty_cycle > left_low_duty_cycle)
					left_motor_duty_cycle <= left_motor_duty_cycle - delta_duty_cycle;
				else
					left_motor_duty_cycle <= left_low_duty_cycle;
			end

			// Right motor velocity is faster (w.r.t Threshold)
			else if ((right_motor_velocity - left_motor_velocity) > threshold_difference)
			begin
				left_motor_duty_cycle <= left_base_duty_cycle;
				if (right_motor_duty_cycle > right_low_duty_cycle)
					right_motor_duty_cycle <= right_motor_duty_cycle - delta_duty_cycle;
				else
					right_motor_duty_cycle <= right_low_duty_cycle;
			end

			// If the velocities are in threshold region, move straight
			else
			begin
				left_motor_duty_cycle <= left_base_duty_cycle;
				right_motor_duty_cycle <= right_base_duty_cycle;
			end
		end
		
		// Line Sensor Based Movements
		else if (mode == 0)		
		begin
		
			case (bot_orientation)
								
			// Straight Line
			3'd2:
			begin
				robot_direction <= 3'd1;
				left_motor_duty_cycle <= left_base_duty_cycle;
				right_motor_duty_cycle <= right_base_duty_cycle;
			end

			
			// Hard Right
			3'd4:
			begin
				last_line_orientation <= 1;							// If lost, turn from last unkown orientation (Right)
				robot_direction <= 3'd4;
				left_motor_duty_cycle <= left_base_duty_cycle;
				right_motor_duty_cycle <= right_base_duty_cycle;
			end
			
			// Hard Left 
			3'd5:
			begin
				last_line_orientation <= 0;							// If lost, turn from last unkown orientation (Left)
				robot_direction <= 3'd3;
				left_motor_duty_cycle <= left_base_duty_cycle;
				right_motor_duty_cycle <= right_base_duty_cycle;
			end
			
			// Move straight
			3'd6:
			begin
				 robot_direction <= 3'd1;
				 left_motor_duty_cycle <= left_base_duty_cycle;
				 right_motor_duty_cycle <= right_base_duty_cycle;
			end
			
			3'd7:
			begin
				robot_direction <= 3'd1;
				if (last_line_orientation)									// Turn Right
				begin
					left_motor_duty_cycle <= left_base_duty_cycle;
					right_motor_duty_cycle <= low_duty_cycle;
				end
				else
				begin
					left_motor_duty_cycle <= low_duty_cycle;
					right_motor_duty_cycle <= right_base_duty_cycle;				
				end
			end
			
			// Find Line
			default:
			begin
				if (last_line_orientation)									// Turn Right
				begin
				  robot_direction <= 3'd4;
				  left_motor_duty_cycle <= left_base_duty_cycle;
				  right_motor_duty_cycle <= right_base_duty_cycle;
				end
				
				else																// Turn Left
				begin
					robot_direction <= 3'd3;
					left_motor_duty_cycle <= left_base_duty_cycle;
					right_motor_duty_cycle <= right_base_duty_cycle;
				end
			end
			
		endcase
		end
	end
	
	// If enable (start_bot) is low
	else
	begin
		left_motor_duty_cycle <= 0;
		right_motor_duty_cycle <= 0;
	end
end

endmodule 