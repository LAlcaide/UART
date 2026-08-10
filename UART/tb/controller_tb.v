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
        if(active_baud !== 3'd1)
            $display("FAIL case1: expected active_baud=1, got %0d", active_baud);
        else
            $display("PASS case1: immediate apply while idle, active_baud=%0d", active_baud);

        repeat(3) @(posedge clk);

        // Test Case 2: busy, change should defer, not apply yet
        tx_busy = 1;
        @(posedge clk);
        baud_value = 3'd3;
        repeat (2) @(posedge clk);
        if(active_baud !== 3'd1)
            $display("FAIL case2: expected active_baud still=1 (deferred), got %0d", active_baud);
        else
            $display("PASS case2: change correctly deferred while busy, active_baud=%0d", active_baud);

        // Test Case 2b: multiple changes while still busy
        @(posedge clk);
        baud_value = 3'd4;
        repeat (2) @(posedge clk);
        if(active_baud !== 3'd1)
            $display("FAIL case2b: active_baud changed too early, got %0d", active_baud);
        else
            $display("PASS case2b: still deferred after second change, active_baud=%0d", active_baud);

        // Test Case 3: tx_busy drops, pending value applies
        tx_busy = 0;
        repeat (2) @(posedge clk);
        if(active_baud !== 3'd4)
            $display("FAIL case3: expected active_baud=4 (last-one-wins), got %0d", active_baud);
        else
            $display("PASS case3: last-one-wins applied correctly, active_baud=%0d", active_baud);

        repeat(5) @(posedge clk);
        $stop;
    end
endmodule
