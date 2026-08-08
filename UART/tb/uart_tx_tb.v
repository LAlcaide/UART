`timescale 1ns/1ps
`default_nettype none
module uart_tx_tb;
    reg clk, reset;
    reg baud_tick;
    reg [7:0] data;
    reg tx_start;
    wire tx, tx_busy;

    reg [7:0] received;
    integer i;

    uart_tx DUT (
        .clk(clk), .reset(reset),
        .baud_tick(baud_tick),
        .data(data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    always #10 clk = ~clk;

    // Simple free-running baud_tick, one pulse every 4 clk cycles
    reg [1:0] tick_div;
    always @(posedge clk) begin
        if(reset) begin
            tick_div  <= 0;
            baud_tick <= 0;
        end
        else if(tick_div == 2'd3) begin
            tick_div  <= 0;
            baud_tick <= 1;
        end
        else begin
            tick_div  <= tick_div + 1;
            baud_tick <= 0;
        end
    end

    // Wait for exactly 16 baud_tick pulses
    task wait_one_bit;
        integer n;
        begin
            n = 0;
            while(n < 16) begin
                @(posedge clk);
                if(baud_tick) n = n + 1;
            end
        end
    endtask

    initial begin
        clk      = 0;
        reset    = 1;
        tx_start = 0;
        data     = 8'h00;
        repeat(5) @(posedge clk);
        reset = 0;

        // Send a test byte
        data = 8'b10110101;
        @(posedge clk);
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;

        // Check start bit
        wait_one_bit;
        if(tx !== 1'b0)
            $display("FAIL: start bit expected 0, got %b", tx);
        else
            $display("PASS: start bit = 0");

        // Sample each of the 8 data bits, LSB first
        for(i = 0; i < 8; i = i + 1) begin
            wait_one_bit;
            received[i] = tx;
            $display("bit %0d received = %b (expected %b)", i, tx, data[i]);
        end

        // Check stop bit
        wait_one_bit;
        if(tx !== 1'b1)
            $display("FAIL: stop bit expected 1, got %b", tx);
        else
            $display("PASS: stop bit = 1");

        // Final check
        if(received === data)
            $display("PASS: full byte match ? sent %b, received %b", data, received);
        else
            $display("FAIL: byte mismatch ? sent %b, received %b", data, received);

        repeat(20) @(posedge clk);
        $stop;
    end
endmodule
`default_nettype wire
