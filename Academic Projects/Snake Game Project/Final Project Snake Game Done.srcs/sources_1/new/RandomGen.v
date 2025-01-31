`timescale 1ns / 1ps

module RandomGen(
        input clk,
        input [5:0] limit,
        output reg [5:0] random_num0, random_num1
    );
    always@(posedge clk)
    begin
        random_num0 = random_num0 + 1;
        random_num1 = random_num0 + 3;
        if (random_num0 > limit)
            random_num0 = 0;
        if (random_num1 > limit)
            random_num1 = 0;
    end
endmodule
