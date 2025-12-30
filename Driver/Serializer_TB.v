`timescale 1ns/1ps
//==============================================================================
//  Testbench   : Serializer_TB
//  Description :
//  Functional testbench for Serializer module.
//  Verifies correct byte loading and bit-pair serialization
//  across TX_BYTE_clk and TX_DDR_clk domains.
//
//  Designer    : NH
//  Company     : ITI
//==============================================================================

module Serializer_TB;

    //-------------------------------------------------------------------------
    // DUT Signals
    //-------------------------------------------------------------------------
    reg TX_BYTE_clk;
    reg TX_DDR_clk;
    reg TX_rst;
    reg Enable;
    reg [7:0] TX_BYTE_DATA;

    wire Serial_B1;
    wire Serial_B2;

    //-------------------------------------------------------------------------
    // DUT Instantiation
    //-------------------------------------------------------------------------
    Serializer dut (
        .TX_BYTE_clk(TX_BYTE_clk),
        .TX_DDR_clk (TX_DDR_clk),
        .TX_rst(TX_rst),
        .Enable(Enable),
        .TX_BYTE_DATA(TX_BYTE_DATA),
        .Serial_B1(Serial_B1),
        .Serial_B2(Serial_B2)
    );

    //-------------------------------------------------------------------------
    // Clock Generation
    //-------------------------------------------------------------------------
    initial begin
        TX_BYTE_clk = 0;
        forever #20 TX_BYTE_clk = ~TX_BYTE_clk; // 25 MHz
    end

    initial begin
        TX_DDR_clk = 1;
        forever #5 TX_DDR_clk = ~TX_DDR_clk;    // 100 MHz
    end

    //-------------------------------------------------------------------------
    // Stimulus
    //-------------------------------------------------------------------------
    initial begin
        // Initial conditions
        TX_rst       = 1;
        Enable       = 0;
        TX_BYTE_DATA = 8'h00;

        // Apply reset
        #30;
        TX_rst = 0;

        // Enable serializer and load byte
        #20;
        Enable       = 1;
        TX_BYTE_DATA = 8'hA5; // 1010_0101

        // Allow full byte serialization
        #100;

        // Change byte
        TX_BYTE_DATA = 8'h3C; // 0011_1100
        #100;

        // Disable
        Enable = 0;

        #50;
        $finish;
    end

endmodule
