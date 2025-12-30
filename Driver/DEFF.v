module DEFF(
    input TX_DDR_clk,
    input TX_rst,
    input Enable,

    input Serial_B1,
    input Serial_B2,

    output Dp,
    output Dn
);
    reg q1, q2;

    always @(posedge TX_DDR_clk, posedge TX_rst) begin
        if(TX_rst)
            q1 <= 0;
        else if (Enable)
            q1 <= Serial_B1;
    end
    
    always @(negedge TX_DDR_clk, posedge TX_rst) begin
        if(TX_rst)
            q2 <= 0;
        else if (Enable)
            q2 <= Serial_B2;
    end
    assign Dp = Enable? (TX_DDR_clk? q1 : q2) : 1'bz;
    assign Dn = Enable? ~Dp : 1'bz;
endmodule