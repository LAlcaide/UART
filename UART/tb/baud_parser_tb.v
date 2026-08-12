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
    
    integer error_count;
    
    always @(posedge clk) begin
      if (error)
        error_count = 1;
    end

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
        
        check(
          baud_value == 3'd0,
          "Baud Parser 9600"
        );

        // Valid: 19200 -> baud_value should become 1
        press(1); press(9); press(2); press(0); press(0); press(11);
        repeat(5) @(posedge clk);
        
        check(
          baud_value == 3'd1,
          "Baud Parser 19200"
        );

        // Valid: 38400 -> baud_value should become 2
        press(3); press(8); press(4); press(0); press(0); press(11);
        repeat(5) @(posedge clk);
        
        check(
          baud_value == 3'd2,
          "Baud Parser 38400"
        );

        // Valid: 57600 -> baud_value should become 3
        press(5); press(7); press(6); press(0); press(0); press(11);
        repeat(5) @(posedge clk);
        
        check(
          baud_value == 3'd3,
          "Baud Parser 57600"
        );

        // Valid: 115200 -> baud_value should become 4
        press(1); press(1); press(5); press(2); press(0); press(0); press(11);
        repeat(5) @(posedge clk);
        
        check(
          baud_value == 3'd4,
          "Baud Parser 115200"
        );

        // Invalid: 1234 -> error should pulse, baud_value stays 4
        press(1); press(2); press(3); press(4); press(11);
        repeat(5) @(posedge clk);
        
        check(
          error_count,
          "Baud Parser Invalid Input"
        );
        error_count = 0;

        // Backspace test: type "961", backspace, "00", Enter -> should validate as 9600
        press(9); press(6); press(1); press(10); press(0); press(0); press(11);                         
        repeat(5) @(posedge clk);
        
        check(
          baud_value == 3'd0,
          "Baud Parser Backspace"
        );

        // Enter with empty buffer -> error, baud_value unchanged
        press(11);
        repeat(5) @(posedge clk);
        check(
          error_count,
          "Baud Parser Empty Input Error"
        );
        error_count = 0;

        $stop;
    end
endmodule
