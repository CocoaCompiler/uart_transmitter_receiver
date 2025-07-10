module uart_tx(
    output reg tx_bit,
    output reg tx_active,
    output reg tx_done,
    input clk,
    input [7:0] data_word,
    input enable 
    );
  parameter cycles_per_bit = 86; // floor(10MHz clk / 115200 baud rate) = 86 clock cycles per bit
    
    parameter S_IDLE  = 2'b00;
    parameter S_START = 2'b01;
    parameter S_TRANSMIT = 2'b10;
    parameter S_STOP = 2'b11; 
   
    reg [1:0] tx_state = S_IDLE; 
    reg [3:0] word_index;
    reg [8:0] cycle_count; 
    always @(posedge clk) begin
        //$display("tx_state = %b, cycle_count=%d", tx_state, cycle_count); 
        case (tx_state) 
            S_IDLE : begin
                tx_bit      <= 1'b1; 
                tx_active   <= 1'b0;
                tx_done     <= 1'b0;
                word_index  <= 0; 
                cycle_count <= 0; 
                
                if(enable) begin
                    tx_state  <= S_START;
                    tx_active <= 1'b1; 
                end
            end
            
            S_START : begin
                tx_bit <= 0; 
                if(cycle_count == cycles_per_bit) begin
                    tx_state    <= S_TRANSMIT;
                    cycle_count <= 0; 
                end else begin
                    cycle_count <= cycle_count + 1;  
                end
            end
            
            S_TRANSMIT : begin
                tx_bit <= data_word[word_index];
                if(cycle_count == cycles_per_bit) begin
                    if(word_index == 7) begin
                        tx_state <= S_STOP;
                    end else begin
                        word_index  <= word_index + 1; 
                    end
                    
                    cycle_count <= 0; 
                end else begin
                    cycle_count <= cycle_count + 1;  
                end
            end
            
            S_STOP : begin
                tx_bit <= 1'b1; 
                if(cycle_count == cycles_per_bit) begin
                    tx_done     <= 1'b1;
                    tx_active   <= 1'b0; 
                    tx_state    <= S_IDLE; 
                    cycle_count <= 0; 
                end else begin
                    cycle_count <= cycle_count + 1;  
                end
            end
        endcase
    end
    
endmodule