`timescale 1ns/1ps
//==============================================================================
//  Module      : TX_HS_FSM_TB
//  Description :
//  Testbench for TX_HS_FSM
//  Verifies HS entry, sync, data transmission, and HS exit sequencing
//  in the byte-clock domain.
//
//  Designer    : NH
//  Company     : ITI
//
//  Notes       :
//  - Drives Enable, TX_BYTE_DATA, and TX_HS_END_DATA
//  - Observes TX_HS_STATE, TX_BYTE_DATA_VALID, and TX_HS_READY
//  - Intended for waveform and FSM debug analysis
//==============================================================================

module TX_HS_FSM_TB;

    //----------------------------------------------------------------------
    // Parameters
    //----------------------------------------------------------------------
    parameter CLK_PERIOD = 10;

    //----------------------------------------------------------------------
    // DUT Signals
    //----------------------------------------------------------------------
    reg TX_DDR_clk;
    reg TX_rst;
    reg Enable;
    reg [7:0] TX_BYTE_DATA;
    reg TX_HS_END_DATA;

    wire [2:0] TX_HS_STATE;
    wire [7:0] TX_BYTE_DATA_FSM;
    wire TX_BYTE_DATA_VALID;
    wire TX_HS_READY;

    //----------------------------------------------------------------------
    // DUT Instantiation
    //----------------------------------------------------------------------
    TX_HS_FSM DUT (
        .TX_DDR_clk(TX_DDR_clk),
        .TX_rst(TX_rst),
        .Enable(Enable),
        .TX_BYTE_DATA(TX_BYTE_DATA),
        .TX_HS_END_DATA(TX_HS_END_DATA),
        .TX_HS_STATE(TX_HS_STATE),
        .TX_BYTE_DATA_FSM(TX_BYTE_DATA_FSM),
        .TX_BYTE_DATA_VALID(TX_BYTE_DATA_VALID),
        .TX_HS_READY(TX_HS_READY)
    );

    //----------------------------------------------------------------------
    // Clock Generation
    //----------------------------------------------------------------------
    always #(CLK_PERIOD/2) TX_DDR_clk = ~TX_DDR_clk;

    //----------------------------------------------------------------------
    // Initial Block
    //----------------------------------------------------------------------
    initial begin
        // Initialization
        TX_DDR_clk     = 1'b0;
        TX_rst         = 1'b1;
        Enable         = 1'b0;
        TX_BYTE_DATA   = 8'h00;
        TX_HS_END_DATA = 1'b0;

        #(CLK_PERIOD);
        TX_rst = 1'b0;

        //------------------------------------------------------------------
        // Test Case 1: Normal HS Transmission
        //------------------------------------------------------------------
        $display("---- Test Case 1: Normal HS Transmission ----");

        Enable = 1'b1;
        #(5*CLK_PERIOD); // wait for zero an sync

        send_byte(8'hA5);
        send_byte(8'h3C);
        send_byte(8'hF0);

        // End HS data
        TX_HS_END_DATA = 1'b1;
        #(CLK_PERIOD);
        TX_HS_END_DATA = 1'b0;

        #(10*CLK_PERIOD);

        //------------------------------------------------------------------
        // Test Case 2: Disable FSM
        //------------------------------------------------------------------
        $display("---- Test Case 2: Disable FSM ----");

        Enable = 1'b0;
        send_byte(8'h55);

        #(10*CLK_PERIOD);
        $stop;
    end

    //----------------------------------------------------------------------
    // Tasks
    //----------------------------------------------------------------------
    task send_byte;
        input [7:0] data;
        begin
            @(posedge TX_DDR_clk);
            TX_BYTE_DATA = data;
        end
    endtask

endmodule
