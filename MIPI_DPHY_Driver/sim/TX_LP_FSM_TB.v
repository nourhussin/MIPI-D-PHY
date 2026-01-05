`timescale 1ns/1ps
//==============================================================================
//  Module      : TX_LP_FSM_TB
//  Description :
//  Testbench for TX_LP_FSM
//  Verifies LP-to-HS request, HS prepare, and return to LP STOP.
//
//  Designer    : NH
//  Company     : ITI
//
//  Notes       :
//  - Drives TX_REQ to simulate HS entry and exit
//  - Observes Dp, Dn, and TX_HS_END_DATA
//  - Intended for waveform and FSM debug analysis
//==============================================================================

module TX_LP_FSM_TB;

    //----------------------------------------------------------------------
    // Parameters
    //----------------------------------------------------------------------
    parameter CLK_PERIOD = 10;

    //----------------------------------------------------------------------
    // DUT Signals
    //----------------------------------------------------------------------
    reg  TX_BYTE_clk;
    reg  TX_rst;
    reg  TX_REQ;

    wire Dp;
    wire Dn;
    wire TX_HS_END_DATA;

    //----------------------------------------------------------------------
    // DUT Instantiation
    //----------------------------------------------------------------------
    TX_LP_FSM DUT (
        .TX_BYTE_clk(TX_BYTE_clk),
        .TX_rst(TX_rst),
        .TX_REQ(TX_REQ),
        .Dp(Dp),
        .Dn(Dn),
        .TX_HS_END_DATA (TX_HS_END_DATA)
    );

    //----------------------------------------------------------------------
    // Clock Generation
    //----------------------------------------------------------------------
    always #(CLK_PERIOD/2) TX_BYTE_clk = ~TX_BYTE_clk;

    //----------------------------------------------------------------------
    // Initial Block
    //----------------------------------------------------------------------
    initial begin
        // Initialization
        TX_BYTE_clk = 1'b1;
        TX_rst      = 1'b1;
        TX_REQ      = 1'b0;
        #(2*CLK_PERIOD);
        TX_rst = 1'b0;

        //------------------------------------------------------------------
        // Test Case 1: Enter HS Mode
        //------------------------------------------------------------------
        $display("---- Test Case 1: LP to HS Request ----");

        TX_REQ = 1'b1;
        #(5*CLK_PERIOD);

        //------------------------------------------------------------------
        // Test Case 2: Exit HS Mode
        //------------------------------------------------------------------
        $display("---- Test Case 2: HS to LP STOP ----");

        TX_REQ = 1'b0;
        #(5*CLK_PERIOD);
        $stop;
    end

endmodule
