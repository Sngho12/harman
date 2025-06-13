// `timescale 1ns / 1ps

// module UART_Periph(
//     input  logic        PCLK,
//     input  logic        PRESET,
//     // APB Interface Signals
//     input  logic [ 3:0] PADDR,
//     input  logic [31:0] PWDATA,
//     input  logic        PWRITE,
//     input  logic        PENABLE,
//     input  logic        PSEL,
//     output logic [31:0] PRDATA,
//     output logic        PREADY
//     //inport signals

//     );

//     logic   en;
//     logic   [9:0]  distance;


//     APB_SlaveIntf_UART U_APB_Intf_UART(.*);


// endmodule



// module APB_SlaveIntf_UART (
//     // global signal
//     input  logic        PCLK,
//     input  logic        PRESET,
//     // APB Interface Signals
//     input  logic [ 3:0] PADDR,
//     input  logic [31:0] PWDATA,
//     input  logic        PWRITE,
//     input  logic        PENABLE,
//     input  logic        PSEL,
//     output logic [31:0] PRDATA,
//     output logic        PREADY,
//     // internal signals
//     output logic en,
//     input  logic [ 9:0] distance 
// );
//     logic [31:0] slv_reg0, slv_reg1; //slv_reg2;// slv_reg3;

//     assign en = slv_reg0[0];
//     assign slv_reg1[9:0] = distance;
//     always_ff @(posedge PCLK, posedge PRESET) begin
//         if (PRESET) begin
//             slv_reg0 <= 0;
//             //slv_reg1 <= 0;
//             //slv_reg2 <= 0;
//             // slv_reg3 <= 0;
//         end else begin
//             if (PSEL && PENABLE) begin
//                 PREADY <= 1'b1;
//                 if (PWRITE) begin
//                     case (PADDR[3:2])
//                         2'd0: slv_reg0 <= PWDATA;
//                         2'd1: ;//slv_reg1 <= PWDATA;
//                         //2'd2: slv_reg2 <= PWDATA;
//                         // 2'd3: slv_reg3 <= PWDATA;
//                     endcase
//                 end else begin
//                     PRDATA <= 32'bx;
//                     case (PADDR[3:2])
//                         2'd0: PRDATA <= slv_reg0;
//                         2'd1: PRDATA <= slv_reg1;
//                         //2'd2: PRDATA <= slv_reg2;
//                         // 2'd3: PRDATA <= slv_reg3;
//                     endcase
//                 end
//             end else begin
//                 PREADY <= 1'b0;
//             end
//         end
//     end

// endmodule

// module uart (
//     input  logic       PCLK,
//     input  logic       PRESET,

//     input  logic [7:0] tx_data,
//     output logic       tx,

//     input  logic       rx,
//     output logic [7:0] rx_data
// );

//     logic baud_tick;
//     logic rx_done;
//     baud_gen U_BAUD_GEN(.*);
//     uart_tx U_UART_TX(
//         .*,
//         .start(rx_done));
//     uart_rx U_UART_RX(.*);

// endmodule

// module uart_tx (
//     input  logic       PCLK,
//     input  logic       PRESET,
//     input  logic       baud_tick,
//     input  logic       start,
//     input  logic [7:0] tx_data,
//     output logic       tx
// );
//     localparam IDLE =0, START = 1, DATA = 2, STOP = 3 ;
//     logic [1:0] state, next;
//     logic [3:0] tick_count_next,tick_count_reg;
//     logic [2:0] bit_count_next, bit_count_reg;
//     logic [7:0] temp_next, temp_reg;
//     logic tx_next,tx_reg;

//     assign tx = tx_reg;
     
//     always_ff @( posedge PCLK, posedge PRESET ) begin
//         if(PRESET) begin
//             state <= 0;
//             tick_count_reg <= 0;
//             bit_count_reg <= 0;
//             temp_reg <= 0;
//             tx_reg <= 1;
//         end else begin
//             state <= next;
//             tick_count_reg <= tick_count_next;
//             bit_count_reg <= bit_count_next;
//             temp_reg <= temp_next;
//             tx_reg <= tx_next;
//         end
//     end


