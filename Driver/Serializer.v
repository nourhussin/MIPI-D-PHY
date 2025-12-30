//==============================================================================
//  Module      : Serializer
//  Description :
//  Byte-to-bit serializer for MIPI D-PHY TX datapath.
//  Converts parallel byte data into two serial bit streams suitable for
//  DDR transmission.
//
//  - Byte data is latched in the TX_BYTE_clk domain
//  - Bits are shifted out in the TX_DDR_clk domain
//  - Serial_B1 and Serial_B2 represent rising and falling edge data paths
//
//  Designer    : NH
//  Company     : ITI
//==============================================================================

module Serializer (
    // Clocks and Reset
    input  wire TX_BYTE_clk,
    input  wire TX_DDR_clk,
    input  wire TX_rst,
    input  wire Enable,

    // Parallel Input
    input  wire [7:0] TX_BYTE_DATA,

    // Serial Outputs
    output reg Serial_B1,
    output reg Serial_B2
);

    //--------------------------------------------------------------------------
    // Internal Registers
    //--------------------------------------------------------------------------
    reg [7:0] byte_reg;
    reg Counter_Enable;
    reg [1:0] bit_counter;    // Selects bit pairs

    //--------------------------------------------------------------------------
    // Byte Register (Byte Clock Domain)
    //--------------------------------------------------------------------------
    always @(posedge TX_BYTE_clk or posedge TX_rst) begin
        if (TX_rst) begin 
            byte_reg <= 8'b0;
            Counter_Enable <= 0;
        end
        else if (Enable) begin 
            byte_reg <= TX_BYTE_DATA;
            Counter_Enable <= 1;
        end else begin
            byte_reg <= 8'b0;
            Counter_Enable <= 0;
        end
    end

    //--------------------------------------------------------------------------
    // Bit Counter (DDR Clock Domain)
    //--------------------------------------------------------------------------
    always @(posedge TX_DDR_clk or posedge TX_rst) begin
        if (TX_rst)
            bit_counter <= 2'b00;
        else if (Counter_Enable)
            bit_counter <= bit_counter + 1'b1;
        else
            bit_counter <= 2'b00;
    end

    //--------------------------------------------------------------------------
    // Bit Selection Logic
    //--------------------------------------------------------------------------
    always @(*) begin
        case (bit_counter)
            2'b00: begin
                Serial_B1 = byte_reg[0];
                Serial_B2 = byte_reg[1];
            end
            2'b01: begin
                Serial_B1 = byte_reg[2];
                Serial_B2 = byte_reg[3];
            end
            2'b10: begin
                Serial_B1 = byte_reg[4];
                Serial_B2 = byte_reg[5];
            end
            2'b11: begin
                Serial_B1 = byte_reg[6];
                Serial_B2 = byte_reg[7];
            end
            default: begin
                Serial_B1 = 1'b0;
                Serial_B2 = 1'b0;
            end
        endcase
    end

endmodule
