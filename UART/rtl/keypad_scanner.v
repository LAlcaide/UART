`default_nettype none
module keypad_scanner #(parameter settle_cycles = 20)(
input wire clk, reset,
input wire [3:0] R,
output reg [3:0] C,
output wire key_valid,
output wire [3:0] key
);
  
  reg [3:0] keymap [0:3][0:3];
  reg [3:0] key_raw, R_sync0, R_sync;
  reg [4:0] settle_counter;
  reg [1:0] col, row;
  reg key_pressed, sampling, row_active, key_held;
  
  debounce DEBOUNCE_INST(
    .clk(clk), 
    .reset(reset), 
    .key_pressed(key_pressed), 
    .key(key_raw), 
    .key_valid(key_valid),
    .key_out(key)
  );
  
  //Synchronizer
  always @(posedge clk) begin
    R_sync0<=R;
    R_sync<=R_sync0;
  end
  
  //Key map
  initial begin 
    keymap[0][0]=4'd1; 
    keymap[0][1]=4'd4; 
    keymap[0][2]=4'd7; 
    keymap[0][3]=4'd10; 
    keymap[1][0]=4'd2; 
    keymap[1][1]=4'd5; 
    keymap[1][2]=4'd8; 
    keymap[1][3]=4'd0; 
    keymap[2][0]=4'd3; 
    keymap[2][1]=4'd6; 
    keymap[2][2]=4'd9; 
    keymap[2][3]=4'd11; 
    keymap[3][0]=4'd12; 
    keymap[3][1]=4'd13; 
    keymap[3][2]=4'd14; 
    keymap[3][3]=4'd15; 
  end
  
  //Settle counter
  always @(posedge clk) begin
    if(reset)
      {settle_counter, sampling}<=0;
    else begin
      if(!sampling)begin
        if(settle_counter>=settle_cycles-1)begin
          sampling<=1;
          settle_counter<=0;
        end
        else
          settle_counter<=settle_counter+5'd1;
      end
      else begin
        sampling<=0;
      end
    end   
  end  
  //Key dectection
  always @(posedge clk) begin
    if(reset) begin
      col <= 0;
      C   <= 4'b1110;
      key_held    <= 0;
      key_raw     <= 0;
      key_pressed <= 0;
    end
    else if(sampling) begin
      if(row_active && !key_held) begin
        key_raw<=keymap[col][row];
        key_held<=1;
      end
      case(col)
        2'd0: begin 
          C <= 4'b1101; 
          col <= 1; 
        end
        2'd1: begin  
          C <= 4'b1011; 
          col <= 2; 
        end
        2'd2: begin 
          C <= 4'b0111; 
          col <= 3; 
        end 
        2'd3: begin 
          C <= 4'b1110; 
          col <= 0;
          key_pressed<=key_held | row_active;
          key_held<=0; 
        end
      endcase
    end
  end
  
  //Row detection
  always @(*) begin
    row_active = ~&R_sync;
    casez(R_sync)
        4'b???0: row = 2'd0;
        4'b??01: row = 2'd1;
        4'b?011: row = 2'd2;
        4'b0111: row = 2'd3;
        default: row = 2'd0;
    endcase
  end
endmodule


