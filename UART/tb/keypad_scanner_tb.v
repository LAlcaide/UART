`timescale 1ns/1ps
`default_nettype none
module keypad_scanner_tb;
    reg clk;
    reg reset;
    reg [3:0] R;
    wire [3:0] C;
    wire key_valid;
    wire [3:0] key;

    keypad_scanner DUT (
        .clk(clk),
        .reset(reset),
        .R(R),
        .C(C),
        .key_valid(key_valid),
        .key(key)
    );

    defparam DUT.DEBOUNCE_INST.DEBOUNCE_TIME = 20;

    always #10 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        R     = 4'b1111;
        repeat (5) @(posedge clk);
        reset = 0;

        //Press key '1' (Column 0, Row 0)
        wait(C == 4'b1110);
        @(posedge clk);
        R = 4'b1110;   
        repeat (80) @(posedge clk);
        R = 4'b1111;
        repeat (50) @(posedge clk);

        // Press key '5' (Column 1, Row 1)
        wait(C == 4'b1101);
        @(posedge clk);
        R = 4'b1101; 
        repeat (80) @(posedge clk);
        R = 4'b1111;
        repeat (50) @(posedge clk);

        // Press key '9' (Column 2, Row 2)
        wait(C == 4'b1011);
        @(posedge clk);
        R = 4'b1011;            
        repeat (80) @(posedge clk);
        R = 4'b1111;
        repeat (50) @(posedge clk);

        // Press key 'D' (Column 3, Row 3)
        wait(C == 4'b0111);
        @(posedge clk);
        R = 4'b0111;            
        repeat (80) @(posedge clk);
        R = 4'b1111;
        repeat (50) @(posedge clk);

        $stop;
    end
endmodule