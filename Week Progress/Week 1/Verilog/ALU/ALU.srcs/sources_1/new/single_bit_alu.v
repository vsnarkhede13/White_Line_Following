`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: e-Yantra
// Engineer: Karthik K Bhat
// 
// Create Date: 24.05.2019 11:05:21
// Design Name: Single Bit Basic ALU
// Module Name: single_bit_alu
// Project Name: ALU
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module single_bit_alu(
    input a,
    input b,
    input carry_in,
    input[1:0] opcode,
    input b_invert,
    output reg result,
    output reg carry_out
    );
    
    reg b_value;

    always @ (*)
    begin
        if (b_invert == 1)
            b_value = ~b;
            
        case (opcode)
            2'b00:
                begin
                    result = a & b_value;
                    carry_out = 0; 
                end
            2'b01:
                begin
                    result = a | b_value;
                    carry_out = 0;
                end
            2'b10:
                begin
                    {result, carry_out} = a + b + carry_in;
                end
        endcase
    end   
endmodule
