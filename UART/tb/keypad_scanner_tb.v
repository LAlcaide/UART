`timescale 1ns/1ps
`default_nettype none
module keypad_scanner_tb;
    reg clk;
    reg reset;
    reg [3:0] R;
    wire [3:0] C;
    wire key_valid;
    wire [3:0] key;
    
    integer i;

    keypad_scanner #(.settle_cycles(5)) DUT (
        .clk(clk),
        .reset(reset),
        .R(R),
        .C(C),
        .key_valid(key_valid),
        .key(key)
    );

    defparam DUT.DEBOUNCE_INST.DEBOUNCE_TIME = 50;

    always #10 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        R     = 4'b1111;
        repeat (5) @(posedge clk);
        reset = 0;

        //Short press key '1'  (Column 0, Row 0)
        wait(C == 4'b1110);
        @(posedge clk);
        R = 4'b1110;   
        wait(C == 4'b1101);
        R = 4'b1111;
        repeat (50) @(posedge clk);

        // Press key '5' (Column 1, Row 1)
        for(i = 0; i<=DUT.DEBOUNCE_INST.DEBOUNCE_TIME/(DUT.settle_cycles * 4); i = i+1) begin
          wait(C == 4'b1101);
          @(posedge clk);
          R = 4'b1101; 
          wait(C == 4'b1011);
          R = 4'b1111;
        end
        repeat (50) @(posedge clk);
        
        // Press key '5' again (Column 1, Row 1)
        for(i = 0; i<=DUT.DEBOUNCE_INST.DEBOUNCE_TIME/(DUT.settle_cycles * 4); i = i+1) begin
          wait(C == 4'b1101);
          @(posedge clk);
          R = 4'b1101; 
          wait(C == 4'b1011);
          R = 4'b1111;
        end
        repeat (50) @(posedge clk);

        // Press key '9' (Column 2, Row 2)
        for(i = 0; i<=DUT.DEBOUNCE_INST.DEBOUNCE_TIME/(DUT.settle_cycles * 4); i = i+1) begin
          wait(C == 4'b1011);
          @(posedge clk);
          R = 4'b1011; 
          wait(C == 4'b0111);
          R = 4'b1111;
        end
        repeat (50) @(posedge clk);

        // Press key 'D' (Column 3, Row 3)
        for(i = 0; i<=DUT.DEBOUNCE_INST.DEBOUNCE_TIME/(DUT.settle_cycles * 4); i = i+1) begin
          wait(C == 4'b0111);
          @(posedge clk);
          R = 4'b0111; 
          wait(C == 4'b1110);
          R = 4'b1111;
        end
        repeat (50) @(posedge clk);

        $stop;
    end
endmodule
