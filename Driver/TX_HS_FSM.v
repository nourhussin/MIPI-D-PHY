//==============================================================================
//  Module      : TX_HS_FSM
//  Description :
//  High-Speed Transmitter FSM for MIPI D-PHY TX lane.
//  Controls HS entry, sync, data transmission, and HS exit sequencing
//  in the byte-clock domain.
//
//  Designer    : NH
//  Company     : ITI
//
//  Notes       :
//  - Implements HS-ZERO, HS-SYNC, HS-DATA, and HS-TRAIL phases
//  - Timing is controlled using programmable counters
//  - Outputs valid bytes only during active HS transmission
//==============================================================================

module TX_HS_FSM (
    input  wire TX_DDR_clk,
    input  wire TX_rst,
    input  wire Enable,

    input  wire [7:0] TX_BYTE_DATA,
    input  wire TX_HS_END_DATA,

    output wire [2:0] TX_HS_STATE,

    output reg  [7:0] TX_BYTE_DATA_FSM,
    output reg TX_BYTE_DATA_VALID,
    output reg TX_HS_READY
);

    //--------------------------------------------------------------------------
    // Timing Parameters
    //--------------------------------------------------------------------------
    parameter integer T_HS_ZERO  = 4;
    parameter integer T_HS_TRAIL = 4;

    //--------------------------------------------------------------------------
    // FSM States
    //--------------------------------------------------------------------------
    localparam TX_HS_STOP  = 3'b000,
               TX_HS_ZERO  = 3'b001,
               TX_HS_SYNC  = 3'b010,
               TX_HS_DATA  = 3'b011,
               TX_HS_TRAIL = 3'b100;

    reg [2:0] current_state, next_state;

    reg [$clog2(T_HS_ZERO+1)-1:0]  zero_cnt;
    reg [$clog2(T_HS_TRAIL+1)-1:0] trail_cnt;

    assign TX_HS_STATE = current_state;

    //--------------------------------------------------------------------------
    // State Register
    //--------------------------------------------------------------------------
    always @(posedge TX_DDR_clk or posedge TX_rst) begin
        if (TX_rst)
            current_state <= TX_HS_STOP;
        else if (Enable)
            current_state <= next_state;
        else
            current_state <= TX_HS_STOP;
    end

    //--------------------------------------------------------------------------
    // Timing Counters
    //--------------------------------------------------------------------------
    always @(posedge TX_DDR_clk or posedge TX_rst) begin
        if (TX_rst) begin
            zero_cnt  <= 0;
            trail_cnt <= 0;
        end else begin
            if (current_state == TX_HS_ZERO)
                zero_cnt <= zero_cnt + 1'b1;
            else
                zero_cnt <= 0;

            if (current_state == TX_HS_TRAIL)
                trail_cnt <= trail_cnt + 1'b1;
            else
                trail_cnt <= 0;
        end
    end

    //--------------------------------------------------------------------------
    // Next-State and Output Logic
    //--------------------------------------------------------------------------
    always @(*) begin
        
        next_state = current_state;
        TX_BYTE_DATA_FSM = 8'h00;
        TX_BYTE_DATA_VALID = 1'b0;
        TX_HS_READY = 1'b0;

        case (current_state)

            TX_HS_STOP: begin
                if (Enable)
                    next_state = TX_HS_ZERO;
            end

            TX_HS_ZERO: begin
                TX_BYTE_DATA_VALID = 1'b1;
                if (zero_cnt == T_HS_ZERO-1)
                    next_state = TX_HS_SYNC;
            end

            TX_HS_SYNC: begin
                TX_BYTE_DATA_FSM   = 8'h1D;
                TX_BYTE_DATA_VALID = 1'b1;
                next_state = TX_HS_DATA;
            end

            TX_HS_DATA: begin
                TX_BYTE_DATA_FSM = TX_BYTE_DATA;
                TX_BYTE_DATA_VALID = 1'b1;
                TX_HS_READY = 1'b1;
                if (TX_HS_END_DATA)
                    next_state = TX_HS_TRAIL;
            end

            TX_HS_TRAIL: begin
                TX_BYTE_DATA_FSM = 8'hff;
                TX_BYTE_DATA_VALID = 1'b1;
                if (trail_cnt == T_HS_TRAIL-1)
                    next_state = TX_HS_STOP;
            end

            default: begin
                next_state = TX_HS_STOP;
            end
        endcase
    end

endmodule
