`default_nettype none
module controller(
input wire clk, reset,
input wire [2:0] baud_value,
input wire tx_busy, 
output reg  [2:0] active_baud
);
    reg [2:0] baud_value_prev;
    reg [2:0] pending_baud_value;
    reg pending_valid;

    wire baud_changed = (baud_value != baud_value_prev);

    always @(posedge clk) begin
        if(reset)
            {baud_value_prev, pending_baud_value, pending_valid , active_baud}<= 0;
        else begin
            baud_value_prev<=baud_value;

            if(baud_changed) begin
                if(tx_busy) begin
                    // capture, defer application, last one wins by construction
                    pending_baud_value<=baud_value;
                    pending_valid<=1;
                end
                else
                    active_baud<=baud_value;
            end
            else if(!tx_busy && pending_valid) begin
                active_baud<=pending_baud_value;
                pending_valid<=0;
            end
        end
    end
endmodule
