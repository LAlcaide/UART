`default_nettype none
module uart_rx(
    input  wire clk, reset, baud_tick, rx,
    output reg [7:0]  data,
    output reg data_valid, frame_error
);
    reg rx_sync0, rx_sync, rx_prev;
    reg [3:0] tick_count;
    reg [2:0] bit_index;
    reg [7:0] rx_shift;
    reg [1:0] state;

    localparam 
    IDLE = 2'd0,
    START_CONFIRM = 2'd1,
    DATA = 2'd2,
    STOP = 2'd3;

    // Synchronizer
    always @(posedge clk) begin
        rx_sync0<=rx;
        rx_sync <=rx_sync0;
    end

    always @(posedge clk) begin
        if(reset) begin
            state<=IDLE;
            {tick_count, bit_index, data_valid, rx_shift, data, frame_error}<=0;
            rx_prev<=1;
        end
        else begin
            data_valid<=0;
            frame_error<=0;
            rx_prev<=rx_sync;

            case(state)
                IDLE: begin
                    if(rx_prev && !rx_sync) begin
                        tick_count<=0;
                        state<=START_CONFIRM;
                    end
                end

                START_CONFIRM: begin
                    if(baud_tick) begin
                        if(tick_count >= 7) begin
                            if(!rx_sync) begin
                                tick_count<=0;
                                bit_index<=0;
                                state<= DATA;
                            end
                            else
                                state<=IDLE;
                        end
                        else
                            tick_count<=tick_count + 1;
                    end
                end

                DATA: begin
                    if(baud_tick) begin
                        if(tick_count >= 15) begin
                            tick_count<=0;
                            rx_shift[bit_index]<=rx_sync;
                            if(bit_index == 7)
                                state<=STOP;
                            else
                                bit_index<=bit_index + 1;
                        end
                        else
                            tick_count<=tick_count + 1;
                    end
                end

                STOP: begin
                    if(baud_tick) begin
                        if(tick_count >= 15) begin
                            tick_count<=0;
                            if(rx_sync) begin
                              data<=rx_shift;
                              data_valid<=1;
                            end
                            else
                              frame_error<=1;
                            state<=IDLE;
                        end
                        else
                            tick_count<= tick_count + 1;
                    end
                end
            endcase
        end
    end
endmodule
