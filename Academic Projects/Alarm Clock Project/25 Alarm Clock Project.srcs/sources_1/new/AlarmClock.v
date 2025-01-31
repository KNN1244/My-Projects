`timescale 1ns / 1ps

module AlarmClock(
    input OFswitch, sysclk, clkreset, select, al_stop, inc, dec, set_al,
    output [6:0] C,
    output [7:0] AN,
    output DP, audioOut, aud_sd, set_al_LED,
    output [2:0] RGB1, RGB2);
    parameter freq05 = 0.5, freq1 = 1, freq100 = 100, freq400 = 400;
    wire sysclkwire, clkresetwire, T_select, selectwire, al_stopwire, incwire, decwire,
    outsig05, outsig1, outsig100, outsig400, DPwire, audioOutwire, aud_sdwire, Enable;
    wire [2:0] Q, RGB1wire, RGB2wire;
    wire [6:0] C0,C1,C2,C3,C4,C5,C6,C7,Cwire;
    wire [7:0] ANwire;
    wire [5:0] second, minute, sec_set, min_set;
    wire [3:0] second_tens,second_ones,minute_tens,minute_ones;
    wire [3:0] al_sec_tens,al_sec_ones,al_min_tens,al_min_ones;
    
    // Clcok Counting and Display modules
    slowerClkGen Hz05clk(sysclkwire, freq05, 1'b0, outsig05);
    slowerClkGen Hz1clk(sysclkwire, freq1, 1'b0, outsig1);
    slowerClkGen Hz100clk(sysclkwire, freq100, 1'b0, outsig100);
    slowerClkGen Hz400clk(sysclkwire, freq400, 1'b0, outsig400);
    upcounter mycounter(1'b1, outsig400, 1'b1, Q);
    Redge_detect Clkreset(outsig05, 1'b0, clkreset, clkresetwire);
    TimeGen timecounter(outsig1, clkresetwire, second, minute);
    DigitSeparator second_sep(second,second_tens,second_ones);
    DigitSeparator minute_sep(minute,minute_tens,minute_ones);
    Pattern seg0(second_ones,C0);
    Pattern seg1(second_tens,C1);
    Pattern seg2(minute_ones,C2);
    Pattern seg3(minute_tens,C3);
    // Alarm Setting and Display modules
    Redge_detect Select(outsig100, 1'b0, select, T_select);
    Toggle_In SelectT(1'b0, T_select, selectwire);
    Redge_detect Inc(outsig100, 1'b0, inc, incwire);
    Redge_detect Dec(outsig100, 1'b0, dec, decwire);
    TimeSelect(sysclk,incwire,decwire,selectwire,sec_set,min_set);
    DigitSeparator al_sec_sep(sec_set,al_sec_tens,al_sec_ones);
    DigitSeparator al_min_sep(min_set,al_min_tens,al_min_ones);
    Pattern seg4(al_sec_ones,C4);
    Pattern seg5(al_sec_tens,C5);
    Pattern seg6(al_min_ones,C6);
    Pattern seg7(al_min_tens,C7);
    // Alarm checking and alarm sounding and lighting
    Redge_detect Alarmstop(outsig05, 1'b0, al_stop, al_stopwire);
    Alarm_Control mycontrol(outsig1,al_stopwire,set_al,minute,second,min_set,sec_set,Enable);
    SongPlayer alarm_song(sysclkwire, 1'b0, Enable, audioOutwire, aud_sdwire);
    RGB_led blinking(outsig1, ~Enable, RGB1wire, RGB2wire);
    // Display mux
    mux8to1 mymux(Q,C0,C1,C2,C3,C4,C5,C6,C7,ANwire,Cwire,DPwire);
    // On/off logic module
    On_Off_logic mylogic(OFswitch,sysclk,Cwire,DPwire,ANwire,audioOutwire,aud_sdwire,RGB1wire,RGB2wire,set_al,
    sysclkwire,C,DP,AN,audioOut,aud_sd,RGB1,RGB2,set_al_LED);
endmodule

module On_Off_logic(OFswitch,sysclk,Cwire,DPwire,ANwire,audioOutwire,aud_sdwire,RGB1wire,RGB2wire,set_al,
    sysclkwire,C,DP,AN,audioOut,aud_sd,RGB1,RGB2,set_al_LED);
    input OFswitch, sysclk, DPwire, audioOutwire, aud_sdwire, set_al;
    input [6:0] Cwire;
    input [7:0] ANwire;
    input [2:0] RGB1wire, RGB2wire;
    output reg [6:0] C;
    output reg [7:0] AN;
    output reg sysclkwire, DP, audioOut, aud_sd;
    output reg [2:0] RGB1, RGB2;
    output reg set_al_LED;
    
    always @(OFswitch)
    begin
        if(~OFswitch)
        begin
            sysclkwire <= 0;
            C <= 7'b1111111;
            AN <= 8'b11111111;
            DP <= 1;
            audioOut <= 1;
            aud_sd <= 0;
            RGB1 <= 3'b000;
            RGB2 <= 3'b000;
            set_al_LED <= 0;
        end
        else
        begin
            sysclkwire <= sysclk;
            C <= Cwire;
            AN <= ANwire;
            DP <= DPwire;
            audioOut <= audioOutwire;
            aud_sd <= aud_sdwire;
            RGB1 <= RGB1wire;
            RGB2 <= RGB2wire;
            set_al_LED <= set_al;
        end
    end 
endmodule

module Alarm_Control(oneHz,stop_al,set_al,clk_min,clk_sec,al_min,al_sec,E);
    input oneHz, stop_al, set_al;
    input [5:0] clk_min,clk_sec,al_min,al_sec;
    output reg E;
    reg [4:0] counter;   // 5-bit counter to count 20 seconds (max count = 31)


    always @(posedge oneHz)
    begin
        if (set_al)
        begin
            if ((clk_min != al_min) || (clk_sec != al_sec))
            begin
                E <= 0;
            end
            if (counter < 27) // alarm will sound for 28 sec
            begin
                counter <= counter +1;
                E <= 1;
            end
            if (((clk_min == al_min) && (clk_sec == al_sec)))
            begin
                counter <= 0;
                E <= 1;
            end
            if (stop_al)
            begin
                E<=0;
                counter <= 31;
            end
        end
        else
        begin
            E<=0;
            counter <= 31;
        end
    end
endmodule

module TimeGen(oneHzclk,reset,second,minute);
    input oneHzclk, reset;
    output reg [5:0] second, minute;
    
    always @(posedge oneHzclk)
    begin
        if (!reset)
        begin
            second = second + 1;
            if (second == 60)
            begin
                second = 0;
                minute = minute + 1;
            end
            if (minute == 60)
            begin
                minute = 0;
            end
        end
        else
        begin
            second = 0;
            minute = 0;
        end
    end
endmodule

module TimeSelect(
    input wire clk, inc, dec, selectwire,
    output reg [5:0] second, minute
    );
    reg inc_prev, dec_prev; // Registers to store previous states of inc and dec

    initial begin
        second = 6'b0;
        minute = 6'b0;
        inc_prev = 0;
        dec_prev = 0;
    end

    always @(posedge clk) begin
        // Detect rising edge of inc
        if (inc_prev == 0 && inc == 1) 
        begin
        if(~selectwire)
        begin
            second = second + 1;
            if (second == 60)
            begin
                second = 0;
                minute = minute + 1;
            end
            if (minute == 60)
            begin
                minute = 0;
            end
        end
        if(selectwire)
        begin
            minute = minute + 1;
            if (minute == 60)
            begin
                minute = 0;
            end
        end
        end
        // Detect rising edge of dec
        if (dec_prev == 0 && dec == 1) 
        begin
            if(~selectwire)
        begin
            second = second - 1;
            if (second > 59)
            begin
                second = 59;
                minute = minute -1;
            end
            if (minute > 59)
                minute = 59;
        end
        if(selectwire)
        begin
            minute = minute -1;
            if (minute > 59)
                minute = 59;
        end
        end

        // Update previous state of inc and dec
        inc_prev <= inc;
        dec_prev <= dec;
    end
endmodule

module DigitSeparator (twodigits, tens, ones);
    input [5:0] twodigits;
    output reg [3:0] tens;
    output reg [3:0] ones;
    
    always @(twodigits)
    begin
        tens = twodigits/10;
        ones = twodigits%10;
    end
endmodule

module mux8to1 (S,C0,C1,C2,C3,C4,C5,C6,C7,AN,C,DP);
    input [2:0] S;
    input [6:0] C0,C1,C2,C3,C4,C5,C6,C7;
    output reg [7:0] AN;
    output reg [6:0] C;
    output reg DP;
    
    always @(S)
        case (S)
        0:
        begin 
        C = C0;
        DP = 1;
        AN = 8'b11111110;
        end
        1: 
        begin 
        C = C1;
        DP = 1;
        AN = 8'b11111101;
        end
        2: 
        begin
        C = C2; 
        DP = 0;
        AN = 8'b11111011;
        end
        3: 
        begin 
        C = C3;
        DP = 1;
        AN = 8'b11110111;
        end
        4:
        begin 
        C = C4;
        DP = 1;
        AN = 8'b11101111;
        end
        5: 
        begin 
        C = C5;
        DP = 1;
        AN = 8'b11011111;
        end
        6: 
        begin
        C = C6; 
        DP = 0;
        AN = 8'b10111111;
        end
        7: 
        begin 
        C = C7;
        DP = 1;
        AN = 8'b01111111;
        end
        endcase

endmodule


module Pattern(index, C);
    input [3:0] index;
    output reg [6:0] C;
    
    always @(index)
        case (index)
            0: C=7'b0000001; // 0
            1: C=7'b1001111; // 1
            2: C=7'b0010010; // 2
            3: C=7'b0000110; // 3
            4: C=7'b1001100; // 4
            5: C=7'b0100100; // 5
            6: C=7'b0100000; // 6
            7: C=7'b0001111; // 7
            8: C=7'b0000000; // 8
            9: C=7'b0000100; // 9
            default: C=0;
        endcase
endmodule

module Toggle_In(reset,button_press,tog_sig);
    input reset, button_press;
    output reg tog_sig;
    
    always @(posedge button_press)
    begin
        if (reset)
            tog_sig = 0;
        else
            tog_sig = ~tog_sig;
    end
endmodule

module Redge_detect(input wire clk, reset, level, output reg tick);
    localparam [1:0] zero=2'b00, edg=2'b01, one=2'b10;
    reg [1:0] state_reg, state_next;
    always @(posedge clk, posedge reset)
        if (reset)
            state_reg<=zero;
        else
            state_reg<=state_next;
    always@*
    begin
        state_next=state_reg;
        tick=1'b0; //default output
        case (state_reg)
            zero:
            begin
                tick=1'b0;
                if (level)
                    state_next=edg;
            end
            edg:
            begin
                tick=1'b1;
                if (level)
                    state_next=one;
            else
                state_next=zero;
            end
            one:
                if (~level)
                    state_next=zero;
            default: state_next=zero;
        endcase
    end
endmodule

module slowerClkGen(clk, freq, resetSW, outsig);
    input clk, resetSW;
    input [26:0] freq;
    output reg outsig;
    reg [26:0] counter;
    always @ (posedge clk)
    begin
        if (resetSW)
        begin
            counter=0;
            outsig=0;
        end
        else
        begin
            counter = counter +1;
            if (counter == (100_000_000/(2*freq))) 
            begin
                outsig=~outsig;
                counter=0;
            end
        end
    end
endmodule

module upcounter (Resetn, Clock, E, Q);
    input Resetn, Clock, E;
    output reg [2:0] Q;
    always @(negedge Resetn, posedge Clock)
        if (!Resetn)
            Q <= 0;
        else if (E)
            Q <= Q + 1;
endmodule

module RGB_led(trigger, reset, RGB1, RGB2);
    input trigger, reset;
    output reg [2:0]RGB1;
    output reg [2:0]RGB2;
    reg [4:0] count;
         
    always@(posedge reset, posedge trigger)
    begin
       if (reset)
        begin
            count=0;
            RGB1=0;
            RGB2=0;
        end
       else
        begin
           case(count)
            0: begin RGB1=3'b001; RGB2=3'b010; end
            2: begin RGB1=3'b010; RGB2=3'b011; end
            4: begin RGB1=3'b011; RGB2=3'b100; end
            6: begin RGB1=3'b100; RGB2=3'b101; end
            8: begin RGB1=3'b101; RGB2=3'b110; end
            10:begin RGB1=3'b110; RGB2=3'b111; end
            default: begin RGB1=3'b000; RGB2=3'b000; end
           endcase
           count=count+1;
        end
    end    
endmodule

module SongPlayer( input clock, input reset, input playSound, output reg audioOut, output wire aud_sd);
    reg [19:0] counter;
    reg [31:0] time1, noteTime;
    reg [9:0] msec, number;	//millisecond counter, and sequence number of musical note.
    wire [4:0] note, duration;
    wire [19:0] notePeriod;
    parameter clockFrequency = 100_000_000; 
    
    assign aud_sd = 1'b1;
    
    MusicSheet 	mysong(number, notePeriod, duration	);
    always @ (posedge clock) 
    begin
        if(reset | ~playSound) 
        begin 
            counter <=0;  
            time1<=0;  
            number <=0;  
            audioOut <=1;	
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
           // if(number == 99) number <=0; // Make the number reset at the end of the song
        end
    end	
             
    always @(duration) noteTime = duration * (clockFrequency/8); 
           //number of   FPGA clock periods in one note.
endmodule   
 

module MusicSheet( input [9:0] number, 
	output reg [19:0] note,//what is the max frequency  
	output reg [4:0] duration);
parameter   EIGHTH = 5'b00001; 
parameter   QUARTER = 5'b00010; 
parameter	HALF = 5'b00100;
parameter	ONE = 2* HALF;
parameter	TWO = 2* ONE;
parameter	FOUR = 2* TWO;
parameter SP=1,G3=127553,A4=113636,C4=95556,D4=85131,E4=75843,F4=71586,G4=63776;
parameter E3=151686,D3=170262,B4=101238;
 
always @ (number) begin
case(number) // Blinding lights
    0: 	    begin note = D4; duration = HALF+2;	  end	//
    1: 	    begin note = SP; duration = EIGHTH;  end	//
    2: 	    begin note = D4; duration = HALF+2; 	  end	//
    3: 	    begin note = C4; duration = EIGHTH;   end	//
    4: 	    begin note = D4; duration = EIGHTH;	  end	//
    5: 	    begin note = E4; duration = QUARTER;  end	//
    6: 	    begin note = SP; duration = EIGHTH;  end	//
    7: 	    begin note = A4; duration = QUARTER;  end	//
    8: 	    begin note = SP; duration = EIGHTH;  end	//
    9: 	    begin note = C4; duration = HALF; 	  end	//
    10: 	begin note = SP; duration = EIGHTH;  end	//
    
    11: 	begin note = D4; duration = HALF+2;	  end	//
    12: 	begin note = SP; duration = EIGHTH;  end	//
    13: 	begin note = D4; duration = HALF+2; 	  end	//
    14: 	begin note = C4; duration = EIGHTH;   end	//
    15: 	begin note = D4; duration = EIGHTH;	  end	//
    16: 	begin note = E4; duration = QUARTER;  end	//
    17: 	begin note = SP; duration = EIGHTH;  end	//
    18: 	begin note = A4; duration = QUARTER;  end	//
    19: 	begin note = SP; duration = EIGHTH;  end	//
    20: 	begin note = C4; duration = HALF; 	  end	//
    21: 	begin note = SP; duration = EIGHTH;  end	//
    
    22: 	begin note = G4; duration = EIGHTH;	  end	//
    23: 	begin note = E4; duration = QUARTER;  end	//
    24: 	begin note = SP; duration = EIGHTH;  end	//
    25: 	begin note = D4; duration = QUARTER;  end	//
    26: 	begin note = SP; duration = EIGHTH;  end	//
    27: 	begin note = C4; duration = HALF; 	  end	//
    28: 	begin note = SP; duration = EIGHTH;  end	//
    
    29: 	begin note = G4; duration = EIGHTH;	  end	//
    30: 	begin note = E4; duration = QUARTER;  end	//
    31: 	begin note = SP; duration = EIGHTH;  end	//
    32: 	begin note = D4; duration = QUARTER;  end	//
    33: 	begin note = SP; duration = EIGHTH;  end	//
    34: 	begin note = C4; duration = HALF; 	  end	//
    35: 	begin note = SP; duration = EIGHTH;  end	//
    
    36: 	begin note = D4; duration = TWO;  end	//
    37: 	begin note = SP; duration = HALF;  end	//
    
    38: 	begin note = A4; duration = EIGHTH;  end	//
    39: 	begin note = G3; duration = EIGHTH;  end	//
    40: 	begin note = A4; duration = EIGHTH;  end	//
    41: 	begin note = G3; duration = EIGHTH;  end	//
    42: 	begin note = A4; duration = ONE+HALF;   end	//
    43: 	begin note = SP; duration = ONE;  end	//
    
    44: 	begin note = A4; duration = EIGHTH;  end	//
    45: 	begin note = G3; duration = EIGHTH;  end	//
    46: 	begin note = A4; duration = EIGHTH;  end	//
    47: 	begin note = G3; duration = EIGHTH;  end	//
    48: 	begin note = SP; duration = EIGHTH;  end	//
    49: 	begin note = C4; duration = QUARTER;   end	//
    50: 	begin note = SP; duration = EIGHTH;  end	//
    51: 	begin note = G3; duration = EIGHTH;  end	//
    52: 	begin note = SP; duration = EIGHTH;  end	//
    53: 	begin note = G3; duration = QUARTER;  end	//
    54: 	begin note = SP; duration = EIGHTH;  end	//
    55: 	begin note = A4; duration = EIGHTH;  end	//
    56: 	begin note = E3; duration = QUARTER;  end	//
    57: 	begin note = SP; duration = HALF+2;  end	//
    
    58: 	begin note = A4; duration = EIGHTH;  end	//
    59: 	begin note = G3; duration = EIGHTH;  end	//
    60: 	begin note = A4; duration = EIGHTH;  end	//
    61: 	begin note = G3; duration = EIGHTH;  end	//
    62: 	begin note = SP; duration = EIGHTH;  end	//
    63: 	begin note = C4; duration = QUARTER;   end	//
    64: 	begin note = SP; duration = EIGHTH;  end	//
    65: 	begin note = G3; duration = EIGHTH;  end	//
    66: 	begin note = SP; duration = EIGHTH;  end	//
    67: 	begin note = G3; duration = QUARTER;  end	//
    68: 	begin note = SP; duration = EIGHTH;  end	//
    69: 	begin note = A4; duration = EIGHTH;  end	//
    70: 	begin note = E3; duration = QUARTER;  end	//
    71: 	begin note = SP; duration = HALF+2;  end	//
    
    72: 	begin note = G3; duration = QUARTER;  end	//
    73: 	begin note = SP; duration = EIGHTH;  end	//
    74: 	begin note = A4; duration = QUARTER;  end	//
    75: 	begin note = SP; duration = EIGHTH;  end	//
    76: 	begin note = E3; duration = EIGHTH;  end	//
    77: 	begin note = D3; duration = ONE;  end	//
    78: 	begin note = SP; duration = HALF;  end	//

    79: 	begin note = G3; duration = EIGHTH;  end	//
    80: 	begin note = A4; duration = EIGHTH;  end	//
    81: 	begin note = G3; duration = EIGHTH;  end	//
    82: 	begin note = A4; duration = EIGHTH;  end	//
    83: 	begin note = G3; duration = EIGHTH;  end	//
    84: 	begin note = A4; duration = ONE+HALF; end	//
    85: 	begin note = SP; duration = ONE;  end	//
    
    86: 	begin note = A4; duration = EIGHTH;  end	//
    87: 	begin note = G3; duration = EIGHTH;  end	//
    88: 	begin note = A4; duration = EIGHTH;  end	//
    89: 	begin note = G3; duration = EIGHTH;  end	//
    90: 	begin note = C4; duration = QUARTER;  end	//
    91: 	begin note = SP; duration = EIGHTH;  end	//
    92: 	begin note = G3; duration = EIGHTH;  end	//
    93: 	begin note = SP; duration = EIGHTH;  end	//
    94: 	begin note = G3; duration = QUARTER;  end	//
    95: 	begin note = SP; duration = EIGHTH;  end	//
    96: 	begin note = A4; duration = EIGHTH;  end	//
    97: 	begin note = E3; duration = QUARTER;  end	//
    98: 	begin note = SP; duration = ONE;  end	//

default: 	begin note = C4; duration = FOUR; 	end
endcase
end

endmodule

