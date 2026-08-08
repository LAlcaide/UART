`default_nettype none
module baud_generator(
input wire clk, reset, 
input wire [2:0] baud_value,
output reg baud_tick
);
  reg [8:0] divider, tick_counter;
  
  //Divider lookup
  always @(*) begin
    case(baud_value)
        3'd0: divider = 9'd326; // 9600 baud
        3'd1: divider = 9'd163; // 19200 baud
        3'd2: divider = 9'd81; // 38400 baud
        3'd3: divider = 9'd54; // 57600 baud
        3'd4: divider = 9'd27; // 115200 baud
        default: divider = 9'd326;
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
        tick_counter<=tick_counter + 1; 
      end
    end
  end
endmodule
