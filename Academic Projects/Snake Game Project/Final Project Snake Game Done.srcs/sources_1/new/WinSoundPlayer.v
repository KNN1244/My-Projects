`timescale 1ns / 1ps

module WinSongPlayer(input clock, input reset, input playSound, output reg audioOut);
    reg [19:0] counter;
    reg [31:0] time1, noteTime;
    reg [9:0] msec;	//millisecond counter, and sequence number of musical note.
    wire [4:0] note;
    reg [9:0] number;
    wire [4:0] duration;
    wire [19:0] notePeriod;
    parameter clockFrequency = 100_000_000; 
    
    MusicSheetWin Win_song(number, notePeriod, duration);
    always @ (posedge clock) 
    begin
        if(reset | ~playSound) 
        begin 
            counter <=0;  
            time1<=0;  	
            number<= 0;
        end
        else 
        begin
            counter <= counter + 1; 
            time1<= time1+1;
            if(counter >= notePeriod) 
            begin
                counter <=0;  
                audioOut <= ~audioOut ; 
            end	//toggle audio output 	
            if( time1 >= noteTime) 
            begin	
                time1 <=0;  
                number <= number + 1; 
            end  //play next note
            if(number >= 19) number <=20; // Make the number reset at the end of the song
        end
    end	
             
    always @(duration) noteTime = duration * (clockFrequency/8); 
           //number of   FPGA clock periods in one note.
endmodule   
 

module MusicSheetWin( input [9:0] number, 
	output reg [19:0] note,//what is the max frequency  
	output reg [4:0] duration);
parameter   EIGHTH = 5'b00001; 
parameter   QUARTER = 5'b00010; 
parameter	HALF = 5'b00100;
parameter	ONE = 2* HALF;
parameter	TWO = 2* ONE;
parameter	FOUR = 2* TWO;
parameter SP=1,E5=37922,CS5=45097,D5=42566,G5=31888,F5=35793;
 
always @ (number) begin
case(number) // Blinding lights
    0: 	    begin note = SP; duration = QUARTER;	  end	//
    1: 	    begin note = E5; duration = EIGHTH;   end	//
    2: 	    begin note = SP; duration = EIGHTH;   end	//
    3: 	    begin note = E5; duration = EIGHTH;   end	//
    4: 	    begin note = SP; duration = EIGHTH;   end	//
    5: 	    begin note = E5; duration = EIGHTH;   end	//
    6: 	    begin note = SP; duration = EIGHTH;   end	//
    7: 	    begin note = E5; duration = QUARTER;	  end	//
    8: 	    begin note = SP; duration = EIGHTH;	  end	//
    
    9: 	    begin note = CS5; duration = QUARTER;   end	//
    10: 	begin note = SP; duration = QUARTER;   end	//
    11: 	begin note = D5; duration = EIGHTH;   end	//
    12: 	begin note = SP; duration = QUARTER;   end	//
    13: 	begin note = E5; duration = EIGHTH;   end	//
    14: 	begin note = SP; duration = QUARTER;   end	//
    14: 	begin note = F5; duration = EIGHTH;   end	//
    16: 	begin note = SP; duration = EIGHTH;   end	//
    17: 	begin note = F5; duration = ONE;      end	//
    18: 	begin note = SP; duration = QUARTER;   end	//
   
default: 	begin note = SP; duration = FOUR; 	end
endcase
end

endmodule


