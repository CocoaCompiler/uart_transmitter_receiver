
module tb_uart_tx_rx();
// Clock:     10MHz
// Baud rate: 115200

    logic clk; 
    logic enable; 
  	logic rst;
    logic [7:0] data_word_in; 
    
    logic tx_bit; 
    logic tx_active;
    logic tx_done; 
    logic [7:0] data_word_out; 
    
    uart_tx uart_tx_dut (
        .tx_bit(tx_bit),
        .tx_active(tx_active),
        .tx_done(tx_done),
        .clk(clk),
        .data_word(data_word_in),
        .enable(enable)
    );
    
    uart_rx uart_rx_dut (
        .data_word(data_word_out),
        .clk(clk),
     	.rst(rst),
        .rx_bit(tx_bit)
    );
    
    initial begin
        clk = 0; 
        forever #50 clk = ~clk; // 100ns period 
    end
    
    initial begin
      	rst = 0;
        enable = 0; 
        #20; 
        
        enable = 1; 
        data_word_in = 8'hA5;
        
        @(posedge tx_done);
        $display("Transmission complete at time=%0t", $time); 
        
      	enable = 0; 
      
        #18000; // ~ 86 clock cycles per bit * 10 bits * 20ns clock period
        
        assert(data_word_out == data_word_in)
            else $error("ERROR MISMATCH: data_word_out = 0x%h, data_word_in = 0x%h", data_word_out, data_word_in);
      $display("data_word_out = %b, data_word_in = %b", data_word_out, data_word_in);
        rst = 1; 
        $display("Test complete at time=%0t", $time); 
        $finish;
       
    end
endmodule
