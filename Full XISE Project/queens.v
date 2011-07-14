`timescale 1ns / 1ps

module queens(
	input clk,
	input reset,
	input [4:0] n,
	output reg [31:0] result,
	input [4:0] row_query,
	output [4:0] row_result
    );

	parameter N = 31;
	parameter N2 = 63;
	parameter logN = 4;
	parameter logN2 = 5;
	//parameter n = 9;
	reg [logN:0] column; //3:0
	reg [logN:0] row [N:0]; //3:0 and 15:0
	reg [N:0] Rused; //15:0
	reg [N2:0] D1used; //31:0
	reg [N2:0] D2used; //31:0
	//reg [N2:0] result; //31:0
	reg finished;

	reg [logN:0] first_solution [N:0]; //3:0 and 15:0
	reg first_solution_found;


	//next state logic for the FSM
	wire [logN:0] currow = row[column];
	wire backward_needed = (currow == n) || (column == n); //if hit the end or all possibilities tried
	wire [logN2:0] D1_check = currow + column;
	wire [logN2:0] D2_check = n+column-currow;
	wire forward_possible = (~(Rused[currow] || D1used[D1_check] || D2used[D2_check])) && ~backward_needed;
	wire solution_found = (column == n);
	
	wire [31:0] next_result = solution_found ? result+1 : result;
	wire [logN:0] next_currow = (currow == n) ? 0 : currow + 1;
	wire [logN:0] next_column = forward_possible ? column+1 : (backward_needed ? column-1 : column);
	wire next_finished = backward_needed && (column == 0); //(~(result == 0)) && (currow == 0) && (column == 0);
	
	//choose correct row to set or delete an used row
	// if forward move in progress => set next_currow to 1
	// if backward move in progress => set row[next_column]-1 to 0 //the row where the last queen was set
	// else set R[n] to anything
	wire edit_needed = forward_possible || backward_needed;
	//editing indices in case of any change
	wire [logN:0] edit_column = forward_possible ? column : next_column; //column-1 in case of backward move
	wire [logN:0] edit_row = forward_possible ? currow : row[next_column]-1; //row[next_column]-1 in case of backward move
	wire edit_value = forward_possible ? 1 : 0;
	
	wire [logN:0] R_index = edit_needed ? edit_row : n; //unused row n;
	wire [logN2:0] D1_index = edit_needed ? (edit_row + edit_column) : N2; //unused Diagonal N2
	wire [logN2:0] D2_index = edit_needed ? (n + edit_column - edit_row) : N2; //unused Diagonal N2
	
	//state transition of the FSM
	always @ (posedge clk, posedge reset)
	begin
		if(reset)
		begin
			result <= 0;
			Rused <= 0;
			D1used <= 0;
			D2used <= 0;
			row[0] <= 0; row[1] <= 0; row[2] <= 0; row[3] <= 0; row[4] <= 0; row[5] <= 0; row[6] <= 0; row[7] <= 0;
			row[8] <= 0; row[9] <= 0; row[10] <= 0; row[11] <= 0; row[12] <= 0; row[13] <= 0; row[14] <= 0; row[15] <= 0;
			row[16] <= 0; row[17] <= 0; row[18] <= 0; row[19] <= 0; row[20] <= 0; row[21] <= 0; row[22] <= 0; row[23] <= 0;
			first_solution[0] <= 0; first_solution[1] <= 0; first_solution[2] <= 0; first_solution[3] <= 0; first_solution[4] <= 0; first_solution[5] <= 0; first_solution[6] <= 0; first_solution[7] <= 0;
			first_solution[8] <= 0; first_solution[9] <= 0; first_solution[10] <= 0; first_solution[11] <= 0; first_solution[12] <= 0; first_solution[13] <= 0; first_solution[14] <= 0; first_solution[15] <= 0;
			first_solution[16] <= 0; first_solution[17] <= 0; first_solution[18] <= 0; first_solution[19] <= 0; first_solution[20] <= 0; first_solution[21] <= 0; first_solution[22] <= 0; first_solution[23] <= 0;
			first_solution_found <= 0;
			column <= 0;
			finished <= 0;
		end
		else
		begin
			if(~finished)
			begin
				//assign next state of the FSM
				result <= next_result;
				row[column] <= next_currow;
				column <= next_column;
				Rused[R_index] <= edit_value;
				D1used[D1_index] <= edit_value;
				D2used[D2_index] <= edit_value;
				finished <= next_finished;
				if(solution_found && ~first_solution_found)
				begin
					first_solution[0] <= row[0]; first_solution[1] <= row[1]; first_solution[2] <= row[2]; first_solution[3] <= row[3];
					first_solution[4] <= row[4]; first_solution[5] <= row[5]; first_solution[6] <= row[6]; first_solution[7] <= row[7];
					first_solution[8] <= row[8]; first_solution[9] <= row[9]; first_solution[10] <= row[10]; first_solution[11] <= row[11];
					first_solution[12] <= row[12]; first_solution[13] <= row[13]; first_solution[14] <= row[14]; first_solution[15] <= row[15];
					first_solution[16] <= row[16]; first_solution[17] <= row[17]; first_solution[18] <= row[18]; first_solution[19] <= row[19];
					first_solution[20] <= row[20]; first_solution[21] <= row[21]; first_solution[22] <= row[22]; first_solution[23] <= row[23];
					first_solution_found <= 1;
				end
			end
		end
	end
	
	//assign row_result to display the queen in this column
	assign row_result = finished ? first_solution[row_query] : row[row_query];
	
	/*
	wire [logN:0] r0 = row[0];
	wire [logN:0] r1 = row[1];
	wire [logN:0] r2 = row[2];
	wire [logN:0] r3 = row[3];
	wire [logN:0] r4 = row[4];
	wire [logN:0] r5 = row[5];
	wire [logN:0] r6 = row[6];
	wire [logN:0] r7 = row[7];
	
	wire Ru0 = Rused[0];
	wire Ru1 = Rused[1];
	wire Ru2 = Rused[2];
	wire Ru3 = Rused[3];
	wire Ru4 = Rused[4];
	wire Ru5 = Rused[5];
	wire Ru6 = Rused[6];
	wire Ru7 = Rused[7];

	wire D1u0 = D1used[0];	
	wire D1u1 = D1used[1];	
	wire D1u2 = D1used[2];	
	wire D1u3 = D1used[3];	
	wire D1u4 = D1used[4];	
	wire D1u5 = D1used[5];	
	wire D1u6 = D1used[6];	
	wire D1u7 = D1used[7];	
	wire D1u8 = D1used[8];	
	wire D1u9 = D1used[9];	
	wire D1u10 = D1used[10];	
	wire D1u11 = D1used[11];	
	wire D1u12 = D1used[12];	
	wire D1u13 = D1used[13];	
	wire D1u14 = D1used[14];	
	wire D1u15 = D1used[15];	

	wire D2u0 = D2used[0];	
	wire D2u1 = D2used[1];	
	wire D2u2 = D2used[2];	
	wire D2u3 = D2used[3];	
	wire D2u4 = D2used[4];	
	wire D2u5 = D2used[5];	
	wire D2u6 = D2used[6];	
	wire D2u7 = D2used[7];	
	wire D2u8 = D2used[8];	
	wire D2u9 = D2used[9];	
	wire D2u10 = D2used[10];	
	wire D2u11 = D2used[11];	
	wire D2u12 = D2used[12];	
	wire D2u13 = D2used[13];	
	wire D2u14 = D2used[14];	
	wire D2u15 = D2used[15];	

  initial
     $monitor("c%d r%d fwd%d, bwd%d, R (%d,%d,%d,%d,%d,%d,%d,%d), Rused (%d,%d,%d,%d,%d,%d,%d,%d), D1 %d (%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d), D2 %d (%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d), e_r %d, e_c %d, R_i %d, D1_i %d, D2_i %d, res %d, fin %d",column, currow, forward_possible, backward_needed, r0,r1,r2,r3,r4,r5,r6,r7,Ru0,Ru1,Ru2,Ru3,Ru4,Ru5,Ru6,Ru7,D1_check, D1u0,D1u1,D1u2,D1u3,D1u4,D1u5,D1u6,D1u7,D1u8,D1u9,D1u10,D1u11,D1u12,D1u13,D1u14,D1u15,D2_check, D2u0,D2u1,D2u2,D2u3,D2u4,D2u5,D2u6,D2u7,D2u8,D2u9,D2u10,D2u11,D2u12,D2u13,D2u14,D2u15, edit_row, edit_column, R_index, D1_index, D2_index, result, finished);
*/

endmodule
