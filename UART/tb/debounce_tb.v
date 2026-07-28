`timescale 1ns/1ps

module debounce_tb;

    reg clk;
    reg reset;
    reg key_pressed;
    reg [3:0] key;

    wire key_valid;
    wire [3:0] key_out;

    debounce #(.DEBOUNCE_TIME(20)) DUT (
        .clk(clk),
        .reset(reset),
        .key_pressed(key_pressed),
        .key_valid(key_valid),
        .key(key),
        .key_out(key_out)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        key_pressed = 0;
        key = 0;

        repeat (5) @(posedge clk);
        reset = 0;
        repeat (5) @(posedge clk);

        // Test 1: Press key 5
        key = 4'd5; 
        key_pressed = 1;

        repeat (21) @(posedge clk);

        key_pressed = 0;
        repeat (5) @(posedge clk);

        // Test 2: Press key 8
        key = 4'd8;
        key_pressed = 1;

        repeat (21) @(posedge clk);

        key_pressed = 0;
        repeat (5) @(posedge clk);

        // Test 3: Simulate bounce
        key = 4'd3;

        key_pressed = 1;
        repeat (2) @(posedge clk);

        key_pressed = 0;
        repeat (2) @(posedge clk);

        key_pressed = 1;
        repeat (2) @(posedge clk);

        key_pressed = 0;
        repeat (2) @(posedge clk);

        key_pressed = 1;

        repeat (21) @(posedge clk);

        key_pressed = 0;

        repeat (5) @(posedge clk);
        
        // Test 4: Short press

        key = 4'd7;
        key_pressed = 1;

        repeat (10) @(posedge clk);

        key_pressed = 0;

        repeat (5) @(posedge clk);

        $stop;
    end

endmodule
