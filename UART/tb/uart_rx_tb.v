`timescale 1ns/1ps
`default_nettype none
module uart_rx_tb;
    reg clk, reset;
    reg baud_tick;
    reg rx;
    wire [7:0] data;
    wire data_valid;
    wire frame_error;

    uart_rx DUT (
        .clk(clk), .reset(reset),
        .baud_tick(baud_tick),
        .rx(rx),
        .data(data),
        .data_valid(data_valid),
        .frame_error(frame_error)
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
    
    integer data_valid_count, frame_error_count;

    always @(posedge clk) begin
      if (data_valid)
        data_valid_count = 1;
    end
    
    always @(posedge clk) begin
      if (frame_error)
        frame_error_count = 1;
    end

    // Free-running baud_tick, one pulse every 4 clk cycles
    reg [1:0] tick_div;
    always @(posedge clk) begin
        if(reset) begin
            tick_div<=0;
            baud_tick<=0;
        end
        else if(tick_div>=2'd3) begin
            tick_div <=0;
            baud_tick<=1;
        end
        else begin
            tick_div<=tick_div + 1;
            baud_tick<=0;
        end
    end

    // Hold rx at a given level for exactly one bit period
    task hold_bit(input val);
        integer n;
        begin
            rx = val;
            n = 0;
            while(n < 16) begin
                @(posedge clk);
                if(baud_tick) n = n + 1;
            end
        end
    endtask

    // Send a full, correctly-framed byte
    task send_byte(input [7:0] b);
        integer i;
        begin
            hold_bit(0);              
            for(i = 0; i < 8; i = i + 1)
                hold_bit(b[i]);        
            hold_bit(1);               
        end
    endtask

    initial begin
        clk   = 0;
        reset = 1;
        rx    = 1;
        data_valid_count = 0;
        frame_error_count = 0;
        repeat(5) @(posedge clk);
        reset = 0;
        repeat(5) @(posedge clk);

        // Good frame
        send_byte(8'b10110101);

        check(
          data_valid_count && data === 8'b10110101,
          "RX Valid Frame"
        );
        data_valid_count = 0;
        frame_error_count = 0;

        // Bad frame: stop bit held low instead of high
        rx = 0;
        // start bit
        hold_bit(0);
        // 8 data bits (arbitrary)
        hold_bit(1); hold_bit(0); hold_bit(1); hold_bit(0);
        hold_bit(1); hold_bit(0); hold_bit(1); hold_bit(0);
        // broken stop bit
        hold_bit(0);
        repeat(10) @(posedge clk);
        
        check(
          frame_error_count && data === 8'b10110101,
          "UART RX Frame Error"
        );
        data_valid_count = 0;
        frame_error_count = 0;
        
        rx = 1;
        
        @ (posedge clk);

        // Confirm receiver recovered
        send_byte(8'h16);
        repeat(100) @(posedge clk);
        
        check(
          data_valid_count && data === 8'h16,
          "UART RX Recovery"
        );
        data_valid_count = 0;
        frame_error_count = 0;
        $stop;
    end

endmodule
