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
											 
											 output reg [7:0] left_motor_duty_cycle, right_motor_duty_cycle,
											 output reg [2:0] robot_direction
											);
integer left_motor_base_dc, right_motor_base_dc, dc_variation;

initial begin
	left_motor_base_dc = 200;
	right_motor_base_dc = 200;
	dc_variation = 100;
end
											
always @ (left_sensor_reading or middle_sensor_reading or right_sensor_reading)
begin
	/*  Left Sensor on Black
    *  Center Sensor on White space
    *  Right Sensor on White space
    */
   if (left_sensor_value >= sensor_threshold &&
            center_sensor_value <= sensor_threshold &&
            right_sensor_value <= sensor_threshold)
	begin
		// Soft Right
		robot_direction <= 3'd1;
		left_motor_duty_cycle <= left_motor_base_dc;
		right_motor_duty_cycle <= right_motor_base_dc - dc_variation;
	end
			 
	/*  Left Sensor on White space
    *  Center Sensor on Black
    *  Right Sensor on White space
    */
   else if (left_sensor_value <= sensor_threshold &&
            center_sensor_value >= sensor_threshold &&
            right_sensor_value <= sensor_threshold)
	begin
		// Straight Line
		robot_direction <= 3'd1;
	end
	
	/*  Left Sensor on White space
    *  Center Sensor on White space
    *  Right Sensor on Black
    */
   else if (left_sensor_value <= sensor_threshold &&
       center_sensor_value <= sensor_threshold &&
       right_sensor_value >= sensor_threshold)
	begin
		// Soft left
		robot_direction <= 3'd1
		left_motor_duty_cycle <= left_motor_base_dc - dc_variation;
		right_motor_duty_cycle <= right_motor_base_dc;
	end
	
	/*  Left Sensor on White space
   *  Center Sensor on Black
   *  Right Sensor on Black
   */
   else if (left_sensor_value <= sensor_threshold &&
            center_sensor_value >= sensor_threshold &&
            right_sensor_value >= sensor_threshold)
	begin
		// Stop the robot
		robot_direction <= 3'd0;
	end
	
	/*  Left Sensor on Black
    *  Center Sensor on Black
    *  Right Sensor on White space
    */
   else if (left_sensor_value >= sensor_threshold &&
            center_sensor_value >= sensor_threshold &&
            right_sensor_value <= sensor_threshold)
	begin
		// Stop the robot
		robot_direction <= 3'd0;
	end
	
	/*  Left Sensor on Black
    *  Center Sensor on Black
    *  Right Sensor on Black
    */
   else if (left_sensor_value >= sensor_threshold &&
            center_sensor_value >= sensor_threshold &&
            right_sensor_value >= sensor_threshold)
	begin
		// Stop the robot
		robot_direction <= 3'd0;
		
	end
	
	/*  Left Sensor on White
    *  Center Sensor on White
    *  Right Sensor on White
    */
   else if (left_sensor_value <= sensor_threshold &&
            center_sensor_value <= sensor_threshold &&
            right_sensor_value <= sensor_threshold)
	begin
		// Stop the robot
		robot_direction <= 3'd0;
	end
		
end

endmodule 