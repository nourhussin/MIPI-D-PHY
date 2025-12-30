`timescale 1ns/1ps

module DEFF_TB;

    // DUT signals
    reg TX_DDR_clk;
    reg TX_rst;
    reg Enable;
    reg Serial_B1;
    reg Serial_B2;

    wire Dp;
    wire Dn;

    // Instantiate DUT
    DEFF dut (
        .TX_DDR_clk(TX_DDR_clk),
        .TX_rst    (TX_rst),
        .Enable    (Enable),
        .Serial_B1 (Serial_B1),
        .Serial_B2 (Serial_B2),
        .Dp        (Dp),
        .Dn        (Dn)
    );

    // Clock generation: 100 MHz (10 ns period)
    initial begin
        TX_DDR_clk = 0;
        forever #5 TX_DDR_clk = ~TX_DDR_clk;
    end

    // Stimulus
    initial begin
        // Default values
        TX_rst     = 1;
        Enable     = 0;
        Serial_B1  = 0;
        Serial_B2  = 0;

        // Hold reset for a few cycles
        #20;
        TX_rst = 0;

        // Enable DDR sampling
        #22;
        Enable = 1;

        // Drive different data on posedge/negedge paths
        repeat (4) begin
            // Change B1 before posedge
                Serial_B1 = $random % 2;
            // Change B2 before negedge
                Serial_B2 = $random % 2;
            #10;
        end

        // Disable sampling
        #20;
        Enable = 0;

        // Change inputs while disabled (should not update q1/q2)
        #10;
        Serial_B1 = 1;
        Serial_B2 = 1;

        // Re-enable
        #10;
        Enable = 1;

        #30;
        $finish;
    end

    // Optional waveform monitoring
    initial begin
        $display("Time  clk rst En B1 B2 | qDp qDn");
        $monitor("%4t  %b   %b   %b  %b  %b |  %b   %b",
                 $time, TX_DDR_clk, TX_rst, Enable,
                 Serial_B1, Serial_B2, Dp, Dn);
    end

endmodule
