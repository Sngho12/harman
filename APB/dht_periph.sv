`timescale 1ns / 1ps

module dht_periph (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 4:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    inout  logic        dht_io,
    output logic [ 5:0] led
    // input  logic        btn_start
);

    logic dht_done;
    logic [7:0] temp_int;
    logic [7:0] temp_dem;
    logic [7:0] hum_int;
    logic [7:0] hum_dem;
    logic trigger;

    APB_SlaveIntf_dht U_APB_Intf_DHT (.*);
    top_dht U_DHT_IP (
        .*,
        .clk(PCLK),
        .rst(PRESET),
        .btn_start(trigger)
    );
endmodule

module APB_SlaveIntf_dht (
    // global signal
    input  logic        PCLK,
    input  logic        PRESET,
    // APB Interface Signals
    input  logic [ 4:0] PADDR,
    input  logic [31:0] PWDATA,
    input  logic        PWRITE,
    input  logic        PENABLE,
    input  logic        PSEL,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    // internal signals
    input  logic [ 7:0] temp_int,
    input  logic [ 7:0] temp_dem,
    input  logic [ 7:0] hum_int,
    input  logic [ 7:0] hum_dem,
    output logic        trigger,
    input  logic        dht_done
    // input [15:0] data,
    // output mode
    //output btn_start
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4;

    // assign slv_reg0[7:0] = temp_int[7:0];
    // assign slv_reg1[7:0] = temp_dem[7:0];
    // assign slv_reg2[7:0] = hum_int[7:0];
    // assign slv_reg3[7:0] = hum_dem[7:0];
    // assign trigger = slv_reg4[0];

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
            slv_reg4 <= 0;
        end else begin
            if (dht_done) begin
                slv_reg0[7:0] <= temp_int;
                slv_reg1[7:0] <= temp_dem;
                slv_reg2[7:0] <= hum_int;
                slv_reg3[7:0] <= hum_dem;
            end
            trigger <= slv_reg4[0];
            
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[4:2])
                        3'd0: ;  //slv_reg0 <= PWDATA;
                        3'd1: ;  //slv_reg1 <= PWDATA;
                        3'd2: ;  //slv_reg2 <= PWDATA;
                        3'd3: ;  //slv_reg3 <= PWDATA;
                        3'd4: slv_reg4 <= PWDATA;
                    endcase
                end else begin
                        PRDATA <= 32'bx;
                        case (PADDR[4:2])
                            3'd0: PRDATA <= slv_reg0;
                            3'd1: PRDATA <= slv_reg1;
                            3'd2: PRDATA <= slv_reg2;
                            3'd3: PRDATA <= slv_reg3;
                            3'd4: PRDATA <= slv_reg4;
                        endcase
                    end
                end else begin
                    PREADY <= 1'b0;
                end
            end
        end
endmodule
// module APB_SlaveIntf_dht (
//     // global signal
//     input  logic        PCLK,
//     input  logic        PRESET,
//     // APB Interface Signals
//     input  logic [ 4:0] PADDR,
//     input  logic [31:0] PWDATA,
//     input  logic        PWRITE,
//     input  logic        PENABLE,
//     input  logic        PSEL,
//     output logic [31:0] PRDATA,
//     output logic        PREADY,
//     // internal signals
//     input  logic [ 7:0] temp_int,
//     input  logic [ 7:0] temp_dem,
//     input  logic [ 7:0] hum_int,
//     input  logic [ 7:0] hum_dem,
//     output logic        trigger,
//     input  logic        dht_done
//     // input [15:0] data,
//     // output mode
//     //output btn_start
// );
//     logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3, slv_reg4;

//     assign slv_reg0[7:0] = temp_int[7:0];
//     assign slv_reg1[7:0] = temp_dem[7:0];
//     assign slv_reg2[7:0] = hum_int[7:0];
//     assign slv_reg3[7:0] = hum_dem[7:0];
//     assign trigger = slv_reg4[0];

//     always_ff @(posedge PCLK, posedge PRESET) begin
//         if (PRESET) begin
//             //slv_reg0 <= 0;
//             //slv_reg1 <= 0;
//             //slv_reg2 <= 0;
//             //slv_reg3 <= 0;
//         end else begin
//             if (PSEL && PENABLE) begin
//                 // if (dht_done) begin // done이 들어왔을 때 동작하도록. 
//                 PREADY <= 1'b1;
//                 if (PWRITE) begin
//                     case (PADDR[4:2])
//                         3'd0: ;  //slv_reg0 <= PWDATA;
//                         3'd1: ;  //slv_reg1 <= PWDATA;
//                         3'd2: ;  //slv_reg2 <= PWDATA;
//                         3'd3: ;  //slv_reg3 <= PWDATA;
//                         3'd4: slv_reg4 <= PWDATA;
//                     endcase
//                 end else begin
//                     if (dht_done) begin
//                         PRDATA <= 32'bx;
//                         case (PADDR[4:2])
//                             3'd0: PRDATA <= slv_reg0;
//                             3'd1: PRDATA <= slv_reg1;
//                             3'd2: PRDATA <= slv_reg2;
//                             3'd3: PRDATA <= slv_reg3;
//                             3'd4: PRDATA <= slv_reg4;
//                         endcase
//                     end
//                 end
//             end else begin
//                 PREADY <= 1'b0;
//             end
//         end
//     end
// endmodule

module top_dht (
    input logic clk,
    input logic rst,
    input logic btn_start,
    //input uart_run,
    //input uart_stop,
    output logic [7:0] temp_int,
    output logic [7:0] temp_dem,
    output logic [7:0] hum_int,
    output logic [7:0] hum_dem,
    output logic [5:0] led,
    //input mode,
    inout logic dht_io,
    output logic dht_done
);

    logic [15:0] temperature;
    logic [15:0] humidity;

    assign temp_int = temperature[15:8];
    assign temp_dem = temperature[7:0];
    assign hum_int  = humidity[15:8];
    assign hum_dem  = humidity[7:0];

    wire tick_10us, tick_1us;
    wire w_sensor_led;
    wire [3:0] w_current_state;
    wire [7:0] check_sum;
    wire w_btn_start;
    wire w_check_sum;
    wire w_sensor_start;
    wire [7:0] sum;

    assign sum = humidity[7:0]+humidity[15:8]+temperature[7:0]+temperature[15:8];
    assign led = {w_check_sum, w_sensor_led, w_current_state};
    assign w_check_sum = (check_sum == sum) ? 1 : 0;
    // assign w_sensor_start = uart_run | w_btn_start;
    //assign w_sensor_start = w_btn_start;

    tick_gen_1us_dht #(
        .FCOUNT(1000)
    ) U_TICK_10us (
        .clk (clk),
        .rst (rst),
        .tick(tick_10us)
    );
    tick_gen_1us_dht #(
        .FCOUNT(100)
    ) U_TICK_1us (
        .clk (clk),
        .rst (rst),
        .tick(tick_1us)
    );
    dht_controller U_DHT_CTRL (
        .clk(clk),
        .rst(rst),
        .tick(tick_10us),
        .tick_1us(tick_1us),
        .btn_start(send_10s),
        .sensor_led(w_sensor_led),
        .current_state(w_current_state),
        .humidity(humidity),
        .temperature(temperature),
        .dht_io(dht_io),
        .check_sum(check_sum),
        .dht_done(dht_done)
    );

    btn_debounce U_BTN_DB (
        .clk  (clk),
        .reset(rst),
        .i_btn(btn_start),
        .o_btn(w_btn_start)
    );
    send_start_10s U_SEND (
        .clk(clk),
        .reset(rst),
        .tick(tick_10us),
        //.btn_start(w_sensor_start),
        .btn_start(w_btn_start),
        //.uart_stop(uart_stop),
        .start_per_10s(send_10s)
    );
endmodule

module send_start_10s (
    input  logic clk,
    input  logic reset,
    input  logic tick,
    input  logic btn_start,
    //input uart_stop,
    output logic start_per_10s
);

    parameter IDLE = 2'b00;
    parameter START = 2'b01;
    parameter COUNT = 2'b10;

    logic [1:0] state, next;
    logic [$clog2(1_000_000)-1:0] count_reg, count_next;
    logic o_start_reg, o_start_next;

    assign start_per_10s = o_start_reg;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            state <= IDLE;
            count_reg <= 0;
            o_start_reg <= 0;
        end else begin
            state <= next;
            count_reg <= count_next;
            o_start_reg <= o_start_next;
        end
    end

    always @(*) begin
        next = state;
        count_next = count_reg;
        o_start_next = o_start_reg;
        case (state)
            IDLE: begin
                if (btn_start) begin
                    next = START;
                    o_start_next = 1'b1;
                end
            end
            START: begin
                o_start_next = 1'b0;
                if (tick) begin
                    next = COUNT;
                end
            end
            COUNT: begin
                o_start_next = 1'b0;
                if (tick) begin
                    if (count_reg == 1_000_000 - 1) begin
                        count_next   = 0;
                        o_start_next = 1'b1;
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
                // if(uart_stop == 1'b1) begin
                //     next = IDLE;
                //     count_next = 0;
                //     o_start_next = 0;
                // end
            end
        endcase
    end
endmodule

module tick_gen_1us_dht #(
    parameter FCOUNT = 1000
) (
    input  logic clk,
    input  logic rst,
    output logic tick
);  //100_000_000
    reg tick_next, tick_reg;
    reg [$clog2(FCOUNT)-1:0] count_next, count_reg;
    assign tick = tick_reg;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg <= 0;
            tick_reg  <= 0;
        end else begin
            count_reg <= count_next;
            tick_reg  <= tick_next;
        end
    end

    always @(*) begin
        count_next = count_reg;
        tick_next  = 0;
        if (count_reg == FCOUNT - 1) begin
            count_next = 0;
            tick_next  = 1;
        end else begin
            count_next = count_reg + 1;
            tick_next  = 0;
        end
    end
endmodule

module btn_debounce (
    input  logic clk,
    input  logic reset,
    input  logic i_btn,
    output logic o_btn
);
    //        state, next;
    reg [7:0] q_reg, q_next;
    reg  edge_detect;
    wire btn_debounce;
    //시뮬레이션시 1kh를 /*로 막은 뒤 밑의 always구문의의 r_1khz를 100mhz 기본 clk으로 해버리면 시뮬레이션 빨리가능
    // 1khz clk
    reg [$clog2(100_000)-1:0] counter_reg, counter_next;
    reg r_1khz;
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    //next
    always @(*) begin  //100_000_000
        counter_next = counter_reg;
        r_1khz = 0;
        if (counter_reg == 100_000 - 1) begin
            counter_next = 0;
            r_1khz = 1'b1;
        end else begin
            counter_next = counter_reg + 1;
            r_1khz = 1'b0;
        end

    end

    // state logic
    always @(posedge r_1khz, posedge reset) begin
        if (reset) begin
            q_reg <= 0;
        end else begin
            q_reg <= q_next;
        end
    end

    always @(i_btn, r_1khz, q_reg) begin  // event i_btn, r_1khz
        // q_reg의 상위 7비트를 다음 하위 7비트에 넣고 최상에는 i_btn을 넣어라라
        q_next = {i_btn, q_reg[7:1]};  //shift의 동작을 설명
    end

    // 8 input And gate
    assign btn_debounce = &q_reg;

    // edge_detector
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            edge_detect <= 1'b0;
        end else begin
            edge_detect <= btn_debounce;
        end

    end

    // 최종 출력
    assign o_btn = btn_debounce & (~edge_detect);
endmodule

module dht_controller (
    input logic clk,
    input logic rst,
    input logic tick,
    input logic tick_1us,
    input logic btn_start,
    output logic sensor_led,
    output logic [3:0] current_state,
    output logic [15:0] humidity,
    output logic [15:0] temperature,
    output logic [7:0] check_sum,
    output logic dht_done,
    inout logic dht_io
);
    parameter START_CNT = 1800, WAIT_CNT = 3, SYNC_CNT = 8,
                 DATA_SYNC_CNT = 5, DATA_01 = 40, STOP_CNT = 5, TIME_OUT = 3000;
    parameter IDLE =0,START =1, WAIT = 2, SYNCLOW = 3, SYNCHIGH=4, 
                DATASYNC = 5, DATABIT = 6, DATA_STORE = 7, STOP = 8;

    reg [3:0] state, next;
    reg [$clog2(TIME_OUT)-1:0] count_reg, count_next;
    reg sensor_led_next, sensor_led_reg;

    logic io_mode_reg, io_mode_next;
    logic dht_out_reg, dht_out_next;
    reg [39:0] data_reg, data_next;
    reg [5:0] bit_count_next, bit_count_reg;
    reg [15:0] humidity_reg, humidity_next;
    reg [15:0] temperature_reg, temperature_next;
    reg [7:0] check_sum_reg, check_sum_next;
    reg dht_done_reg, dht_done_next;


    reg [$clog2(TIME_OUT) - 1:0] timeout_count_reg, timeout_count_next;
    assign dht_io = (io_mode_reg == 1) ? dht_out_reg : 1'bz;
    assign current_state = state;
    assign sensor_led = sensor_led_reg;
    assign humidity = humidity_reg;
    assign temperature = temperature_reg;
    assign check_sum = check_sum_reg[7:0];
    assign dht_done = dht_done_reg;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= 0;
            count_reg <= 0;
            dht_out_reg <= 1;  // idle 일때 high
            sensor_led_reg <= 0;
            io_mode_reg <= 1;
            data_reg <= 0;
            bit_count_reg <= 0;
            humidity_reg <= 0;
            temperature_reg <= 0;
            check_sum_reg <= 8'hff;
            timeout_count_reg <= 0;
            dht_done_reg <= 0;
        end else begin
            state <= next;
            count_reg <= count_next;
            dht_out_reg <= dht_out_next;
            sensor_led_reg <= sensor_led_next;
            io_mode_reg <= io_mode_next;
            data_reg <= data_next;
            bit_count_reg <= bit_count_next;
            humidity_reg <= humidity_next;
            temperature_reg <= temperature_next;
            check_sum_reg <= check_sum_next;
            timeout_count_reg <= timeout_count_next;
            dht_done_reg <= dht_done_next;
        end

    end

    always @(*) begin
        next = state;
        count_next = count_reg;
        io_mode_next = io_mode_reg;
        dht_out_next = dht_out_reg;
        sensor_led_next = sensor_led_reg;
        data_next = data_reg;
        bit_count_next = bit_count_reg;
        humidity_next = humidity_reg;
        temperature_next = temperature_reg;
        check_sum_next = check_sum_reg;
        timeout_count_next = timeout_count_reg;
        dht_done_next = dht_done_reg;
        case (state)
            IDLE: begin
                bit_count_next = 0;
                io_mode_next = 1;
                count_next = 0;
                dht_out_next = 1'b1;
                data_next = 0;
                timeout_count_next = 0;
                sensor_led_next = 0;
                dht_done_next = 0;
                if (btn_start == 1) begin
                    next = START;
                    dht_out_next = 1'b0;
                end else begin
                    next = IDLE;
                end
            end
            START: begin
                if (tick == 1'b1) begin
                    if (count_reg == START_CNT - 1) begin
                        count_next = 0;
                        dht_out_next = 1'b1;
                        next = WAIT;
                    end else begin
                        count_next = count_reg + 1;
                    end
                end
            end

            WAIT: begin
                if (tick == 1'b1) begin
                    count_next = count_reg + 1;
                    if (count_reg == WAIT_CNT - 1) begin
                        count_next = 0;
                        io_mode_next = 0;
                        next = SYNCLOW;
                    end
                end
            end
            SYNCLOW: begin

                if (tick) begin
                    if (count_reg == 2) begin
                        count_next = count_reg;
                    end else begin
                        count_next = count_reg + 1;
                    end

                    if (timeout_count_reg == TIME_OUT - 1) begin
                        timeout_count_next = 0;
                        next = IDLE;
                    end else begin
                        timeout_count_next = timeout_count_reg + 1;
                    end
                end

                if ((dht_io == 1'b1) && (count_reg == 2)) begin
                    next = SYNCHIGH;
                    count_next = 0;
                    timeout_count_next = 0;
                end

            end

            SYNCHIGH: begin

                if (tick) begin
                    if (count_reg == 2) begin
                        count_next = count_reg;
                    end else begin
                        count_next = count_reg + 1;
                    end

                    if (timeout_count_reg == TIME_OUT - 1) begin
                        timeout_count_next = 0;
                        next = IDLE;
                    end else begin
                        timeout_count_next = timeout_count_reg + 1;
                    end
                end

                if ((dht_io == 1'b0) && (count_reg == 2)) begin
                    next = DATASYNC;
                    count_next = 0;
                    timeout_count_next = 0;
                end

            end

            DATASYNC: begin
                sensor_led_next = 1;

                if (tick) begin
                    if (count_reg == 1) begin
                        count_next = count_reg;
                    end else begin
                        count_next = count_reg + 1;
                    end

                    if (timeout_count_reg == TIME_OUT - 1) begin
                        timeout_count_next = 0;
                        next = IDLE;
                    end else begin
                        timeout_count_next = timeout_count_reg + 1;
                    end

                end

                if ((dht_io == 1'b1) && (count_next == 1)) begin
                    next = DATABIT;
                    count_next = 0;
                    timeout_count_next = 0;
                end

            end
            DATABIT: begin
                if (dht_io == 1'b1) begin
                    if (tick_1us) begin
                        count_next = count_reg + 1;
                    end
                end else begin
                    next = DATA_STORE;
                    timeout_count_next = 0;
                end
                if (tick) begin
                    if (timeout_count_reg == TIME_OUT - 1) begin
                        timeout_count_next = 0;
                        next = IDLE;
                    end else begin
                        timeout_count_next = timeout_count_reg + 1;
                    end
                end
            end

            DATA_STORE: begin
                if (count_reg <= DATA_01) begin
                    count_next = 0;
                    data_next  = {data_reg[38:0], 1'b0};
                end else if (count_reg > DATA_01) begin
                    count_next = 0;
                    data_next  = {data_reg[38:0], 1'b1};
                end

                if (bit_count_reg == 39) begin
                    bit_count_next = 0;
                    count_next = 0;
                    timeout_count_next = 0;
                    next = STOP;
                end else begin
                    bit_count_next = bit_count_reg + 1;
                    timeout_count_next = 0;
                    next = DATASYNC;
                end
            end


            STOP: begin
                sensor_led_next = 1'b0;
                humidity_next = data_reg[39:24];
                temperature_next = data_reg[23:8];
                check_sum_next = data_reg[7:0];
                if (tick) begin
                    if (count_reg == STOP_CNT) begin
                        dht_done_next = 1;
                        next = IDLE;
                        timeout_count_next = 0;
                        count_next = 0;
                    end else begin
                        count_next = count_reg + 1;
                    end

                    if (timeout_count_reg == TIME_OUT - 1) begin
                        timeout_count_next = 0;
                        next = IDLE;
                    end else begin
                        timeout_count_next = timeout_count_reg + 1;
                    end
                end
            end

        endcase
    end

endmodule
