`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:07:54 05/15/2011 
// Design Name: 
// Module Name:    queenController 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module queenController(
    input [4:0] n,
    input [1:0] outSel,
    input reset,
    output [7:0] outNum,
    input sysClk,
	 output [31:0] result,
	 input [4:0] row_query,
	 output [4:0] row_result
    );

	wire calcClk = sysClk;
	
	queens queenSolver(.clk(calcClk), .reset(reset), .n(n), .result(result), .row_query(row_query), .row_result(row_result));
	
	assign outNum = outSel[1] ? (outSel[0] ? result[31:24] : result[23:16]) : (outSel[0] ? result[15:8] : result[7:0]);
	
endmodule
