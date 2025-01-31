`timescale 1ns / 1ps

module SecPulse(
    input wire clk,
    input wire reset,
    input wire [3:0] sec,
    input wire events,
    output reg output_reg,
    output reg [26:0] counter
);
    reg [4:0] sec_counter;
    always@(posedge clk) begin
        if (~events || reset) begin
            output_reg = 0;
            counter = 0;
            sec_counter = 0;
        end
        else begin
            if (events) begin
                output_reg = 1;
                counter = counter + 1;
                if (counter == 25_000_000) begin
                    sec_counter = sec_counter + 1;
                    if (sec_counter >= sec) begin
                        output_reg = 0;
                    end
                end
            end
        end
    end

endmodule
