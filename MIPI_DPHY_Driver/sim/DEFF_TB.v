`timescale 1ns/1ps
//==============================================================================
//  Testbench   : DEFF_TB
//  Description :
//  Functional testbench for the DEFF DDR output flip-flop.
//  Verifies rising-edge and falling-edge data sampling, enable control,
//  reset behavior, and differential output operation.
//
//  Designer    : NH
//  Company     : ITI
//==============================================================================

module DEFF_TB;

    //-------------------------------------------------------------------------
    // DUT Interface Signals
    //-------------------------------------------------------------------------
    reg  TX_DDR_clk;
    reg  TX_rst;
    reg  Enable;
    reg  Serial_B1;
    reg  Serial_B2;

    wire Dp;
    wire Dn;

    //-------------------------------------------------------------------------
    // DUT Instantiation
    //-------------------------------------------------------------------------
    DEFF dut (
        .TX_DDR_clk (TX_DDR_clk),
        .TX_rst     (TX_rst),
        .Enable     (Enable),
        .Serial_B1  (Serial_B1),
        .Serial_B2  (Serial_B2),
        .Dp         (Dp),
        .Dn         (Dn)
    );

    //-------------------------------------------------------------------------
    // DDR Clock Generation (100 MHz)
    //-------------------------------------------------------------------------
    initial begin
        TX_DDR_clk = 1'b0;
        forever #5 TX_DDR_clk = ~TX_DDR_clk;
    end

    //-------------------------------------------------------------------------
    // Stimulus Process
    //-------------------------------------------------------------------------
    initial begin
        // Initial conditions
        TX_rst    = 1'b1;
        Enable    = 1'b0;
        Serial_B1 = 1'b0;
        Serial_B2 = 1'b0;

        // Apply reset
        #20;
        TX_rst = 1'b0;

        // Enable DDR operation
        #22;
        Enable = 1'b1;

        // Drive DDR data
        repeat (4) begin
            Serial_B1 = $random % 2;
            Serial_B2 = $random % 2;
            #10;
        end

        // Disable outputs
        #20;
        Enable = 1'b0;

        // Input changes while disabled
        #10;
        Serial_B1 = 1'b1;
        Serial_B2 = 1'b1;

        // Re-enable DDR operation
        #10;
        Enable = 1'b1;

        // End simulation
        #30;
        $finish;
    end

    initial begin
        $dumpfile("vcd/DEFF_TB.vcd");
        $dumpvars(0, DEFF_TB);
    end

endmodule
