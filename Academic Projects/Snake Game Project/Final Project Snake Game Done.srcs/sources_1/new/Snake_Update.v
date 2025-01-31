`timescale 1ns / 1ps

module snakeClkGen(clk, resetSW, speed, outsig);
    input clk;
    input resetSW;
    input speed;
    output outsig;
    reg [26:0] counter;
    reg outsig;
    always @ (posedge clk)
    begin
        if (resetSW)
        begin
            counter=0;
        end
        else
        begin
            outsig=0;
            counter = counter +1;
            if (~speed) begin
            if (counter == 7111111)
            begin
                outsig=1;
                counter=0;
            end
            end
            else begin
            if (counter == 3555555)
            begin
                outsig=1;
                counter=0;
            end
            end
        end
    end
endmodule


