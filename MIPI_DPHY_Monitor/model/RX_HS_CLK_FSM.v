//==============================================================================
// RX_HS_CLK_FSM.v
// High-Speed Clock Lane FSM for MIPI D-PHY
//==============================================================================

module RX_HS_CLK_FSM #(
    parameter Tclk_miss = 10
)(
    input  clk,
    input  rst,
    input  HS_Enable,
    input  CLKDp,
    input  CLKDn,
    output reg RX_HS_CLK
);

    localparam HS_STOP = 2'b00;
    localparam HS_CLK  = 2'b01;
    localparam HS_END  = 2'b10;

    reg [1:0] hs_state, hs_next;
    integer hs_timeout;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hs_state   <= HS_STOP;
            hs_timeout <= 0;
        end else begin
            hs_state <= hs_next;

            if (hs_state == HS_CLK) begin
                hs_timeout <= hs_timeout + 1;
            end else begin
                hs_timeout <= 0;
            end
                
        end
    end

    always @(*) begin
        hs_next = hs_state;
        RX_HS_CLK = 0;
        case (hs_state)
            HS_STOP: begin
                if (HS_Enable)
                    hs_next = HS_CLK;
            end
            HS_CLK: begin
                RX_HS_CLK = CLKDp;
                if(!HS_Enable)
                    hs_next = HS_STOP;

                else if ((hs_timeout >= Tclk_miss))
                    hs_next = HS_END;
            end
            HS_END: begin
                if(!HS_Enable)
                    hs_next = HS_STOP;
                else if (({CLKDp, CLKDn} == 2'b11))
                    hs_next = HS_STOP;
            end
        endcase
    end

endmodule
