`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/30/2020 09:52:43 AM
// Design Name: 
// Module Name: reg_file
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


module reg_file
    #(parameter ADDR_WIDTH = 3, DATA_WIDTH = 8)             
    (                                                                                                     
        input logic clk,
        input logic w_en,
        input logic [ADDR_WIDTH - 1: 0] r_addr, // reading address
        input logic [ADDR_WIDTH - 1: 0] w_addr, // writing address
        input logic [(2*DATA_WIDTH) - 1: 0] w_data,                         //write data is 2x larger than read data, changed
        output logic [DATA_WIDTH - 1: 0] r_data
    );
    
    // signal declaration
    logic [DATA_WIDTH - 1: 0] memory [0: 2 ** ADDR_WIDTH - 1];   //keep memory at 8bits
    logic [DATA_WIDTH - 1: 0] high_byte_data;                               //added, needed to seperate wr_data into 2 seperate bytes for rd operation to work
    logic [DATA_WIDTH - 1: 0] low_byte_data;                                //added
    
    assign {high_byte_data, low_byte_data} = w_data;                      //added, concatenation (splitting vectors into smaller vectors)
                                                                                                          //high_byte = MSByte of w_data 
    // write operation                                                                          //low_byte = LSByte of w_data
    always_ff @(posedge clk)
    begin
        if (w_en)
        begin
            memory[w_addr] <= low_byte_data;                                    //added, did in reverse so that LSByte comes out first
            memory[w_addr + 1] <= high_byte_data;                            //added
        end
    end
            
    // read operation
    assign r_data = memory[r_addr];         //keep
endmodule
