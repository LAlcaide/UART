`timescale 1ns/1ps
`default_nettype none
module controller_tb;
    reg clk, reset;
    reg [2:0] baud_value;
    reg tx_busy;
    wire [2:0] active_baud;

    controller DUT (
        .clk(clk), .reset(reset),
        .baud_value(baud_value),
        .tx_busy(tx_busy),
        .active_baud(active_baud)
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

    initial begin
        clk = 0;
        reset = 1;
        baud_value = 3'd0;
        tx_busy = 0;
        repeat(3) @(posedge clk);
        reset = 0;
        repeat(3) @(posedge clk);

        // Test Case 1: idle, change should apply immediately
        baud_value = 3'd1;
        repeat (2) @(posedge clk);
        check(
          active_baud === 3'd1,
          "Change active_baud"
        );

        repeat(3) @(posedge clk);

        // Test Case 2: busy, change should defer, not apply yet
        tx_busy = 1;
        @(posedge clk);
        baud_value = 3'd3;
        repeat (2) @(posedge clk);
        check(
          active_baud === 3'd1,
          "Change to active_baud deffered"
        );

        // Test Case 2b: multiple changes while still busy
        @(posedge clk);
        baud_value = 3'd4;
        repeat (2) @(posedge clk);
        check(
          active_baud === 3'd1,
          "Change still deffered"
        );
        
        // Test Case 3: tx_busy drops, pending value applies
        tx_busy = 0;
        repeat (2) @(posedge clk);
        check(
          active_baud === 3'd4,
          "Change to active_baud applied"
        );

        repeat(5) @(posedge clk);
        $stop;
    end
endmodule
