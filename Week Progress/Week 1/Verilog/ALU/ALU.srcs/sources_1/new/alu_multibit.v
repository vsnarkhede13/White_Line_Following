`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.05.2019 12:24:15
// Design Name: 
// Module Name: alu_multibit
// Project Name: 
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


module alu_multibit(
    input[7:0] a,
    input[7:0] b,
    input c_in,
    input[2:0] op_code,
    input b_invert,
    output[7:0] results,
    output carry_out
    );
    
    // single_bit_alu - (a, b, carry_in, opcode, b_invert, result, carry_out);
    wire[6:0] carries;
    single_bit_alu b0(a, b, b_invert,   op_code, b_invert, results[0], carries[0]);
    single_bit_alu b1(a, b, carries[0], op_code, b_invert, results[1], carries[1]);
    single_bit_alu b2(a, b, carries[1], op_code, b_invert, results[2], carries[2]);
    single_bit_alu b3(a, b, carries[2], op_code, b_invert, results[3], carries[3]);
    single_bit_alu b4(a, b, carries[3], op_code, b_invert, results[4], carries[4]);
    single_bit_alu b5(a, b, carries[4], op_code, b_invert, results[5], carries[5]);
    single_bit_alu b6(a, b, carries[5], op_code, b_invert, results[6], carries[6]);
    single_bit_alu b7(a, b, carries[6], op_code, b_invert, results[7], carry_out);
    
endmodule
