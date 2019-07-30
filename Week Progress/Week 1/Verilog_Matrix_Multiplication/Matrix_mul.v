/*
* e-Yantra Summer Internship 2019
* Project Title: Robot Design using FPGA
* Author List: Vishal Narkhede, Karthik Bhat
* Project Name: 3*3 binary matrix multiplication
* Filename: Matrix_mul.v
*/


`timescale 1ns/1ns					//Setting timescale with 1ns precision

/*
* Function Name: mul
* Input: matrix_elements-> in binary array format
* Output: prints matrix multiplied array
* Logic: Matrix Multiplication include multiplication, addition and right shift
*/

module mul(clk,a,b,c); 
	input clk;
	input [8:0]a,b; 					//Initialization of input matrices as array
	
	output reg [17:0]c; 
	
	
	reg [1:0]sum; 						//Temporary register variable for multiplication 
	reg [2:0]ra[2:0]; 				//register to store input array as matrix elements		
	reg [2:0]rb[2:0]; 
	
	
	integer i1,j1,k,m ; 				//Variable for looping purpose
	
	/*
	In this initially integer and register are set to logic low and then conversion of array to matrix
	is initialized. This conversion logic includes 2 for loop which take single bit from input array &
	store it in 2D array. Both input array are converted in single condition which will save code length.
	*/
	
	
	always@(*) 
	begin									//Initial conversion of array to matrix and then matrix multiplication
		m = 1'b0;
		k = 1'b0;
		for(i1=0;i1<3;i1=i1+1) 
		begin 
			for(j1=0;j1<3;j1=j1+1) 
			begin 
				ra[i1][j1] = 1'b0;
				rb[i1][j1] = 1'b0;
				ra[i1][j1]=a[k]; 
				rb[i1][j1]=b[k];
					k = k+1;
				m = m+1;
			end 
		end 
	end
	
	always@(posedge clk)				//Output will be obtained in single clock cycle
	begin
		for(i1=0;i1<3;i1=i1+1)
		begin
			for(j1=0;j1<3;j1=j1+1)
			begin
			sum = 2'b00;
				for(k=0;k<3;k=k+1)
				begin
					sum = sum + (ra[i1][k] * rb[k][j1]);  //Output of row*column multiplication is added in temp. variable
				end
				c[1:0] = sum;									  //Append temporary to output variable
				c = {c[1:0],c[17:2]};						  //Right shift of output variable to get output same as like matrix
			end
		end
	end
	
 endmodule
	