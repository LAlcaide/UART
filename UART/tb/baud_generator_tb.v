`timescale 1ns/1ps
`default_nettype none
module baud_generator_tb;
    reg clk, reset;
    reg [2:0] baud_value;
    wire baud_tick;

    baud_generator DUT (
        .clk(clk),
        .reset(reset),
        .baud_value(baud_value),
        .baud_tick(baud_tick)
    );
    
    task check;
      input condition;
      input [255:0] test_name;
      begin
        if (condition)
            $display("PASS %0s", test_name);
        else
            $display("FAIL %0s", test_name);
      end
    endtask

    always #10 clk = ~clk;
    
    integer baud_count;
    always @(posedge clk) begin
      if (baud_tick)
        baud_count = baud_count + 1;
    end

    initial begin
        clk   = 0;
        reset = 1;
        baud_count = 0;
        baud_value = 3'd4;
        repeat(3) @(posedge clk);
        reset = 0;
        
        @(posedge clk);
        
        // Test Case 1: 115200 baud
        repeat(27*6) @(posedge clk);
        
        check(
          baud_count == 6,
          "Baud 115200 Generation"
        );
        baud_count = 0;

        // Test Case 2: Switch to 9600 baud
        baud_value = 3'd0;
        repeat(326*4) @(posedge clk);
        
         check(
          baud_count == 4,
          "Baud 9600 Generation"
        );
        baud_count = 0;

        // Test Case 3: Switch to 19200 baud
        baud_value = 3'd1;
        repeat(163*4) @(posedge clk);
        
        check(
          baud_count == 4,
          "Baud 19200 Generation"
        );
        baud_count = 0;
        
        // Test Case 4: Switch to 38400 baud
        baud_value = 3'd2;
        repeat(81*4) @(posedge clk);
        
        check(
          baud_count == 4,
          "Baud 38400 Generation"
        );
         baud_count = 0;
         
        // Test Case 5: Switch to 57600 baud
        baud_value = 3'd3;
        repeat(54*4) @(posedge clk);
        
        check(
          baud_count == 4,
          "Baud 57600 Generation"
        );
         baud_count = 0;

        $stop;
    end
endmodule