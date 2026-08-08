`timescale 1ns/1ps
`default_nettype none
module baud_generator_tb;
    reg clk, reset;
    reg [2:0] baud_value;
    wire baud_tick;

    integer last_tick_time;
    integer gap;

    baud_generator DUT (
        .clk(clk),
        .reset(reset),
        .baud_value(baud_value),
        .baud_tick(baud_tick)
    );

    always #10 clk = ~clk;

    always @(posedge baud_tick) begin
        if(last_tick_time != 0) begin
            gap = ($time - last_tick_time) / 20;
            $display("[%0t] baud_tick fired, gap = %0d cycles (baud_value=%0d)", $time, gap, baud_value);
        end
        last_tick_time = $time;
    end

    initial begin
        clk   = 0;
        reset = 1;
        baud_value = 3'd4;
        last_tick_time = 0;
        repeat(3) @(posedge clk);
        reset = 0;

        // Test Case 1: 115200 baud
        repeat(27*6) @(posedge clk);

        // Test Case 2: Switch to 9600 baud
        baud_value = 3'd0;
        repeat(326*4) @(posedge clk);

        // Test Case 3: Switch to 19200 baud
        baud_value = 3'd1;
        repeat(163*4) @(posedge clk);
        
        // Test Case 4: Switch to 38400 baud
        baud_value = 3'd2;
        repeat(81*4) @(posedge clk);
        
        // Test Case 5: Switch to 57600 baud
        baud_value = 3'd3;
        repeat(54*4) @(posedge clk);

        $stop;
    end
endmodule