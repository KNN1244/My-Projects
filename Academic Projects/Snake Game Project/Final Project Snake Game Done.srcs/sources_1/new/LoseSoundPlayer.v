`timescale 1ns / 1ps

module LoseSongPlayer(input clock, input reset, input playSound, output reg audioOut);
    reg [19:0] counter;
    reg [31:0] time1, noteTime;
    reg [9:0] msec;	//millisecond counter, and sequence number of musical note.
    wire [4:0] note;
    reg [9:0] number;
    wire [4:0] duration;
    wire [19:0] notePeriod;
    parameter clockFrequency = 100_000_000; 
    
    MusicSheetLose Lose_song(number, notePeriod, duration);
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
            if(number >= 7) number <=8; // Make the number reset at the end of the song
        end
    end	
             
    always @(duration) noteTime = duration * (clockFrequency/8); 
           //number of   FPGA clock periods in one note.
endmodule   
 

module MusicSheetLose( input [9:0] number, 
	output reg [19:0] note,//what is the max frequency  
	output reg [4:0] duration);
parameter   EIGHTH = 5'b00001; 
parameter   QUARTER = 5'b00010; 
parameter	HALF = 5'b00100;
parameter	ONE = 2* HALF;
parameter	TWO = 2* ONE;
parameter	FOUR = 2* TWO;
parameter SP=1,C2=382226,CS2=360773,D2=340524;
 
always @ (number) begin
case(number) // Blinding lights
    0: 	    begin note = SP; duration = QUARTER;	  end	//
    1: 	    begin note = D2; duration = HALF;   end	//
    2: 	    begin note = SP; duration = EIGHTH;   end	//
    3: 	    begin note = CS2; duration = HALF;   end	//
    4: 	    begin note = SP; duration = EIGHTH;   end	//
    5: 	    begin note = C2; duration = HALF+QUARTER;   end	//
    6: 	    begin note = SP; duration = EIGHTH;   end	//
   
default: 	begin note = SP; duration = FOUR; 	end
endcase
end

endmodule

