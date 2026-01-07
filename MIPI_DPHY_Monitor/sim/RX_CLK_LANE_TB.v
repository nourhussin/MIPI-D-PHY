`timescale 1ns/1ps

module RX_CLK_LANE_TB;

    parameter Tclk_term_en = 2;
    parameter Tclk_miss    = 4;

    reg clk;
    reg rst;
    reg CLKDp;
    reg CLKDn;
    wire RX_HS_CLK;

    RX_CLK_LANE #(
        .Tclk_term_en(Tclk_term_en),
        .Tclk_miss(Tclk_miss)
    ) dut (
        .clk(clk),
        .rst(rst),
        .CLKDp(CLKDp),
        .CLKDn(CLKDn),
        .RX_HS_CLK(RX_HS_CLK)
    );


    // Clock generation: 50MHz
    initial clk = 0;
    always #10 clk = ~clk;

    initial begin
        $dumpfile("vcd/RX_CLK_LANE_TB.vcd");
        $dumpvars(0, RX_CLK_LANE_TB);
    end

    initial begin
        rst   = 1;
        CLKDp = 1;
        CLKDn = 1;

        #30 rst = 0; // Release reset


        #20 CLKDp = 0; CLKDn = 1; // 01 -> request HS
        #20 CLKDp = 0; CLKDn = 0; // 00 -> prepare HS
        # (Tclk_term_en*20) ;      // Wait for Tclk_term_en cycles
        #20 CLKDp = 1; CLKDn = 1; // back to stop


        #20 CLKDp = 0; CLKDn = 1;
        #20 CLKDp = 0; CLKDn = 0;
        repeat (Tclk_term_en) #20;
        CLKDn = ~CLKDp;
        repeat (40) begin
            #5; CLKDp = ~ CLKDp; CLKDn = ~CLKDn;
        end
        CLKDp = 1; CLKDn = 1;
        #100;


        CLKDp = 0; CLKDn = 1;
        #20 CLKDp = 0; CLKDn = 0;
        repeat (Tclk_term_en) #20;
        # (Tclk_miss*20 + 20);
        #40;
        CLKDp = 1; CLKDn = 1;


        #1000;
        $finish;
    end

endmodule
