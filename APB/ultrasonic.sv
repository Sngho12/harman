`timescale 1ns / 1ps

module UltraSonic_Periph(
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    //inport signals
    input  logic        echo,
    output logic        start_trigger,
    output logic        en,
    output logic        cal_done
    );

    logic   [9:0]  distance;
    // logic en;
    // logic cal_done;

    APB_SlaveIntf_US U_APB_Intf_US(.*);
    Ultrasonic U_US(.*);

endmodule



module APB_SlaveIntf_US (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 3:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal signals
    output logic en,
    input  logic [ 9:0] distance,
    input  logic cal_done
);
    logic [31:0] slv_reg0, slv_reg1; //slv_reg2;// slv_reg3;

    assign en = slv_reg0[0];
    assign slv_reg1[9:0] = distance;
    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            //slv_reg1 <= 0;
            //slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                if (PWRITE) begin
                    if(cal_done) begin
                        PREADY <= 1'b1;
                    end else if(en==0)begin
                        PREADY <= 1'b1;
                    end else begin
                        PREADY <= 1'b0;
                    end
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: ;//slv_reg1 <= PWDATA;
                        //2'd2: slv_reg2 <= PWDATA;
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                        PRDATA <= 32'bx;
                    if(cal_done) begin
                        PREADY <= 1;
                        case (PADDR[3:2])
                            2'd0: PRDATA <= slv_reg0;
                            2'd1: PRDATA <= {21'b0,slv_reg1[9:0]};
                            //2'd2: PRDATA <= slv_reg2;
                            // 2'd3: PRDATA <= slv_reg3;
                        endcase
                    end else if(en == 0) begin
                        PREADY <= 1;
                    end else begin
                        PREADY <= 0;
                    end
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end
        

endmodule

module Ultrasonic (
    input  logic PCLK,
    input  logic PRESET,
    input  logic en,
    input  logic echo,
    output logic [9:0] distance,
    output logic start_trigger,
    output logic cal_done
);
    logic tick_1us;

    dist_calculator U_Dist_Cal(.*);
    us_controller U_US_Ctrl(.*);
    tick_gen_1us U_Tick_1us(.*);

endmodule


module dist_calculator(
    input  logic PCLK,
    input  logic PRESET,
    input  logic tick_1us, 
    input  logic echo,
    input  logic start_trigger,
    output logic [9:0] distance,
    output logic cal_done
); //100_000_000; 1us > 1000번 1ms > 1000번 500_000
    parameter OUT_COUNT = 232_00;
    parameter IDLE = 0, START = 1, ECHO =2, CAL = 3, ERROR=4, WAIT = 5;
    logic [2:0] state,next;
    logic [$clog2(OUT_COUNT)-1 :0] outcount_reg, outcount_next;
    logic [9:0] range_reg,range_next, count_1cm_next, count_1cm_reg;

    logic [7:0] count_58_next, count_58_reg;
    logic cal_done_reg, cal_done_next;
    assign distance = range_reg;
    assign cal_done = cal_done_reg;
    always_ff @( posedge PCLK, posedge PRESET ) begin : blockName
        if(PRESET) begin
            state           <= 0;
            range_reg       <= 0;
            outcount_reg    <= 0;
            count_1cm_reg   <= 0;
            count_58_reg    <= 0;
            cal_done_reg    <= 0;
        end else begin
            state           <= next;
            range_reg       <= range_next;
            outcount_reg    <= outcount_next;
            count_1cm_reg   <= count_1cm_next;
            count_58_reg    <= count_58_next;
            cal_done_reg    <= cal_done_next;
        end 
    end

    always_comb begin
        next            = state;
        range_next      = range_reg;
        outcount_next   = outcount_reg;
        count_1cm_next  = count_1cm_reg;
        count_58_next   = count_58_reg;
        cal_done_next   = 0;
        case (state)
            IDLE: begin
                count_1cm_next  = 0;
                count_58_next   = 0;
                outcount_next   = 0;
                if(start_trigger == 1'b1) begin
                    next = START;
                end

                
            end
            WAIT : begin
                if(start_trigger == 1'b0) begin
                    next = START;
                end
            end
            START: begin
                if(echo == 1) begin
                    if(tick_1us == 1'b1) begin
                        next = ECHO;
                    end
                end
            end
            ECHO: begin
                        if(echo == 0) begin
                            if(tick_1us)begin
                                count_1cm_next = count_1cm_reg+1;
                                next = CAL;
                            end
                        end else begin
                            if(tick_1us == 1'b1) begin
                                outcount_next = outcount_reg + 1;
                                if (outcount_reg == OUT_COUNT -1) begin
                                    outcount_next = 0;
                                    next = ERROR;
                                end
                                if(count_58_reg == 57) begin
                                    count_1cm_next = count_1cm_reg + 1;
                                    count_58_next = 0;
                                end else begin
                                    count_1cm_next = count_1cm_reg;
                                    count_58_next = count_58_reg + 1;
                                end
                            
                            end
                        end
                    end
                    
            CAL: begin
                
                range_next = count_1cm_reg;
                next = IDLE;
                cal_done_next = 1;
            end
            ERROR: begin
                cal_done_next = 1;
                range_next = 10'd1000;
                next = IDLE;
            end
        endcase
    end



endmodule


module us_controller(
    input  logic PCLK,
    input  logic PRESET,
    input  logic tick_1us,
    input  logic en,
    output logic start_trigger
    );
    parameter TICK_COUNT = 10;
    parameter IDLE = 0, WAIT = 1, START = 2;
    logic [1:0] state, next;
    logic start_trigger_next,start_trigger_reg;
    logic [$clog2(60000)-1:0] counter_reg,counter_next;
    assign start_trigger = start_trigger_reg;
    always_ff @( posedge PCLK, posedge PRESET ) begin : blockName 
        if(PRESET) begin
            state <= 0;
            counter_reg <= 0;
            start_trigger_reg <= 0;
            
        end else begin
            state <= next;
            counter_reg <= counter_next;
            start_trigger_reg <= start_trigger_next;
        end
    end
    
    always_comb begin
        counter_next = counter_reg;
        start_trigger_next = start_trigger_reg;
        next = state;
        case (state)
            IDLE: begin
                counter_next = 0;
                start_trigger_next = 0;
                if(en) begin
                    next = START;
                    start_trigger_next = 1;
                end
            end
            WAIT : begin
                start_trigger_next = 0;
                if(~en) begin
                    next = IDLE;
                end else if(tick_1us == 1) begin
                    if(counter_reg == 60_000 - 1) begin
                        counter_next = 0;
                        start_trigger_next = 1;
                        next = START;
                    end else begin
                        counter_next = counter_reg + 1;
                    end
                end
            end
            START: begin
                start_trigger_next = 1;
                if(~en) begin
                    next = IDLE;
                end else if(tick_1us == 1'b1)
                    if(counter_reg == TICK_COUNT - 1) begin
                        counter_next = 0;
                        start_trigger_next = 0;
                        next = WAIT;
                    end else begin
                        counter_next = counter_reg + 1;
                    end
            end
        endcase
    end
endmodule

module tick_gen_1us (
    input  logic PCLK,
    input  logic PRESET,
    output logic tick_1us
);
    //100_000_000hz
    localparam FCOUNT = 100; 
    logic tick_next, tick_reg;
    logic [$clog2(FCOUNT)-1:0] tick_count_next, tick_count_reg;

    assign tick_1us = tick_reg;
    always_ff @( posedge PCLK,posedge PRESET ) begin : blockName
        if(PRESET) begin
            tick_count_reg <= 0;
            tick_reg <= 0;
        end else begin
            tick_count_reg <= tick_count_next;
            tick_reg <= tick_next;
        end
    end

    always_comb begin
        tick_next = 0;
        tick_count_next = tick_count_reg;
        if(tick_count_reg == FCOUNT - 1) begin
            tick_count_next = 0;
            tick_next = 1;
        end else begin
            tick_count_next = tick_count_reg + 1;
            tick_next = 0;
        end
    end
endmodule