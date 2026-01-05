 module D_PHY_DRIVER (
    input TX_DDR_clk,
    input TX_BYTE_clk,
    input TX_rst,

    input TX_VALID,
    input [7:0] TX_BYTE_HS,
    input TX_REQ,


    output Dp, Dn,
    output TX_READY,
    output [2:0] D_PHY_TX_HS_STATE,
    output [1:0] D_PHY_TX_LP_STATE

);

    wire HS_Dn, HS_Dp, LP_Dp, LP_Dn;
    wire hs_en, hs_end;
    reg hs_en_reg, hs_end_reg;

    TX_LP_FSM tx_lp(
        .TX_BYTE_clk(TX_BYTE_clk),
        .TX_rst(TX_rst),
        .TX_REQ(TX_REQ),
        .Dp(LP_Dp),
        .Dn(LP_Dn),
        .TX_HS_END_DATA(hs_end),
        .TX_HS_EN(hs_en),
        .TX_LP_STATE(D_PHY_TX_LP_STATE)
    );

    HS_TX  tx_hs(
        .TX_DDR_clk(TX_DDR_clk),
        .TX_BYTE_clk(TX_BYTE_clk),
        .TX_rst(TX_rst),
        .TX_HS_EN(hs_en_reg),
        .TX_HS_END_DATA(hs_end_reg),
        .TX_HS_STATE(D_PHY_TX_HS_STATE),
        .TX_VALID(TX_VALID),
        .TX_BYTE_DATA(TX_BYTE_HS),
        .TX_HS_READY(TX_READY),
        .Dp(HS_Dp),
        .Dn(HS_Dn)
    );

    always @(posedge TX_DDR_clk, posedge TX_rst)begin
        if(TX_rst)begin
            hs_en_reg <=0;
            hs_end_reg <=0;
        end else begin
            hs_en_reg <= hs_en;
            hs_end_reg <= hs_end;
        end
    end

    assign Dp = hs_en_reg? HS_Dp : LP_Dp;
    assign Dn = hs_en_reg? HS_Dn : LP_Dn;
endmodule