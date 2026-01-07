//==============================================================================
// RX_LP_CLK_FSM.v
// Low-Power Clock Lane FSM for MIPI D-PHY
//==============================================================================

module RX_LP_CLK_FSM #(
    parameter Tclk_term_en = 2
)(
    input  clk,
    input  rst,
    input  CLKDp,
    input  CLKDn,
    output reg HS_Enable
);

    localparam RXCLK_STOP    = 2'b00;
    localparam RXCLK_HS_RQST = 2'b01;
    localparam RXCLK_HS_PRPR = 2'b10;
    localparam RXCLK_HS_TERM = 2'b11;

    reg [1:0] lp_state, lp_next;
    integer prpr_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lp_state <= RXCLK_STOP;
            prpr_cnt <= 0;
        end else begin
            lp_state <= lp_next;
            if (lp_state == RXCLK_HS_PRPR)
                prpr_cnt <= prpr_cnt + 1;
            else
                prpr_cnt <= 0;
        end
    end

    always @(*) begin
        lp_next   = lp_state;
        HS_Enable = 1'b0;

        case (lp_state)
            RXCLK_STOP: begin
                if ({CLKDp, CLKDn} == 2'b01)
                    lp_next = RXCLK_HS_RQST;
            end

            RXCLK_HS_RQST: begin
                if({CLKDp, CLKDn} == 2'b00)
                    lp_next = RXCLK_HS_PRPR;
                else
                    lp_next = RXCLK_STOP;
            end

            RXCLK_HS_PRPR: begin
                if (prpr_cnt >= Tclk_term_en & {CLKDp,CLKDn} == 2'b00)
                    lp_next = RXCLK_HS_TERM;
            end

            RXCLK_HS_TERM: begin
                HS_Enable = 1'b1;
                if ({CLKDp, CLKDn} == 2'b11)
                    lp_next = RXCLK_STOP;
            end
        endcase
    end

endmodule
