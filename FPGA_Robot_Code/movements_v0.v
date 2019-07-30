/* e-Yantra Summer Internship Programme
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * Author: Karthik K Bhat, Vishal Narkhede
 * File name: movements.v
 * Module: 
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
 */
 
module move_robot(
						input reset,
						input [3:0] robot_direction,
						input mode,
						
						// Motor Encoder
						input [31:0] left_motor_pulse_count, right_motor_pulse_count,
						
						// Line Sensor
						input [3:0] bot_orientation,
						
						output reg [7:0] left_motor_duty_cycle, right_motor_duty_cycle
					  );
	/*
	 * mode:
	 * 	0 -> Line Sensor
	 * 	1 -> Motor Encoder
	 * robot_direction:
	 *		0 -> Stop
	 *		1 -> Forward
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
	parameter left_base_duty_cycle = 200;
	parameter right_base_duty_cycle = 200;
	parameter lower_duty_cycle_bound = 50;
	parameter delta_duty_cycle = 10;
	parameter threshold_counts = 5;
	parameter kp = 10;

	reg [31:0] prev_left_reading, prev_right_reading;
	
	always @ (robot_direction or reset)
	begin
		prev_left_reading = left_motor_pulse_count;
		prev_right_reading = right_motor_pulse_count;
		
	end
	
	
	always 
	begin
		if (mode)
		begin
			if ((robot_direction == 3'd1) || (robot_direction == 3'd2))
			begin
				if (((left_motor_pulse_count - prev_left_reading) - (right_motor_pulse_count - prev_right_reading)) >= threshold_counts)
				begin
					if (left_motor_duty_cycle > lower_duty_cycle_bound)
						left_motor_duty_cycle <= left_motor_duty_cycle - delta_duty_cycle;
					else
						left_motor_duty_cycle <= lower_duty_cycle_bound;
				end
				
				else if (((right_motor_pulse_count - prev_right_reading) - (left_motor_pulse_count - prev_left_reading)) >= threshold_counts)
				begin
					if (right_motor_duty_cycle > lower_duty_cycle_bound)
						right_motor_duty_cycle <= right_motor_duty_cycle - delta_duty_cycle;
					else
						right_motor_duty_cycle <= right_motor_duty_cycle;
				end
				
			end
			
			else
			begin
				
			end
		end
		
		else
		begin
			if ((robot_direction == 3'd1) || (robot_direction == 3'd2))
			begin
				case (bot_orientation)
					3'd1:
					begin
						if (robot_direction == 3'b1)
						begin
							left_motor_duty_cycle <= left_base_duty_cycle - kp * delta_duty_cycle;
							right_motor_duty_cycle <= right_base_duty_cycle;
						end
						
						else
						begin
							left_motor_duty_cycle <= left_base_duty_cycle;
							right_motor_duty_cycle <= right_base_duty_cycle - kp * delta_duty_cycle;
						end
					end
					
					3'd2:
					begin
						left_motor_duty_cycle <= left_base_duty_cycle;
						right_motor_duty_cycle <= right_base_duty_cycle;
					end
					
					3'd3:
					begin
						if (robot_direction == 3'b1)
						begin
							left_motor_duty_cycle <= left_base_duty_cycle;
							right_motor_duty_cycle <= right_base_duty_cycle - kp * delta_duty_cycle;
						end
						
						else
						begin
							left_motor_duty_cycle <= left_base_duty_cycle - kp * delta_duty_cycle;
							right_motor_duty_cycle <= right_base_duty_cycle;
						end
					end
					/*
					3'd4:
					begin
						left_motor_duty_cycle <= 0;
						right_motor_duty_cycle <= 0;
					end
					
					3'd5:
					begin
						left_motor_duty_cycle <= 0;
						right_motor_duty_cycle <= 0;
					end
					
					3'd6:
					begin
						left_motor_duty_cycle <= 0;
						right_motor_duty_cycle <= 0;
					end
					
					3'd7:
					begin
						left_motor_duty_cycle <= 0;
						right_motor_duty_cycle <= 0;
					end
					*/
					default:
					begin
						left_motor_duty_cycle <= 0;
						right_motor_duty_cycle <= 0;
					end
				endcase
			end
			else if ((robot_direction == 3'd3) || (robot_direction == 3'd4))
			begin
				if (bot_orientation != 3'd2)
				begin
					left_motor_duty_cycle <= left_base_duty_cycle;
					right_motor_duty_cycle <= right_base_duty_cycle;
				end
				
				else
				begin
					left_motor_duty_cycle <= 0;
					right_motor_duty_cycle <= 0;
				end
			end
			
			else
			begin
				left_motor_duty_cycle <= 0;
				right_motor_duty_cycle <= 0;
			end
		end
	end

endmodule 