//==============================================================================
// RX_CLK_LANE.v
// Top module connecting LP and HS FSMs
//==============================================================================

module RX_CLK_LANE #(
    parameter Tclk_term_en = 2,
    parameter Tclk_miss    = 10
)(
    input  clk,
    input  rst,
    input  CLKDp,
    input  CLKDn,
    output RX_HS_CLK
);

    wire HS_Enable;

    RX_LP_CLK_FSM #(
        .Tclk_term_en(Tclk_term_en)
    ) lp_fsm_inst (
        .clk(clk),
        .rst(rst),
        .CLKDp(CLKDp),
        .CLKDn(CLKDn),
        .HS_Enable(HS_Enable)
    );

    RX_HS_CLK_FSM #(
        .Tclk_miss(Tclk_miss)
    ) hs_fsm_inst (
        .clk(clk),
        .rst(rst),
        .HS_Enable(HS_Enable),
        .CLKDp(CLKDp),
        .CLKDn(CLKDn),
        .RX_HS_CLK(RX_HS_CLK)
    );

endmodule
