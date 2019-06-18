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
 
module robot_movement_line_sensor(
											 input [11:0] left_sensor_reading,
											 input [11:0] middle_sensor_reading,
											 input [11:0] right_sensor_reading,
											 
											 output reg [3:0] bot_orientation;
											);
											
reg [7:0] sensor_threshold;

initial begin
	bot_orientation = 3'd2;
	sensor_threshold = 150;
end
/*
 * Bot position:
 * 1. Soft Left
 * 2. On-Line
 * 3. Soft Right
 * 4. Right Node
 * 5. Left Node
 * 6. T-Node
 * 7. White space
 */											
always @ (left_sensor_reading or middle_sensor_reading or right_sensor_reading)
	begin
		//  Left Sensor: Black, Center Sensor: White, Right Sensor: White
		if (left_sensor_reading >= sensor_threshold &&
			 middle_sensor_reading <= sensor_threshold &&
			 right_sensor_reading <= sensor_threshold)
		begin
			// Soft Left
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
		
		// Left Sensor: White, Center Sensor: White, Right Sensor: Black
		else if (left_sensor_reading <= sensor_threshold &&
					middle_sensor_reading <= sensor_threshold &&
					right_sensor_reading >= sensor_threshold)
		begin
			// Soft right
			bot_orientation <= 3'd3;
		end
		
		// Left Sensor: White, Center Sensor: Black, Right Sensor: Black
		else if (left_sensor_reading <= sensor_threshold &&
					middle_sensor_reading >= sensor_threshold &&
					right_sensor_reading >= sensor_threshold)
		begin
			// Stop the robot
			bot_orientation <= 3'd4;
		end
		
		// Left Sensor: Black, Center Sensor: Black, Right Sensor: White
		else if (left_sensor_reading >= sensor_threshold &&
					middle_sensor_reading >= sensor_threshold &&
					right_sensor_reading <= sensor_threshold)
		begin
			// Stop the robot
			bot_orientation <= 3'd5;
		end
		
		// Left Sensor: Black, Center Sensor: Black, Right Sensor: Black
		else if (left_sensor_reading >= sensor_threshold &&
					middle_sensor_reading >= sensor_threshold &&
					right_sensor_reading >= sensor_threshold)
		begin
			// Stop the robot
			bot_orientation <= 3'd6;
		end
		
		// Left Sensor: White, Center Sensor: White, Right Sensor: White
		else if (left_sensor_reading <= sensor_threshold &&
					middle_sensor_reading <= sensor_threshold &&
					right_sensor_reading <= sensor_threshold)
		begin
			// Stop the robot
			bot_orientation <= 3'd7;
		end
			
	end

endmodule 