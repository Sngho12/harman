`timescale 1ns / 1ps

module UART_Periph(
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
    input  logic rx,
    output logic tx
    );
    logic fifo_rx_empty;
    logic fifo_tx_full; 
    logic [7:0] pc2mcu_send_data;
    logic [7:0] mcu2pc_send_data;
    logic wr_en, rd_en;

    APB_SlaveIntf_UART U_APB_Intf_UART(.*,
    .fsr({fifo_rx_empty,fifo_tx_full}));
    top_uart_fifo U_UART(
        .*,
        .pc2mcu_send_data(pc2mcu_send_data),
        .mcu2pc_send_data(mcu2pc_send_data)

    );

endmodule



module APB_SlaveIntf_UART (
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
    input  logic [1:0]  fsr,
    output logic        wr_en,
    output logic        rd_en,
    output logic [7:0] mcu2pc_send_data,
    input  logic [7:0] pc2mcu_send_data
);
    localparam EMPTY = 2'b10, FULL = 2'b01;
    logic [31:0] slv_reg0, slv_reg1; //slv_reg2;// slv_reg3;

    assign mcu2pc_send_data = slv_reg0[7:0];
    assign slv_reg1[7:0] = pc2mcu_send_data;


    always_comb begin
        wr_en  = 1'b0;
        rd_en  = 1'b0;
        PREADY = 1'b0;
        PRDATA = 32'bx;
        slv_reg0 = 32'b0;
        if (PSEL && PENABLE) begin
            case (fsr)
                EMPTY: begin
                    if (PWRITE == 1'b1) PREADY = 1'b1;
                    else PREADY = 1'b0; 
                end
                FULL: begin
                    if (PWRITE == 1'b0) PREADY = 1'b1;
                    else PREADY = 1'b0;
                end
                default: PREADY = 1'b1;
            endcase
        end

        if (PREADY) begin
            if (PWRITE) begin
                wr_en = 1'b1;
                case (PADDR[3:2])
                    2'b00: slv_reg0 = PWDATA;
                    2'b01: ;  //slv_reg1 <= PWDATA;
                    //2'b10: slv_reg2 <= PWDATA;
                    //2'b11: slv_reg3 <= PWDATA;
                endcase
            end else begin
                rd_en = 1'b1;
                case (PADDR[3:2])
                    2'b00: PRDATA = slv_reg0;
                    2'b01: PRDATA = {25'b0, slv_reg1[7:0]};
                    //2'b10: PRDATA <= slv_reg2;
                    //2'b11: PRDATA <= slv_reg3;
                endcase
            end
        end
    end

endmodule

module top_uart_fifo (
    input  logic       PCLK,
    input  logic       PRESET,
    input  logic       wr_en,
    input  logic       rd_en,
    output logic       tx,
    input  logic       rx,
    output logic        fifo_rx_empty,
    output logic        fifo_tx_full,
    output logic [7:0] pc2mcu_send_data,
    input  logic [7:0] mcu2pc_send_data

);
    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx_done;
    logic       rx_done;
    logic [7:0] rx_data;

    logic       fifo_tx_empty;
    logic [7:0] fifo_tx_wdata;

    logic       fifo_rx_full;
    logic [7:0] fifo_rx_rdata;
    assign pc2mcu_send_data = fifo_rx_rdata;
    assign fifo_tx_wdata    = mcu2pc_send_data;
    assign tx_start = ~fifo_tx_empty;

    
    uart U_UART(.*);
    fifo U_FIFO_TX(
        .*,
        .wdata(fifo_tx_wdata),
        .w_en(wr_en),
        .full(fifo_tx_full),
        .rdata(tx_data),
        .r_en(~tx_done&~fifo_tx_empty),
        .empty(fifo_tx_empty)
    );
    fifo U_FIFO_RX(
        .*,
        .wdata(rx_data),
        .w_en(rx_done),
        .full(fifo_rx_full),
        .rdata(fifo_rx_rdata),
        .r_en(rd_en),
        .empty(fifo_rx_empty)
    );

endmodule
module uart (
    input  logic       PCLK,
    input  logic       PRESET,

    input  logic [7:0] tx_data,
    input  logic       tx_start,
    output logic       tx_done,
    output logic       tx,

    input  logic       rx,
    output logic       rx_done,
    output logic [7:0] rx_data
);

    logic baud_tick;
    baud_gen U_BAUD_GEN(.*);
    uart_tx U_UART_TX(
        .*);
    uart_rx U_UART_RX(.*);

endmodule

module uart_tx (
    input  logic       PCLK,
    input  logic       PRESET,
    input  logic       baud_tick,
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_done,
    output logic       tx
);
    localparam IDLE =0, START = 1, DATA = 2, STOP = 3 ;
    logic [1:0] state, next;
    logic [3:0] tick_count_next,tick_count_reg;
    logic [2:0] bit_count_next, bit_count_reg;
    logic [7:0] temp_next, temp_reg;
    logic tx_next,tx_reg,tx_done_next, tx_done_reg;

    assign tx = tx_reg;
    assign tx_done = tx_done_reg;
    always_ff @( posedge PCLK, posedge PRESET ) begin
        if(PRESET) begin
            state <= 0;
            tick_count_reg <= 0;
            bit_count_reg <= 0;
            temp_reg <= 0;
            tx_done_reg <= 0;
            tx_reg <= 1;
        end else begin
            state <= next;
            tick_count_reg <= tick_count_next;
            bit_count_reg <= bit_count_next;
            temp_reg <= temp_next;
            tx_done_reg <= tx_done_next;
            tx_reg <= tx_next;
        end 
    end


    always_comb begin
        next            = state;
        tick_count_next = tick_count_reg;
        bit_count_next  = bit_count_reg;
        temp_next       = temp_reg;
        tx_next         = tx_reg;
        tx_done_next     = 0;
        case (state)
            IDLE:begin
                tick_count_next = 0;
                bit_count_next  = 0;
                tx_next         = 1;
                if(tx_start)begin
                    next = START;
                    tx_next = 0;
                    temp_next = tx_data;
                end
            end 
            START:begin
                if(baud_tick)begin
                    if(tick_count_reg == 15) begin
                        bit_count_next = 0;
                        tick_count_next = 0;
                        tx_next = temp_reg[0];
                        next = DATA;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            DATA:begin
                tx_next = temp_reg[bit_count_reg];
                if(baud_tick)begin
                    if(tick_count_reg == 15)begin
                        if(bit_count_reg == 7) begin
                            tick_count_next = 0;
                            bit_count_next  = 0;
                            tx_next = 1;
                            next = STOP;
                        end else begin
                            tick_count_next = 0;
                            bit_count_next = bit_count_reg + 1;
                            next = DATA;
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            STOP:begin
                if(baud_tick) begin
                    if(tick_count_reg == 15) begin
                        tick_count_next = 0;
                        tx_done_next = 1;
                        next = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end 
        endcase
    end
endmodule
module uart_rx (
    input  logic PCLK, 
    input  logic PRESET,
    input  logic baud_tick,
    input  logic rx,
    output logic [7:0] rx_data,
    output logic rx_done
);
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    logic [4:0] tick_count_next, tick_count_reg;
    logic [2:0] bit_count_next, bit_count_reg;
    logic [1:0] next, state;
    logic [7:0] temp_next, temp_reg,data_reg,data_next;
    logic rx_done_reg, rx_done_next;
    assign rx_data = data_reg;
    assign rx_done = rx_done_reg;
    always_ff @( posedge PCLK, posedge PRESET ) begin
        if(PRESET) begin
            state <= 0;
            tick_count_reg <=0;
            bit_count_reg <=0;
            temp_reg <= 0;
            data_reg<= 0;
            rx_done_reg <= 0;
        end else begin
            state <= next;
            tick_count_reg <= tick_count_next;
            bit_count_reg <= bit_count_next;
            temp_reg  <= temp_next;
            data_reg <= data_next;
            rx_done_reg <= rx_done_next;
        end
    end


    always_comb begin 
        next = state;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count_reg;
        temp_next = temp_reg;

        data_next = data_reg;
        rx_done_next = rx_done_reg;;
        case (state)
            IDLE: begin
                temp_next = 0;
                bit_count_next = 0;
                tick_count_next = 0;
                rx_done_next = 0;
                if(rx == 0) next = START;
            end 
            START: begin
                if(baud_tick) begin
                    if(tick_count_next == 7) begin
                        tick_count_next = 0;
                        next = DATA;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            DATA: begin
                if(baud_tick) begin
                    if(tick_count_reg == 15) begin
                        temp_next = {rx,temp_reg[7:1]};
                        if(bit_count_reg == 7) begin
                            bit_count_next = 0;
                            tick_count_next = 0;
                            next = STOP;
                        end else begin
                            tick_count_next = 0;
                            bit_count_next = bit_count_reg + 1;
                            next = DATA;
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
            STOP: begin
                data_next = temp_reg;
                if(baud_tick)begin
                    if(tick_count_reg == 23) begin
                        tick_count_next = 0;
                        rx_done_next = 1;
                        next = IDLE;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end
        endcase
    end
endmodule

module baud_gen (
    input  logic PCLK,
    input  logic PRESET,
    output logic baud_tick
);
    parameter baud_rate = 9600;
    parameter baud_count = (100_000_000 / baud_rate) / 16; //16 oversampling
    logic [$clog2(baud_count)-1 :0] tick_count_reg, tick_count_next;
    logic baud_tick_reg, baud_tick_next;
    assign baud_tick = baud_tick_reg;
    always_ff @( posedge PCLK,posedge PRESET ) begin
        if(PRESET) begin
            tick_count_reg = 0;
            baud_tick_reg = 0;
        end else begin
            tick_count_reg <= tick_count_next;
            baud_tick_reg <= baud_tick_next;
        end
    end

    always_comb begin
        baud_tick_next = baud_tick_reg;
        tick_count_next = tick_count_reg;
        if(tick_count_reg == baud_count - 1)begin
            baud_tick_next = 1;
            tick_count_next = 0;
        end else begin
            baud_tick_next = 0;
            tick_count_next = tick_count_reg + 1;
        end
    end

endmodule

module fifo (
    input  logic       PCLK,
    input  logic       PRESET,
    input  logic [7:0] wdata,
    input  logic       w_en,
    output logic       full,

    output logic [7:0] rdata,
    input  logic       r_en,
    output logic       empty
);
    logic [2:0] waddr_ptr, raddr_ptr;
    logic [7:0] w_rdata;
    assign rdata = r_en ? w_rdata : 8'hz;
    
    fifo_cu U_FIFO_CU(
        .*,
        .w_ptr(waddr_ptr),
        .r_ptr(raddr_ptr)
    );
    fifo_ram U_RAM(
    .PCLK(PCLK),
    .wdata(wdata),
    .waddr(waddr_ptr),
    .w_en( ~full & w_en),
    .rdata(w_rdata),
    .raddr(raddr_ptr)
    );
endmodule

module fifo_cu (
    input  logic       PCLK,
    input  logic       PRESET,
    input  logic       w_en,
    output logic [2:0] w_ptr, 
    input  logic       r_en,
    output logic [2:0] r_ptr,

    output logic       full,
    output logic       empty
);
    localparam READ = 2'b01, WRITE = 2'b10, READ_WRITE=2'b11;
    logic [2:0] w_ptr_next,w_ptr_reg,r_ptr_next,r_ptr_reg;
    logic empty_next,empty_reg,full_next,full_reg;
    assign  w_ptr = w_ptr_reg;
    assign  r_ptr = r_ptr_reg;
    assign  full = full_reg;
    assign  empty = empty_reg;
    always_ff @( posedge PCLK, posedge PRESET ) begin
        if(PRESET) begin
            full_reg <= 0;
            empty_reg <= 1;
            w_ptr_reg <= 0;
            r_ptr_reg <= 0;
        end else begin
            full_reg <= full_next;
            empty_reg <= empty_next;
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
        end
    end
    always_comb begin
        full_next = full_reg;
        empty_next = empty_reg;
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        case ({w_en, r_en})
            READ:begin
                if(empty_reg == 1'b0) begin
                    full_next = 1'b0;
                    r_ptr_next = r_ptr_reg + 1;
                    if(r_ptr_next == w_ptr_reg) begin
                        empty_next = 1'b1;
                    end
                end
            end
            WRITE:begin
                if(full_reg == 1'b0)begin
                    empty_next = 1'b0;
                    w_ptr_next = w_ptr_reg+1;
                    if(w_ptr_next == r_ptr_reg) begin
                        full_next = 1'b1;
                    end
                end
            end
            READ_WRITE: begin
                if(empty_reg == 1'b1) begin
                    w_ptr_next = w_ptr_reg + 1;
                    empty_next = 1'b0;
                end else if(full_reg == 1'b1) begin
                    r_ptr_next = r_ptr_reg + 1;
                    full_next = 1'b0;
                end else begin
                    w_ptr_next = w_ptr_reg + 1;
                    r_ptr_next = r_ptr_reg + 1;
                end
            end
        endcase
    end
endmodule

module fifo_ram (
    input  logic       PCLK,
    input  logic [7:0] wdata,
    input  logic [2:0] waddr,
    input  logic       w_en,

    output logic [7:0] rdata,
    input  logic [2:0] raddr

);
    logic [7:0] memory [0:2**2-1];
    assign rdata = memory[raddr];
    always_ff @( posedge PCLK) begin
        if(w_en) begin
            memory[waddr] <= wdata;
        end
    end
    
endmodule


