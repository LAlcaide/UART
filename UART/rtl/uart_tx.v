`default_nettype none
module uart_tx(
    input  wire clk, reset, baud_tick,
    input  wire [7:0] data,
    input  wire tx_start,
    output reg  tx, tx_busy
);

  reg [2:0] bit_index;
  reg [3:0] tick_count;
  reg [7:0] data_latched;
  reg [1:0] state;
  
  //TX STATES
  localparam
  IDLE = 2'd0,
  START = 2'd1,
  SENDING_DATA = 2'd2,
  STOP = 2'd3; 
  
  always @(posedge clk) begin
    if (reset) begin
      {state, tx_busy, bit_index, tick_count, data_latched} <= 0;
      tx<=1;
    end
    else begin
      case (state)
        IDLE: begin
          tx<=1;
          tx_busy<=0;
          if(tx_start) begin
            data_latched<=data;
            tx_busy<=1;
            tx<=0;
            tick_count<=0;
            state<=START;
          end
        end
        START: begin
          if(baud_tick) begin
            if(tick_count >= 15) begin
              tick_count<=0;
              bit_index<=0;
              tx<=data_latched[0];
              state<=SENDING_DATA;
            end
            else
              tick_count<=tick_count + 1;
          end
        end
        SENDING_DATA: begin
          if(baud_tick) begin
            if(tick_count >= 15) begin
              tick_count<=0;
              if (bit_index == 7) begin
                tx<=1;
                state<=STOP;
              end
              else begin
                bit_index <= bit_index + 1;
                tx<=data_latched[bit_index + 1];
              end 
            end
            else
              tick_count<=tick_count + 1;
          end
        end
        STOP: begin
          if(baud_tick) begin
            if(tick_count >= 4'd15) begin
              tick_count <= 0;
              state      <= IDLE;
              tx_busy    <= 0;
            end
            else
              tick_count <= tick_count + 1;
          end
        end
      endcase
    end
  end
endmodule
