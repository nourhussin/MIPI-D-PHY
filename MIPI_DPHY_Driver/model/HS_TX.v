module HS_TX (
    input TX_DDR_clk,
    input TX_BYTE_clk,
    input TX_rst,
    input TX_HS_EN, // from LP
    input TX_HS_END_DATA, //from LP
    input TX_VALID,
    input [7:0] TX_BYTE_DATA,

    output [2:0] TX_HS_STATE,
    output TX_HS_READY,
    output Dp,Dn
);

    wire Serial_B1, Serial_B2;
    wire [7:0] internal_data;
    wire internal_data_valid;

    TX_HS_FSM hs_fsm (
        .TX_DDR_clk(TX_DDR_clk),
        .TX_rst(TX_rst),
        .Enable(TX_HS_EN),
        .TX_VALID(TX_VALID),
        .TX_BYTE_DATA(TX_BYTE_DATA),
        .TX_HS_END_DATA(TX_HS_END_DATA),
        .TX_HS_STATE(TX_HS_STATE),
        .TX_BYTE_DATA_FSM(internal_data),
        .TX_BYTE_DATA_VALID(internal_data_valid),
        .TX_HS_READY(TX_HS_READY)
    );
    Serializer serializer (
        .TX_BYTE_clk(TX_BYTE_clk),
        .TX_DDR_clk (TX_DDR_clk),
        .TX_rst(TX_rst),
        .Enable(TX_HS_EN),
        .TX_BYTE_DATA(internal_data),
        .Serial_B1(Serial_B1),
        .Serial_B2(Serial_B2)
    );
    DEFF deff (
        .TX_DDR_clk (TX_DDR_clk),
        .TX_rst(TX_rst),
        .Enable(TX_HS_EN),
        .Serial_B1(Serial_B1),
        .Serial_B2(Serial_B2),
        .Dp(Dp),
        .Dn(Dn)
    );
endmodule