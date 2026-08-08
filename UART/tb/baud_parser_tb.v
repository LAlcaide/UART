`timescale 1ns/1ps
`default_nettype none
module baud_parser_tb;
    reg clk, reset;
    reg key_valid;
    reg [3:0] key;
    wire error;
    wire [2:0] baud_value;

    baud_parser DUT (
        .clk(clk),
        .reset(reset),
        .key_valid(key_valid),
        .key(key),
        .error(error),
        .baud_value(baud_value)
    );

    always #10 clk = ~clk;

    task press(input [3:0] k);
        begin
            @(posedge clk);
            key       = k;
            key_valid = 1;
            @(posedge clk);
            key_valid = 0;
            @(posedge clk); 
        end
    endtask

    initial begin
        clk       = 0;
        reset     = 1;
        key_valid = 0;
        key       = 0;
        repeat(3) @(posedge clk);
        reset = 0;

        // Valid: 9600 -> baud_value should become 0
        press(9); press(6); press(0); press(0); press(11);
        repeat(5) @(posedge clk);

        // Valid: 19200 -> baud_value should become 1
        press(1); press(9); press(2); press(0); press(0); press(11);
        repeat(5) @(posedge clk);

        // Valid: 38400 -> baud_value should become 2
        press(3); press(8); press(4); press(0); press(0); press(11);
        repeat(5) @(posedge clk);

        // Valid: 57600 -> baud_value should become 3
        press(5); press(7); press(6); press(0); press(0); press(11);
        repeat(5) @(posedge clk);

        // Valid: 115200 -> baud_value should become 4
        press(1); press(1); press(5); press(2); press(0); press(0); press(11);
        repeat(5) @(posedge clk);

        // Invalid: 1234 -> error should pulse, baud_value stays 4
        press(1); press(2); press(3); press(4); press(11);
        repeat(5) @(posedge clk);

        // Backspace test: type "961", backspace, "00", Enter -> should validate as 9600
        press(9); press(6); press(1); press(10); press(0); press(0); press(11);                         
        repeat(5) @(posedge clk);

        // Enter with empty buffer -> error, baud_value unchanged
        press(11);
        repeat(5) @(posedge clk);

        $stop;
    end
endmodule
