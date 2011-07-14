module vga(input clk, input reset, input [3:0] buttons, input [7:1] switches, output [7:0] LEDs, output red, output green, output blue, output reg hsync, output reg vsync);


	reg [9:0] posx;	//Bildschirmkoordinaten (nullbasiert)
	reg [9:0] posy;
	
	reg syncing;

	wire vclk;
	video_clk my_vclk(.clk(clk), .reset(reset), .vclk(vclk));
	
	//horizontal
	parameter HD = 10'd640;	//Sichtbare Pixel
	parameter HFP = 10'd16;	//Anzahl Pixel der horizontalen vorderen Schwarzschulter
	parameter HS = 10'd96;	//Anzahl Pixel des horizontalen Synchronimpulses
	parameter HBP = 10'd48;	//Anzahl Pixel der horizontalen Schwarzschulter

	//vertikal
	parameter VD = 10'd480;	//Sichtbare Zeilen
	parameter VFP = 10'd10;	//Anzahl der Zeilen der vertikalen vorderen Schwarzschulter    
	parameter VS = 10'd2;	//Anzahl der Zeilen des vertikalen Synchronimpulses
	parameter VBP = 10'd33;	//Anzahl der Zeilen der vertikalen hinteren Schwarzschulter   


	//instantiate queen controller
	wire [4:0] row_query;
	wire [4:0] row_result;
	wire [31:0] result;
	wire [4:0] queenN = switches[7:3];
	queenController iQueenController(.n(queenN), .outSel(switches[2:1]), .reset(buttons[3]), .outNum(LEDs[7:0]), .sysClk(vclk), .result(result), .row_query(row_query), .row_result(row_result));


	always @ (posedge vclk, posedge reset)
	begin
		if (reset)
		begin			
			posx = HD;
			posy = VD;
			hsync = 0;
			vsync = 0;
			syncing = 1;
		end
		else
		begin
			posx = posx + 1'b1;

			if (syncing)
			begin
				
				hsync = ((HD+HFP) <= posx) && (posx < (HD+HFP+HS));
					

				if (posx == (HD+HFP+HS+HBP)) //Zeile vollständig mit sync (nullbasiert)
				begin
					posx = 10'b0;
					posy = posy + 1'b1;
				end


				vsync = ((VD+VFP) < posy) && (posy < (VD+VFP+VS));

				if (posy == (VD+VFP+VS+VBP)) //Bild vollständig mit syncs
				begin
					posy = 10'b0;
				end


				syncing = (posy >= VD) || (posx >= HD);
			end
			else
			begin
				if (posx == HD) //erster Pixel ausserhalb des Bildschirms (nullbasiert)
					syncing = 1;

			end
		end
	end

	//pixelcolor logic
	
	//Chessboard output
	wire [9:0] boardx = posx-160;
	wire [4:0] bx = boardx[8:4];
	wire [9:0] boardy = posy-60;
	wire [4:0] by = boardy[8:4]+1;
	wire boardenable = ((160<=posx) && (posx < 480)) && ((60 <= posy) && (posy < 380)) && (bx < queenN) && (by <= queenN);
	wire boardparity = bx[0] ^ by[0];
	assign row_query = bx;
	wire boardset = (row_result == by);
	
	// Result Binary Print Line
	wire resultline = (posy > 440) && (posy < 456);
	wire [31:0] resultx = posx - 64;
	wire [4:0] resultindex = resultx[8:4];
	wire resultstate = result[31-resultindex];
	wire resultenable = posx[3];
	wire [3:0] dot = resultline ? ((posx<576 && posx>64) ? (resultenable ? (resultstate ? 3'b110 : 3'b001) : 3'b000) : 3'b000) : (boardenable ? (boardset ? 3'b100 : (boardparity ? 3'b111 : 3'b001)) : 3'b000);
	
	assign red = syncing ? 0 : dot[2];
	assign green = syncing ? 0 : dot[1];
	assign blue = syncing ? 0 : dot[0];

	
endmodule
