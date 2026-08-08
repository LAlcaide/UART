`default_nettype none
module baud_parser(
input wire clk, reset, key_valid,
input wire [3:0] key,
output reg error,
output reg [2:0] baud_value
);

    reg [3:0] digits [0:5];
    reg [2:0] digit_count;
    
    integer i;

    localparam KEY_BACKSPACE = 4'd10;
    localparam KEY_ENTER     = 4'd11;
    
    always @(posedge clk) begin
      error<=0;
      if(reset) begin
         {digit_count, baud_value} <= 0;
         for(i = 0; i < 6; i = i + 1)
            digits[i] <= 0;
      end
      else if (key_valid) begin
        if(key<=9 && digit_count < 6) begin
          digits[digit_count]<=key;
          digit_count <= digit_count + 1;
        end
          else if(key==KEY_BACKSPACE && digit_count>0) begin
          digits[digit_count-1]<=0;
          digit_count <= digit_count - 1;
        end
          else if(key==KEY_ENTER) begin
          if(digit_count==4 && digits[0]==9 && digits[1]==6 && digits[2]==0 && digits[3]==0)
            baud_value  <= 3'd0;
          else if(digit_count==5 && digits[0]==1 && digits[1]==9 && digits[2]==2 && digits[3]==0 && digits[4] == 0)
            baud_value  <= 3'd1;
          else if(digit_count==5 && digits[0]==3 && digits[1]==8 && digits[2]==4 && digits[3]==0 && digits[4] == 0)
            baud_value  <= 3'd2;
          else if(digit_count==5 && digits[0]==5 && digits[1]==7 && digits[2]==6 && digits[3]==0 && digits[4] == 0)
            baud_value  <= 3'd3;
          else if(digit_count==6 && digits[0]==1 && digits[1]==1 && digits[2]==5 && digits[3]==2 && digits[4] == 0 && digits[5] == 0)
            baud_value  <= 3'd4;
          else
            error<=1;
          for(i = 0; i < digit_count; i = i + 1)
            digits[i] <= 0;
          digit_count <= 0;
        end
        
      end
    end
  
endmodule
