`timescale 1ns / 1ps

module SongPlayerBGM(input clock, input reset, input playSound, output reg audioOut);
    reg [19:0] counter;
    reg [31:0] time1, noteTime;
    reg [9:0] msec;	//millisecond counter, and sequence number of musical note.
    wire [4:0] note;
    reg [9:0] number;
    wire [4:0] duration;
    wire [19:0] notePeriod;
    parameter clockFrequency = 100_000_000; 
    
    MusicSheetBGM BGM_song(number, notePeriod, duration);
    always @ (posedge clock) 
    begin
        if(reset | ~playSound) 
        begin 
            counter <=0;  
            time1<=0;  	
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
            if(number == 85) number <=0; // Make the number reset at the end of the song
        end
    end	
             
    always @(duration) noteTime = duration * (clockFrequency/8); 
           //number of   FPGA clock periods in one note.
endmodule   
 

module MusicSheetBGM( input [9:0] number, 
	output reg [19:0] note,//what is the max frequency  
	output reg [4:0] duration);
parameter   EIGHTH = 5'b00001; 
parameter   QUARTER = 5'b00010; 
parameter	HALF = 5'b00100;
parameter	ONE = 2* HALF;
parameter	TWO = 2* ONE;
parameter	FOUR = 2* TWO;
parameter SP=1,E3=151686,D3=170262,B3=202477,G3=127553,FS3=135137,A3=227273;
 
always @ (number) begin
case(number) // Blinding lights
    0: 	    begin note = SP; duration = HALF;	  end	//
    1: 	    begin note = E3; duration = EIGHTH;   end	//
    2: 	    begin note = SP; duration = EIGHTH;   end	//
    3: 	    begin note = E3; duration = EIGHTH;   end	//
    4: 	    begin note = SP; duration = EIGHTH;   end	//
    5: 	    begin note = B3; duration = EIGHTH;   end	//
    6: 	    begin note = SP; duration = EIGHTH;   end	//
    7: 	    begin note = B3; duration = EIGHTH;   end	//
    8: 	    begin note = SP; duration = EIGHTH;   end	//
    9: 	    begin note = D3; duration = EIGHTH;   end	//
    10: 	begin note = SP; duration = EIGHTH;   end	//
    11: 	begin note = D3; duration = EIGHTH;   end	//
    12: 	begin note = SP; duration = HALF;      end	//
    
    13: 	begin note = E3; duration = EIGHTH;   end	//
    14: 	begin note = SP; duration = EIGHTH;   end	//
    15: 	begin note = E3; duration = EIGHTH;   end	//
    16: 	begin note = SP; duration = EIGHTH;   end	//
    17: 	begin note = B3; duration = EIGHTH;   end	//
    18: 	begin note = SP; duration = EIGHTH;   end	//
    19: 	begin note = B3; duration = EIGHTH;   end	//
    20: 	begin note = SP; duration = EIGHTH;   end	//
    21: 	begin note = D3; duration = EIGHTH;   end	//
    22: 	begin note = SP; duration = EIGHTH;   end	//
    23: 	begin note = D3; duration = EIGHTH;   end	//
    24: 	begin note = SP; duration = HALF;      end	//
    
    25: 	begin note = E3; duration = EIGHTH;   end	//
    26: 	begin note = SP; duration = EIGHTH;   end	//
    27: 	begin note = E3; duration = EIGHTH;   end	//
    28: 	begin note = SP; duration = EIGHTH;   end	//
    29: 	begin note = B3; duration = EIGHTH;   end	//
    30: 	begin note = SP; duration = EIGHTH;   end	//
    31: 	begin note = B3; duration = EIGHTH;   end	//
    32: 	begin note = SP; duration = EIGHTH;   end	//
    33: 	begin note = D3; duration = EIGHTH;   end	//
    34: 	begin note = SP; duration = EIGHTH;   end	//
    35: 	begin note = D3; duration = EIGHTH;   end	//
    36: 	begin note = SP; duration = HALF;      end	//
    
    37: 	begin note = E3; duration = EIGHTH;   end	//
    38: 	begin note = SP; duration = EIGHTH;   end	//
    39: 	begin note = E3; duration = EIGHTH;   end	//
    40: 	begin note = SP; duration = EIGHTH;   end	//
    41: 	begin note = G3; duration = EIGHTH;   end	//
    42: 	begin note = SP; duration = EIGHTH;   end	//
    43: 	begin note = G3; duration = EIGHTH;   end	//
    44: 	begin note = SP; duration = EIGHTH;   end	//
    45: 	begin note = FS3; duration = EIGHTH;  end	//
    46: 	begin note = SP; duration = EIGHTH;   end	//
    47: 	begin note = FS3; duration = EIGHTH;  end	//
    48: 	begin note = SP; duration = HALF;      end	//
    
    49: 	begin note = D3; duration = EIGHTH;   end	//
    50: 	begin note = SP; duration = EIGHTH;   end	//
    51: 	begin note = D3; duration = EIGHTH;   end	//
    52: 	begin note = SP; duration = EIGHTH;   end	//
    53: 	begin note = A3; duration = EIGHTH;   end	//
    54: 	begin note = SP; duration = EIGHTH;   end	//
    55: 	begin note = A3; duration = EIGHTH;   end	//
    56: 	begin note = SP; duration = EIGHTH;   end	//
    57: 	begin note = D3; duration = EIGHTH;   end	//
    58: 	begin note = SP; duration = EIGHTH;   end	//
    59: 	begin note = D3; duration = EIGHTH;   end	//
    60: 	begin note = SP; duration = HALF;      end	//
    
    61: 	begin note = D3; duration = EIGHTH;   end	//
    62: 	begin note = SP; duration = EIGHTH;   end	//
    63: 	begin note = D3; duration = EIGHTH;   end	//
    64: 	begin note = SP; duration = EIGHTH;   end	//
    65: 	begin note = A3; duration = EIGHTH;   end	//
    66: 	begin note = SP; duration = EIGHTH;   end	//
    67: 	begin note = A3; duration = EIGHTH;   end	//
    68: 	begin note = SP; duration = EIGHTH;   end	//
    69: 	begin note = D3; duration = EIGHTH;   end	//
    70: 	begin note = SP; duration = EIGHTH;   end	//
    71: 	begin note = D3; duration = EIGHTH;   end	//
    72: 	begin note = SP; duration = HALF;      end	//
    
    73: 	begin note = D3; duration = EIGHTH;   end	//
    74: 	begin note = SP; duration = EIGHTH;   end	//
    75: 	begin note = D3; duration = EIGHTH;   end	//
    76: 	begin note = SP; duration = EIGHTH;   end	//
    77: 	begin note = G3; duration = EIGHTH;   end	//
    78: 	begin note = SP; duration = EIGHTH;   end	//
    79: 	begin note = G3; duration = EIGHTH;   end	//
    80: 	begin note = SP; duration = EIGHTH;   end	//
    81: 	begin note = FS3; duration = EIGHTH;  end	//
    82: 	begin note = SP; duration = EIGHTH;   end	//
    83: 	begin note = FS3; duration = EIGHTH;  end	//
    84: 	begin note = SP; duration = HALF;      end	//
    85: 	begin note = A3; duration = EIGHTH;   end	//
    86: 	begin note = SP; duration = EIGHTH;   end	//
    87: 	begin note = A3; duration = EIGHTH;   end	//
    88: 	begin note = SP; duration = EIGHTH;   end	//
    89: 	begin note = D3; duration = EIGHTH;   end	//
    90: 	begin note = SP; duration = EIGHTH;   end	//
    91: 	begin note = D3; duration = EIGHTH;   end	//
    92: 	begin note = SP; duration = HALF;      end	//
    93: 	begin note = E3; duration = EIGHTH;   end	//
    94: 	begin note = SP; duration = EIGHTH;   end	//
    95: 	begin note = E3; duration = EIGHTH;   end	//
    96: 	begin note = SP; duration = EIGHTH;   end	//
    97: 	begin note = B3; duration = EIGHTH;   end	//
    98: 	begin note = SP; duration = EIGHTH;   end	//
    99: 	begin note = B3; duration = EIGHTH;   end	//
    100: 	begin note = SP; duration = EIGHTH;   end	//
    101: 	begin note = FS3; duration = EIGHTH;  end	//
    102: 	begin note = SP; duration = EIGHTH;   end	//
    103: 	begin note = FS3; duration = EIGHTH;  end	//
    104: 	begin note = SP; duration = HALF;      end	//

    
default: 	begin note = E3; duration = FOUR; 	end
endcase
end

endmodule

