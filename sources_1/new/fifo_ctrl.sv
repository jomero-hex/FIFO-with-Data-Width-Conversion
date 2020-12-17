`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2020 09:53:48 AM
// Design Name: 
// Module Name: fifo_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo_ctrl
    #(parameter ADDR_WIDTH = 3)                        
    (
        input logic clk, reset,
        input logic wr, rd,
        output logic full, empty,
        output logic [ADDR_WIDTH - 1: 0] w_addr,
        output logic [ADDR_WIDTH - 1: 0] r_addr
    );
    
    logic [ADDR_WIDTH - 1: 0] wr_ptr, wr_ptr_next;
    logic [ADDR_WIDTH - 1: 0] rd_ptr, rd_ptr_next;
    
    logic full_next;
    logic empty_next;
    
    // registers for status and read/write pointers
    always_ff @(posedge clk, posedge reset)
    begin
        if(reset)
        begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            full <= 1'b0;
            empty <= 1'b1;
        end
        else
        begin
            wr_ptr <= wr_ptr_next;                  
            rd_ptr <= rd_ptr_next;
            full <= full_next;
            empty <= empty_next;
        end
    end
    
    always_comb
    begin
        // default is to keep old (current) values
        wr_ptr_next = wr_ptr;
        rd_ptr_next = rd_ptr;
        full_next = full;
        empty_next = empty;
        unique case({wr, rd})
            2'b01: // read
            begin
                if (~empty)
                begin
                    rd_ptr_next = rd_ptr + 1;
                    full_next = 1'b0;
                    if (rd_ptr_next == wr_ptr - 1 )      // when reading the last stored value
                        empty_next = 1'b1;                   //added '-1' LATE **********************
                end                
            end
            2'b10: // write
            begin
                if (~full)
                begin                                                                     //change +1 to +2 
                    wr_ptr_next = wr_ptr + 2;                                // reg_file is writing one byte to wr_ptr and the other byte to wr_ptr+1 
                    empty_next = 1'b0;                                           //hence +2 is needed here for correct wr_ptr in memory        
                    if (wr_ptr_next == rd_ptr+1)                  //added + 1 late********
                        full_next = 1'b1;
                end
            end
            2'b11: // read and write simultaneously 
            begin
                // This case is incorrectly handled in the book
                // When the buffer is empty, there is no need to move the pointers
                // this is to gaurantee the last value written will be available
                // on the data output port
                // otherwise, it is okay to move the pointers
                if (empty)
                begin
                    wr_ptr_next = wr_ptr + 2;                                  //added +1, rd and wr, only incraese by 1
                    rd_ptr_next = rd_ptr + 1;  
                    empty_next = 1'b0;                                             //add this line because we are writing 16bits and outputting 8 bits                                                                                                         
                end                                                                         //original code's empty flag was kept at 1, but it is not empty. there is still half the data remaning in memory
                else
                begin
                    wr_ptr_next = wr_ptr + 2;                                  //changed +1 to +2 (why? same as stated earlier)
                    rd_ptr_next = rd_ptr + 1;
                end
            end
            default: ; // case 2'b00; null statements; no op
        endcase       
    end
    
    // outputs
    assign w_addr = wr_ptr;
    assign r_addr = rd_ptr;
endmodule
