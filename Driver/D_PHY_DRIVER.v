module D_PHY_DRIVER (

    input TX_LP_clk,
    input TX_DDR_clk,
    input TX_BYTE_clk,
    input TX_rst,

    input TX_VALID_HS,
    input [7:0] TX_BYTE_HS,
    input TX_REQ_HS,
    input TX_LP_EN,

    output Dp, Dn,
    output TX_READY_HS,
    output [2:0] D_PHY_TX_STATE

);

/*
    LP 
    HS 
    dual edge
    serilizer
    mux
*/

endmodule