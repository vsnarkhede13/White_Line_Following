/* 
 * e-Yantra Summer Internship Programme 2019
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * File name: dec2hex.v
 * Module: dec2hex
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
 */
 
module dec2hex(
					input [11:0] count,  				// 12 bit decimal value
					output reg [8:0] th,h,t,u			// 9 bit value of thousand, hundread, tens and unit place with RS concatenated.
					);
					
	reg [7:0] th1,h1,t1,u1;
	// --------------------------------------------------------------------- //
	always@(*) 
		begin
			th1=(count/1000);								// Calulation of thousands place
			h1=(count/100)%10;							// Calulation of hundread place
			t1=(count/10)%10;								// Calulation of tens place
			u1=count%10;									// Calulation of unit place
			th={1'b1,(th1+8'h30)};
			h={ 1'b1,(h1+8'h30)};
			t={ 1'b1,(t1+8'h30)};
			u={ 1'b1,(u1+8'h30)};
		end
endmodule
