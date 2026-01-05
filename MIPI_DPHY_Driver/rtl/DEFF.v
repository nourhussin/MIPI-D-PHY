//==============================================================================
//  Module      : DEFF
//  Description :
//  DDR Output Flip-Flop block for MIPI D-PHY TX datapath.
//  Samples serial data on both rising and falling edges of the TX DDR clock
//  and drives a differential DDR output.
//
//  Designer    : NH
//  Company     : ITI
//
//  Notes       :
//  - Serial_B1 is sampled on the rising edge of TX_DDR_clk
//  - Serial_B2 is sampled on the falling edge of TX_DDR_clk
//  - Outputs are tri-stated when Enable is deasserted
//==============================================================================

module DEFF (
    // Clock and Reset
    input  wire TX_DDR_clk,   // DDR transmit clock
    input  wire TX_rst,       // Asynchronous reset (active high)

    // Control
    input  wire Enable,       // Output enable

    // DDR Data Inputs
    input  wire Serial_B1,    // Rising-edge data
    input  wire Serial_B2,    // Falling-edge data

    // Differential Outputs
    output wire Dp,           // Positive output
    output wire Dn            // Negative output
);

    // Internal DDR registers
    reg q1;   // Rising-edge register
    reg q2;   // Falling-edge register

    // Rising-edge sampling
    always @(posedge TX_DDR_clk or posedge TX_rst) begin
        if (TX_rst)
            q1 <= 1'b0;
        else if (Enable)
            q1 <= Serial_B2;
    end

    // Falling-edge sampling
    always @(negedge TX_DDR_clk or posedge TX_rst) begin
        if (TX_rst)
            q2 <= 1'b0;
        else if (Enable)
            q2 <= Serial_B1;
    end

    // DDR output selection
    assign Dp = Enable ? (TX_DDR_clk ? q1 : q2) : 1'bz;
    assign Dn = Enable ? ~Dp : 1'bz;

endmodule
