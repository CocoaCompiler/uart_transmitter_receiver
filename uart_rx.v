
module uart_rx(
    output reg [7:0] data_word,
  	output reg data_ready,
    input clk,
  	input rst,
    input rx_bit
    );
  parameter cycles_per_bit = 86; // floor(10MHz clk / 115200 baud rate) = 434 clock cycles per bit
    parameter half_cycles = 43; // floor((cycles_per_bit - 1 ) / 2)
    
    parameter S_IDLE      = 3'b000;
    parameter S_START     = 3'b001;
    parameter S_RECEIVE   = 3'b010;
    parameter S_STOP      = 3'b011; 
    parameter S_HOLD_DATA = 3'b100;
    
  	reg [2:0] rx_state = S_IDLE; 
    reg [3:0] word_index;
    reg [8:0] cycle_count; 
    always@(posedge clk) begin
      //$display("rx_state = %b, rx_bit=%b, cycle_count=%d, data_word=%b", rx_state, rx_bit, cycle_count, data_word); 
        case (rx_state)
            S_IDLE: begin
                cycle_count <= 0;
                word_index  <= 0; 
                data_word   <= 0; 
                if(rx_bit == 1'b0) begin
                    rx_state <= S_START;
                end   
            end
            
            S_START: begin
                if(cycle_count == half_cycles) begin
                    rx_state    <= S_RECEIVE; 
                    cycle_count <= 0; 
                end else begin
                    cycle_count <= cycle_count + 1; 
                end
            end
            
            S_RECEIVE: begin
                if(cycle_count == cycles_per_bit) begin
                    data_word[word_index] <= rx_bit;
                    word_index <= word_index + 1; 
                    cycle_count <= 0; 
                    if(word_index == 8) begin
                        rx_state <= S_STOP;
                    end
                end else begin
                    cycle_count <= cycle_count + 1; 
                end
            end
            
            S_STOP: begin
                if(cycle_count == cycles_per_bit) begin
                    rx_state <= S_HOLD_DATA;
                end else begin
                    cycle_count <= cycle_count + 1;
                end
            end
          
          	S_HOLD_DATA: begin
              if(rst) begin
              		rx_state <= S_IDLE;
                end
            end
        endcase
    end
    
endmodule
