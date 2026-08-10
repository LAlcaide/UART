`timescale 1ns/1ps
`default_nettype none
module uart_top_tb;
    reg clk, reset, rx;
    reg [3:0] R;
    wire [3:0] C;
    wire tx;
    wire parser_error, rx_frame_error;

    uart_top DUT (
        .clk(clk), .reset(reset),
        .R(R), .C(C),
        .rx(rx), .tx(tx),
        .parser_error(parser_error),
        .rx_frame_error(rx_frame_error)
    );

    defparam DUT.BAUD_GEN_INST.baud_9600   = 9'd10;
    defparam DUT.BAUD_GEN_INST.baud_19200  = 9'd10;
    defparam DUT.BAUD_GEN_INST.baud_38400  = 9'd10;
    defparam DUT.BAUD_GEN_INST.baud_57600  = 9'd10;
    defparam DUT.BAUD_GEN_INST.baud_115200 = 9'd10;

    defparam DUT.KEYPAD_INST.settle_cycles = 5;
    defparam DUT.KEYPAD_INST.DEBOUNCE_INST.DEBOUNCE_TIME = 20;

    always #10 clk = ~clk; 

    localparam BIT_PERIOD_CYCLES = 160;

    integer p;
    task hold_press(input [3:0] target_col, input [3:0] row_pattern, input integer reps);
        begin
            for(p = 0; p <= reps; p = p + 1) begin
                wait(C == target_col);
                @(posedge clk);
                R = row_pattern;
                wait(C != target_col);
                R = 4'b1111;
            end
        end
    endtask

    task send_uart_byte(input [7:0] b);
        integer i;
        begin
            rx = 0;                              // start bit
            repeat(BIT_PERIOD_CYCLES) @(posedge clk);
            for(i = 0; i < 8; i = i + 1) begin
                rx = b[i];
                repeat(BIT_PERIOD_CYCLES) @(posedge clk);
            end
            rx = 1;                              // stop bit
            repeat(BIT_PERIOD_CYCLES) @(posedge clk);
        end
    endtask

    initial begin
        clk   = 0;
        reset = 1;
        R     = 4'b1111;
        rx    = 1;
        repeat(5) @(posedge clk);
        reset = 0;
        repeat(5) @(posedge clk);

        // Type "9600" + Enter on the keypad
        hold_press(4'b1011, 4'b1011, 3);   
        hold_press(4'b1011, 4'b1011, 3);
        hold_press(4'b1101, 4'b0111, 3);
        hold_press(4'b1101, 4'b0111, 3);

        repeat(2000) @(posedge clk);

        // Send a UART byte on rx, check it echoes on tx
        send_uart_byte(8'hA5);
        repeat(BIT_PERIOD_CYCLES*11) @(posedge clk);

        $stop;
    end
endmodule
