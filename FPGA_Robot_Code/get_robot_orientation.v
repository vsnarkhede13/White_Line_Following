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
 
/* 
 * Module: get_robot_orientation
 * Purpose: To obtain the orientation of the robot on the line using the line sensor readings
 * Inputs: Sensor readings - Left, Middle, Right
 * Ouputs: Bot orientation
 */
 
module get_robot_orientation(
									  input [11:0] left_sensor_reading,
									  input [11:0] middle_sensor_reading,
									  input [11:0] right_sensor_reading,
									 
									  output reg [3:0] bot_orientation
									 );
	/*
	 * bot_orientation:
	 * 1. Soft Left
	 * 2. On-Line
	 * 3. Soft Right
	 * 4. Right Node
	 * 5. Left Node
	 * 6. T-Node
	 * 7. White space
	 */	
	
	// Parameter declaration. Based on the testing.
	parameter sensor_threshold = 2000;

	initial begin
		bot_orientation = 3'd2;
	end
	
	
	always @ (*)
	begin
		
		// Left Sensor: Black, Center Sensor: Black, Right Sensor: White
		if (left_sensor_reading >= sensor_threshold &&
			 middle_sensor_reading >= sensor_threshold &&
			 right_sensor_reading <= sensor_threshold)
		begin
			// Hard Left
			bot_orientation <= 3'd1;
		end
						 
		// Left Sensor: White, Center Sensor: Black, Right Sensor: White
		else if (left_sensor_reading <= sensor_threshold &&
					middle_sensor_reading >= sensor_threshold &&
					right_sensor_reading <= sensor_threshold)
		begin
			// Straight Line
			bot_orientation <= 3'd2;
		end
		
		// Left Sensor: White, Center Sensor: Black, Right Sensor: Black
		else if (left_sensor_reading <= sensor_threshold &&
					middle_sensor_reading >= sensor_threshold &&
					right_sensor_reading >= sensor_threshold)
		begin
			// Hard Right
			bot_orientation <= 3'd3;
		end
		
		// Left Sensor: White, Center Sensor: White, Right Sensor: Black
		else if (left_sensor_reading <= sensor_threshold &&
					middle_sensor_reading <= sensor_threshold &&
					right_sensor_reading >= sensor_threshold)
		begin
			// Soft right
			bot_orientation <= 3'd4;
		end
		
		//  Left Sensor: Black, Center Sensor: White, Right Sensor: White
		else if (left_sensor_reading >= sensor_threshold &&
			 middle_sensor_reading <= sensor_threshold &&
			 right_sensor_reading <= sensor_threshold)
		begin
			// Soft Left
			bot_orientation <= 3'd5;
		end
		
		// Left Sensor: Black, Center Sensor: Black, Right Sensor: Black
		else if (left_sensor_reading >= sensor_threshold &&
					middle_sensor_reading >= sensor_threshold &&
					right_sensor_reading >= sensor_threshold)
		begin
			// Stop
			bot_orientation <= 3'd6;
		end
		
		// Left Sensor: White, Center Sensor: White, Right Sensor: White
		else if (left_sensor_reading <= sensor_threshold &&
					middle_sensor_reading <= sensor_threshold &&
					right_sensor_reading <= sensor_threshold)
		begin
			// Start Rotating
			bot_orientation <= 3'd7;
		end
			
	end

endmodule 