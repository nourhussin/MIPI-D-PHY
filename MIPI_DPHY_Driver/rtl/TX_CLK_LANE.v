module CLKHSTX(HS_BYTE_CLK,enable,TxRst,TxDDR_CLK,TxRequestHS,
               TX_ULPS_Exit,TX_ULPS_CLK,DATA_LANE_STP_S,
               STOP_STATE,ULPS_ACTIVE_NOT,DATA_LANE_START,CLK_DP,CLK_DN);

input HS_BYTE_CLK,enable,TxRst,TxDDR_CLK,TxRequestHS,
      TX_ULPS_Exit,TX_ULPS_CLK,DATA_LANE_STP_S;

output reg STOP_STATE,ULPS_ACTIVE_NOT,DATA_LANE_START,CLK_DP,CLK_DN;

localparam TX_HS_STOP    = 0,
           TX_HS_RQ      = 1,
           TX_HS_PREPARE = 2,
           TX_HS_GO      = 3,
           TX_HS_PRE     = 4,
           TX_HS_CLK     = 5,
           TX_HS_POST    = 6,
           TX_HS_TRAIL   = 7,
           TX_HS_EXIT    = 8,
           TX_ULPS_Rqst  = 9,
           TX_ULPS       = 10,
           TX_ULPS_EXIT  = 11 ;

reg [5:0]ps,ns;
reg [4:0]Time_to_wait;
reg start ;
wire done ;

parameter TLPX         = 1 ;
parameter TCLK_PREPARE = 10;
parameter CLK_ZERO     = 1 ;
parameter CLK_PRE      = 1 ;
parameter HS_POST      = 1 ;
parameter HS_TRAIL     = 1 ;
parameter CLK_EXIT     = 1 ;
parameter WAKEUP       = 1 ;

Timer TxClkLaneTimer (.reset(TxRst),.start(start),.time_to_move(Time_to_wait),.clk(HS_BYTE_CLK),.done(done));

always@(posedge HS_BYTE_CLK or posedge TxRst)begin

    if(TxRst)begin
        ps <= TX_HS_STOP;
    end
    else begin
        ps <= ns ;
    end

end

//UPDATE PS
always@* begin

    case (ps)
        TX_HS_STOP:begin
            if(TxRequestHS && enable)begin
                ns = TX_HS_RQ ;
            end
            else if(TX_ULPS_CLK) begin
                ns = TX_ULPS_Rqst ;
            end
            else begin
                ns = TX_HS_STOP ;
            end

        end
        TX_ULPS_Rqst:begin

            start = 1 ;
            Time_to_wait = TLPX ;
            // enable time for 1 cycle TLPX 
            if(done)begin
                ns = TX_ULPS ;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_ULPS_Rqst ;

            end
        end
        TX_ULPS:begin

            if(TX_ULPS_EXIT)begin
                ns = TX_ULPS_EXIT ;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_ULPS ;

            end

        end
        TX_ULPS_EXIT:begin

            start = 1 ;
            Time_to_wait = WAKEUP ;
            // enable time for 1 cycle TLPX 
            if(done)begin
                ns =  TX_HS_STOP;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_ULPS_EXIT ;

            end

        end
        TX_HS_RQ:begin
            start = 1 ;
            Time_to_wait = TLPX ;
            // enable time for 1 cycle TLPX 
            if(done)begin
                ns = TX_HS_PREPARE ;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_HS_RQ ;

            end

        end
        TX_HS_PREPARE:begin

            start = 1 ;
            Time_to_wait = TCLK_PREPARE ;
            // enable time for 1 cycle TLPX 
            if(done)begin
                ns = TX_HS_GO ;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_HS_PREPARE ;

            end

        end
        TX_HS_GO:begin

            start = 1 ;
            Time_to_wait = CLK_ZERO ;
            // enable time for 1 cycle TLPX 
            if(done)begin
                ns = TX_HS_PRE ;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_HS_GO ;

            end

        end
        TX_HS_PRE:begin

            start = 1 ;
            Time_to_wait = CLK_PRE ;
            // enable time for 1 cycle TLPX 
            if(done)begin
                ns =  TX_HS_CLK;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_HS_PRE ;

            end

        end
        TX_HS_CLK:begin

            if(TxRequestHS == 0)begin // another condition here???
                ns =  TX_HS_POST;
            end
            else begin
                ns = TX_HS_CLK ;

            end

        end
        TX_HS_POST:begin


            start = 1 ;
            Time_to_wait = HS_POST ;
            // enable time for 1 cycle TLPX 
            if(done)begin
                ns =  TX_HS_TRAIL;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_HS_POST ;

            end

        end
        TX_HS_TRAIL:begin


            start = 1 ;
            Time_to_wait = HS_TRAIL ;
            // enable time for 1 cycle TLPX 
            if(done)begin
                ns =  TX_HS_EXIT;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_HS_TRAIL ;

            end

        end 
        TX_HS_EXIT:begin

            start = 1 ;
            Time_to_wait = CLK_EXIT ;
            // enable time for 1 cycle TLPX 
            if(done)begin
                ns =  TX_HS_STOP;
                start = 0; // to reset timer 
            end
            else begin
                ns = TX_HS_EXIT ;

            end

        end
        default:begin
            ns = TX_HS_STOP ;

        end

    endcase


    
end

//UPDATE OUTPUT

always@* begin

    case (ps)
        TX_HS_STOP:begin
            //send LP11

            CLK_DP = 1;
            CLK_DN = 1;
            STOP_STATE = 1;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;
        end
        TX_ULPS_Rqst:begin
           //send LP10

            CLK_DP = 1;
            CLK_DN = 0;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;
        end
        TX_ULPS:begin

           //send LP00

            CLK_DP = 0;
            CLK_DN = 0;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 1 ;
            DATA_LANE_START = 0 ;

        end
        TX_ULPS_EXIT:begin

           //send LP10

            CLK_DP = 1;
            CLK_DN = 0;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0;
            DATA_LANE_START = 0 ;


        end
        TX_HS_RQ:begin
            //send LP01

            CLK_DP = 0;
            CLK_DN = 1;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;

        end
        TX_HS_PREPARE:begin
            //send LP00
            CLK_DP = 0;
            CLK_DN = 0;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;

        end
        TX_HS_GO:begin
            //send HS0
            CLK_DP = 0 ;
            CLK_DN = 1 ;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;
            
        end
        TX_HS_PRE:begin
            //send Preamble to lock clock

            CLK_DP = TxDDR_CLK ;
            CLK_DN = ~TxDDR_CLK ;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;


        end
        TX_HS_CLK:begin

            //send clk with enable data lane

            CLK_DP = TxDDR_CLK ;
            CLK_DN = ~TxDDR_CLK ;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 1 ;


        end
        TX_HS_POST:begin

            //keep sending clk so RX sample safely 

            CLK_DP = TxDDR_CLK ;
            CLK_DN = ~TxDDR_CLK ;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;


        end
        TX_HS_TRAIL:begin

            //send HS0 to get back 
            CLK_DP = 0 ;
            CLK_DN = 1 ;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;

        end 
        TX_HS_EXIT:begin

            //send LP11 to get back to Stop
            CLK_DP = 1 ;
            CLK_DN = 1 ;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;

        end
        default:begin
            // stop state
            CLK_DP = 1 ;
            CLK_DN = 1 ;
            STOP_STATE = 0 ;
            ULPS_ACTIVE_NOT = 0 ;
            DATA_LANE_START = 0 ;
        end

    endcase


    
end



endmodule
