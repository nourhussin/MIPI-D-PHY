`timescale 1ns/1ps
//==============================================================================
//  Module      : TX_LP_FSM
//  Description :
//  Low-Power Transmitter FSM for MIPI D-PHY TX lane.
//  Controls LP-to-HS request and preparation sequencing
//  in the byte-clock domain.
//
//  The FSM generates Dp/Dn signaling required to request
//  High-Speed transmission and asserts TX_HS_END_DATA
//  when returning to LP STOP state.
//
//  Designer    : NH
//  Company     : ITI
//
//  Notes       :
//  - TX_STOP    : LP-11 state (Dp=1, Dn=1)
//  - TX_HS_REQ  : HS request state (LP-01)
//  - TX_HS_PRPR : HS prepare state (LP-00)
//  - TX_REQ controls transition into and out of HS mode
//==============================================================================

module TX_LP_FSM (
    input  wire TX_BYTE_clk,
    input  wire TX_rst,
    input  wire TX_REQ,

    output reg  Dp,
    output reg  Dn,
    output reg  TX_HS_END_DATA
);

    //--------------------------------------------------------------------------
    // FSM States Encoding
    //--------------------------------------------------------------------------
    localparam TX_STOP    = 2'b00,
               TX_HS_REQ  = 2'b01,
               TX_HS_PRPR = 2'b10;

    reg [1:0] current_state, next_state;

    //--------------------------------------------------------------------------
    // State Register
    //--------------------------------------------------------------------------
    always @(posedge TX_BYTE_clk or posedge TX_rst) begin
        if (TX_rst)
            current_state <= TX_STOP;
        else
            current_state <= next_state;
    end

    //--------------------------------------------------------------------------
    // Next-State and Output Logic
    //--------------------------------------------------------------------------
    always @(*) begin
        // Default values
        Dp = 1'b1;
        Dn = 1'b1;
        TX_HS_END_DATA = 1'b0;
        next_state = current_state;

        case (current_state)

            TX_STOP: begin
                // LP-11
                if (TX_REQ)
                    next_state = TX_HS_REQ;
            end

            TX_HS_REQ: begin
                // LP-01 : HS request
                Dp = 1'b0;
                Dn = 1'b1;
                // wait one clock before HS prepare
                next_state = TX_HS_PRPR;
            end

            TX_HS_PRPR: begin
                // LP-00 : HS prepare
                Dp = 1'b0;
                Dn = 1'b0;
                if (!TX_REQ) begin
                    TX_HS_END_DATA = 1'b1;
                    next_state = TX_STOP;
                end
            end

            default: begin
                next_state = TX_STOP;
            end
        endcase
    end

endmodule
