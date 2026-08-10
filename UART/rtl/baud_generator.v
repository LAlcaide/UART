`default_nettype none
module baud_generator #(parameter baud_9600 = 9'd326, baud_19200 = 9'd163, baud_38400 = 9'd81, baud_57600 = 9'd54, baud_115200 = 9'd27)(
input wire clk, reset, 
input wire [2:0] baud_value,
output reg baud_tick
);
  reg [8:0] divider, tick_counter;
  
  //Divider lookup
  always @(*) begin
    case(baud_value)
        3'd0: divider = baud_9600;
        3'd1: divider = baud_19200;
        3'd2: divider = baud_38400;
        3'd3: divider = baud_57600;
        3'd4: divider = baud_115200;
        default: divider = baud_9600;
    endcase
  end
  
  //Tick counter
  always @(posedge clk) begin
    if(reset)
      {tick_counter, baud_tick}<=0;
    else begin
      if(tick_counter>=divider-1) begin
        baud_tick<=1;
        tick_counter<=0;  
      end
      else begin
        baud_tick<=0;
        tick_counter<=tick_counter + 9'd1; 
      end
    end
  end
endmodule