//     always_comb begin
//         next            = state;
//         tick_count_next = tick_count_reg;
//         bit_count_next  = bit_count_reg;
//         temp_next       = temp_reg;
//         tx_next         = tx_reg;
//         case (state)
//             IDLE:begin
//                 tick_count_next = 0;
//                 bit_count_next  = 0;
//                 tx_next         = 1;
//                 if(start)begin
//                     next = START;
//                     tx_next = 0;
//                     temp_next = tx_data;
//                 end
//             end 
//             START:begin
//                 if(baud_tick)begin
//                     if(tick_count_reg == 15) begin
//                         bit_count_next = 0;
//                         tick_count_next = 0;
//                         tx_next = temp_reg[0];
//                         next = DATA;
//                     end else begin
//                         tick_count_next = tick_count_reg + 1;
//                     end
//                 end
//             end
//             DATA:begin
//                 tx_next = temp_reg[bit_count_reg];
//                 if(baud_tick)begin
//                     if(tick_count_reg == 15)begin
//                         if(bit_count_reg == 7) begin
//                             tick_count_next = 0;
//                             bit_count_next  = 0;
//                             tx_next = 1;
//                             next = STOP;
//                         end else begin
//                             tick_count_next = 0;
//                             bit_count_next = bit_count_reg + 1;
//                             next = DATA;
//                         end
//                     end else begin
//                         tick_count_next = tick_count_reg + 1;
//                     end
//                 end
//             end
//             STOP:begin
//                 if(baud_tick) begin
//                     if(tick_count_reg == 15) begin
//                         tick_count_next = 0;
//                         next = IDLE;
//                     end else begin
//                         tick_count_next = tick_count_reg + 1;
//                     end
//                 end
//             end 
//         endcase
//     end
// endmodule
// module uart_rx (
//     input  logic PCLK,
//     input  logic PRESET,
//     input  logic baud_tick,
//     input  logic rx,
//     output logic [7:0] rx_data,
//     output logic rx_done
// );
//     localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
//     logic [4:0] tick_count_next, tick_count_reg;
//     logic [2:0] bit_count_next, bit_count_reg;
//     logic [1:0] next, state;
//     logic [7:0] temp_next, temp_reg,data_reg,data_next;
//     logic rx_done_reg, rx_done_next;
//     assign rx_data = data_reg;
//     assign rx_done = rx_done_reg;
//     always_ff @( posedge PCLK, posedge PRESET ) begin
//         if(PRESET) begin
//             state <= 0;
//             tick_count_reg <=0;
//             bit_count_reg <=0;
//             temp_reg <= 0;
//             data_reg<= 0;
//             rx_done_reg <= 0;
//         end else begin
//             state <= next;
//             tick_count_reg <= tick_count_next;
//             bit_count_reg <= bit_count_next;
//             temp_reg  <= temp_next;
//             data_reg <= data_next;
//             rx_done_reg <= rx_done_next;
//         end
//     end


//     always_comb begin 
//         next = state;
//         tick_count_next = tick_count_reg;
//         bit_count_next = bit_count_reg;
//         temp_next = temp_reg;

//         data_next = data_reg;
//         rx_done_next = rx_done_reg;;
//         case (state)
//             IDLE: begin
//                 temp_next = 0;
//                 bit_count_next = 0;
//                 tick_count_next = 0;
//                 rx_done_next = 0;
//                 if(rx == 0) next = START;
//             end 
//             START: begin
//                 if(baud_tick) begin
//                     if(tick_count_next == 7) begin
//                         tick_count_next = 0;
//                         next = DATA;
//                     end else begin
//                         tick_count_next = tick_count_reg + 1;
//                     end
//                 end
//             end
//             DATA: begin
//                 if(baud_tick) begin
//                     if(tick_count_reg == 15) begin
//                         temp_next = {rx,temp_reg[7:1]};
//                         if(bit_count_reg == 7) begin
//                             bit_count_next = 0;
//                             tick_count_next = 0;
//                             next = STOP;
//                         end else begin
//                             tick_count_next = 0;
//                             bit_count_next = bit_count_reg + 1;
//                             next = DATA;
//                         end
//                     end else begin
//                         tick_count_next = tick_count_reg + 1;
//                     end
//                 end
//             end
//             STOP: begin
//                 data_next = temp_reg;
//                 if(baud_tick)begin
//                     if(tick_count_reg == 23) begin
//                         tick_count_next = 0;
//                         rx_done_next = 1;
//                         next = IDLE;
//                     end else begin
//                         tick_count_next = tick_count_reg + 1;
//                     end
//                 end
//             end
//         endcase
//     end
// endmodule

// module baud_gen (
//     input  logic PCLK,
//     input  logic PRESET,
//     output logic baud_tick
// );
//     parameter baud_rate = 9600;
//     parameter baud_count = (100_000_000 / baud_rate) / 16; //16 oversampling
//     logic [$clog2(baud_count)-1 :0] tick_count_reg, tick_count_next;
//     logic baud_tick_reg, baud_tick_next;
//     assign baud_tick = baud_tick_reg;
//     always_ff @( posedge PCLK,posedge PRESET ) begin
//         if(PRESET) begin
//             tick_count_next = 0;
//             baud_tick_reg = 0;
//         end else begin
//             tick_count_reg <= tick_count_next;
//             baud_tick_reg <= baud_tick_next;
//         end
//     end

//     always_comb begin
//         if(tick_count_reg == baud_count - 1)begin
//             baud_tick_next = 1;
//             tick_count_next = 0;
//         end else begin
//             baud_tick_next = 0;
//             tick_count_next = tick_count_reg + 1;
//         end
//     end

// endmodule
