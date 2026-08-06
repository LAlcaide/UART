module debounce #(parameter DEBOUNCE_TIME = 500000)(clk, reset, key_pressed, key_valid, key, key_out);
  input clk, reset, key_pressed;
  input [3:0] key;
  
  output reg key_valid;
  output reg [3:0] key_out;
  
  reg [3:0] last_key;
  reg [18:0] counter;
  reg debounced;   
  
  initial begin
    {key_valid, key_out, last_key, counter, debounced}<=0;
  end
  always @(posedge clk) begin
      if(reset)
        {key_valid, key_out, last_key, counter, debounced}<=0;
      else begin
        key_valid<=0;
        if(last_key!=key || !key_pressed) begin
          last_key<=key;
          counter <= 0;
          debounced <= 0;
        end 
        else if(!debounced) begin
          if(counter >= DEBOUNCE_TIME-1) begin
            key_out <= key;
            key_valid <= 1;
            debounced <= 1;
            counter <= 0;
          end
          else
            counter<=counter+1;
        end
      end
  end
  
endmodule
