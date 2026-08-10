`default_nettype none
module uart_top(
  input wire clk, reset,
  input wire [3:0] R,
  output wire [3:0] C,
  input wire rx,
  output wire tx,
  output wire parser_error, rx_frame_error
);
  // For keypad_scanner
  wire [3:0] key;
  wire key_valid;

  // For baud parser
  wire [2:0] baud_value;

  //For controller
  wire [2:0] active_baud;

  //For uart tx
  wire tx_busy;

  //For baud generator
  wire baud_tick;

  //For uart rx
  wire [7:0] rx_data;
  wire rx_data_valid;
  
  
  keypad_scanner KEYPAD_INST (
    .clk(clk), .reset(reset),
    .R(R), .C(C),
    .key_valid(key_valid), .key(key)
  );

  baud_parser PARSER_INST (
    .clk(clk), .reset(reset),
    .key_valid(key_valid), .key(key),
    .error(parser_error),
    .baud_value(baud_value)
  );
  
  controller CTRL_INST (
    .clk(clk), .reset(reset),
    .baud_value(baud_value),
    .tx_busy(tx_busy),
    .active_baud(active_baud)
  );

  baud_generator BAUD_GEN_INST (
    .clk(clk), .reset(reset),
    .baud_value(active_baud),
    .baud_tick(baud_tick)
  );
  
  uart_rx RX_INST (
    .clk(clk), .reset(reset),
    .baud_tick(baud_tick),
    .rx(rx),
    .data(rx_data),
    .data_valid(rx_data_valid),
    .frame_error(rx_frame_error)
  );

  uart_tx TX_INST (
    .clk(clk), .reset(reset),
    .baud_tick(baud_tick),
    .data(rx_data),            // loopback: echo whatever was just received
    .tx_start(rx_data_valid),  // start transmitting the instant a byte finishes receiving
    .tx(tx),
    .tx_busy(tx_busy)
  );
endmodule
