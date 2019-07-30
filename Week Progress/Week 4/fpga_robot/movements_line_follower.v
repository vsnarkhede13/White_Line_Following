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
	 * robot_direction:
	 * 	0 -> Stop
	 * 	1 -> Forward
	 * 	2 -> Backward
	 * 	3 -> Left
	 * 	4 -> Right
	 * bot_orientation:
	 * 	1 -> Soft Left
	 * 	2 -> On-Line
	 * 	3 -> Soft Right
	 * 	4 -> Right Node
	 * 	5 -> Left Node
	 * 	6 -> T-Node
	 * 	7 -> White space
	 */
	parameter left_base_duty_cycle = 120;			//225
	parameter right_base_duty_cycle = 85;		gh	// 155
	parameter low_duty_cycle = 60;
	
	/* 
	 * 0 - Left
	 * 1 - Right
	 */
	reg last_line_orientation;
	
	//reg [15:0] prev_left_reading, prev_right_reading;
	reg start_bot;
	
	initial
	begin
	   start_bot = 0;
		last_line_orientation = 0;
		robot_direction = 1;
	end
	
	always @ (posedge enable or negedge reset)
	begin
	   if (~ reset)
	       start_bot <= 0;
	   else if (enable)
	       start_bot <= 1;
	end
	
	always @ (posedge clock)
	begin
	if (start_bot)
	begin
		if (mode == 0)		// Line Sensor Based Movements
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
				last_line_orientation <= 1;
				robot_direction <= 3'd4;
				left_motor_duty_cycle <= left_base_duty_cycle;
				right_motor_duty_cycle <= right_base_duty_cycle;
			end
			
			// Hard Left 
			3'd5:
			begin
				last_line_orientation <= 0;
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
				
				else
				begin
					robot_direction <= 3'd3;
					left_motor_duty_cycle <= left_base_duty_cycle;
					right_motor_duty_cycle <= right_base_duty_cycle;
				end
			end
			
		endcase
		end
	end
	else
	begin
		left_motor_duty_cycle <= 0;
		right_motor_duty_cycle <= 0;
	end
end

endmodule 