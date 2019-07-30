/* e-Yantra Summer Internship Programme
 * Project Title: Robot Design using FPGA
 * Members: Karthik K Bhat, Vishal Narkhede
 * Mentors: Simranjit Singh, Lohit Penubaku
 *
 * Author: Karthik K Bhat
 * File name: matrix_mul.mat_c
 * Functions: main
 * Global Variables: None
 * Target Device: DE0-Nano Board (EP4CE22F17C6)
*/

// -------------- Library Files -------------- //
#include "sys/alt_stdio.h"

// ------------Function Protypes ------------- //
//int dec_bin(int a);

/*
   * Function Name: main
   * Input: None
   * Return Type: int
   * Logic:
   *       >> Take matrices as 18 bit input
   *       >> Split the input and make them matrix elements
   *       >> Matrix Multiplication
   *       >> Combine the matrix elements into a single number to represent as 18 bit output
   */
int main()
{
   // -------- Variable Declaration ---------- //
   int mat_a[3][3], mat_b[3][3], mat_c[3][3];
   int i = 0, j = 0, k = 0, c = 0;
   int sum = 0, value = 0;;

   alt_printf("Enter 18 bits input");
   for (i = 0; i < 3; i ++)
   {
	   for (j = 0; j < 3; j++)
	   {
		   mat_a[i][j] = alt_getchar() - 0x30;
	   }
   }
   for (i = 0; i < 3; i ++)
   {
	   for (j = 0; j < 3; j++)
	   {
		   mat_b[i][j] = alt_getchar() - 0x30;
	   }
   }

   alt_printf("Matrix A: \n");
   for (i = 0; i < 3; i ++)
	{
		for (j = 0; j < 3; j++)
		{
		   alt_printf("%x\t", mat_a[i][j]);
		}
		alt_printf("\n");
	}
    alt_printf("Matrix B: \n");
	for (i = 0; i < 3; i ++)
	{
		for (j = 0; j < 3; j++)
		{
			alt_printf("%x\t", mat_b[i][j]);
		}
		alt_printf("\n");
	}

   alt_printf("\nMatrix C\n");
   // Loop for Matrix multiplication
   for (i = 0; i < 3; i++)
   {
      for (j = 0; j < 3; j++)
      {
         sum = 0;
         for (k = 0; k < 3; k++)
         {
            sum = sum + mat_a[i][k] * mat_b[k][j];
         }
         // Convert sum into binary
         mat_c[i][j] = sum;
         alt_printf("%x \t", mat_c[i][j]);
         c = (c<<2) + sum;
      }
      alt_printf("\n");
   }
   alt_printf("\nOutput: %x", c);
   return (0);
}
