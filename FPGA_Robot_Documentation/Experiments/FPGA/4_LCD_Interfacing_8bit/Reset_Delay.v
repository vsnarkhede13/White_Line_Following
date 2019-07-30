/* 
 * e-Yantra Summer Internship Programme 2019
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * File name: Reset_Delay.v
 * Module: Reset_Delay
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
 */
 
module	Reset_Delay(
							iCLK,
							oRESET,
							iRST_n
							);
	
	input		iCLK;					// Clock from FPGA
	input		iRST_n;				// Reset switch command
	output reg	oRESET;			// Output of reset switch command
	reg	[19:0]	Cont;

	always@(posedge iCLK)
	begin
		if(Cont!=20'hFFFFF)
		begin
			Cont	<=	Cont+1;
			oRESET	<=	1'b0;
		end
		else
		oRESET	<=	iRST_n;
	end

endmodule