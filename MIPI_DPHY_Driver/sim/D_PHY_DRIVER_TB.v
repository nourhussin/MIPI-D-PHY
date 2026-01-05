`timescale 1ns/1ps
/*******************************************************
* File Name   : tb_D_PHY_DRIVER.v
* Description : Testbench for D_PHY_DRIVER module
*
* Designer    : NH
* Company     : ITI
*
* Notes:
* - Generates TX_DDR_clk and TX_BYTE_clk
* - Tests reset, LP request, and HS data behavior
*******************************************************/

module D_PHY_DRIVER_TB;

    // --------------------------------------------------
    // DUT Inputs
    // --------------------------------------------------
    reg TX_DDR_clk;
    reg TX_BYTE_clk;
    reg TX_rst;

    reg TX_VALID;
    reg [7:0] TX_BYTE_HS;
    reg TX_REQ;

    // --------------------------------------------------
    // DUT Outputs
    // --------------------------------------------------
    wire Dp, Dn;
    wire TX_READY;
    wire [2:0] D_PHY_TX_HS_STATE;
    wire [1:0] D_PHY_TX_LP_STATE;

    // --------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------
    D_PHY_DRIVER dut (
        .TX_DDR_clk(TX_DDR_clk),
        .TX_BYTE_clk(TX_BYTE_clk),
        .TX_rst(TX_rst),
        .TX_VALID(TX_VALID),
        .TX_BYTE_HS(TX_BYTE_HS),
        .TX_REQ(TX_REQ),
        .Dp(Dp),
        .Dn(Dn),
        .TX_READY(TX_READY),
        .D_PHY_TX_HS_STATE(D_PHY_TX_HS_STATE),
        .D_PHY_TX_LP_STATE(D_PHY_TX_LP_STATE)
    );

    // --------------------------------------------------
    // Clock Generation
    // --------------------------------------------------
    // DDR clock (fast)
    always #2.5 TX_DDR_clk = ~TX_DDR_clk;   // 200 MHz

    // BYTE clock (slow)
    always #10 TX_BYTE_clk = ~TX_BYTE_clk; // 50 MHz

    // --------------------------------------------------
    // Stimulus
    // --------------------------------------------------
    initial begin
        // Initialize
        TX_DDR_clk  = 1;
        TX_BYTE_clk = 0;
        TX_rst      = 1;
        TX_VALID    = 0;
        TX_BYTE_HS  = 8'hff;
        TX_REQ      = 0;

        #40; TX_rst = 0;

        #20; TX_REQ = 1;

        #50;
        TX_VALID   = 1;
        TX_BYTE_HS = 8'hA5;
        #50;
        
        #20; TX_BYTE_HS = 8'h3C;
        #20; TX_BYTE_HS = 8'hff;
        #20; TX_BYTE_HS = 8'h11;
        #50;
        #20; TX_VALID = 0; TX_REQ = 0;
    end

    initial begin
        #1000;
        $stop;
    end
endmodule
