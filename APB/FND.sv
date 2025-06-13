`timescale 1ns / 1ps

module FND_Periph (
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
    // export signals

    output  logic [3:0] fndComm,
    output  logic [7:0] fndFont
);

    logic        FCR;
    logic [15:0] FDR;
    logic [ 3:0] DPR;
    logic [1:0] hexa;
    APB_SlaveIntf_FND U_APB_Intf_FND (.*);
    FND U_FND_IP (.*);
    
endmodule

module APB_SlaveIntf_FND (
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
    output logic        FCR,
    output logic [15:0] FDR,
    output logic [ 3:0] DPR,
    output logic [1:0] hexa
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;
    //reg0 = FCR, reg1 = FMR, reg2 = FDR
    assign FCR = slv_reg0[0];
    assign FDR  = slv_reg1[15:0];
    assign DPR  = slv_reg2[3:0]; 
    assign hexa  = slv_reg3[1:0]; 

    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0;
            slv_reg2 <= 0;
            slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule
/*
module FND(
    input logic       FCR,
    input logic [3:0] FMR,
    input logic [3:0] FDR,
    output logic [3:0] fndComm,
    output logic [7:0] fndFont    
);
    assign fndComm = FCR ? ~FMR : 4'b1111;
    always_comb begin
            case (FDR)
            4'h0: fndFont = 8'hC0;
            4'h1: fndFont = 8'hF9;
            4'h2: fndFont = 8'hA4;
            4'h3: fndFont = 8'hB0;
            4'h4: fndFont = 8'h99;
            4'h5: fndFont = 8'h92;
            4'h6: fndFont = 8'h82;
            4'h7: fndFont = 8'hF8;
            4'h8: fndFont = 8'h80;
            4'h9: fndFont = 8'h90;
            4'hA: fndFont = 8'h88;
            4'hB: fndFont = 8'h83;
            4'hC: fndFont = 8'hC6;
            4'hD: fndFont = 8'hA1;
            4'hE: fndFont = 8'h70;
            4'hF: fndFont = 8'h8E;
            default: fndFont = 8'hff;
        endcase
    end
endmodule
*/
module FND (
    input logic PCLK,
    input logic PRESET,
    input  logic FCR,
    input  logic [15:0] FDR, // 비트 수 늘리기
    input logic [3:0] DPR,
    input logic [1:0] hexa,
    output  logic [3:0] fndComm,
    output  logic [7:0] fndFont
);
logic tick;
logic [1:0] counter;
logic [3:0] x0,x1,x2,x3;
logic [3:0] bcd;
logic [3:0] dot,fnd_dot;
logic [7:0] fnd_7;

logic [3:0] x0_mux, x1_mux, x2_mux, x3_mux;

assign fndFont = {fnd_dot, fnd_7[6:0]};

assign x0_mux = (hexa == 1) ? 4'h5 :
                (hexa == 2) ? 4'hC : x0;

assign x1_mux = (hexa == 1) ? 4'hB :
                (hexa == 2) ? 4'hC : x1;

assign x2_mux = (hexa == 1) ? 4'h5 :
                (hexa == 2) ? 4'hE : x2;

assign x3_mux = (hexa == 1) ? 4'hF :
                (hexa == 2) ? 4'hF : x3;

clk_div U_Clk_Div(.*);
counter U_Counter_2bit(.*);
decoder U_Decoder(.*);
digit_splitter U_x0(
    .i_data(FDR),
    .x0(x0), 
    .x1(x1),
    .x2(x2),
    .x3(x3)
);
dot_comp U_Dot_comp(
    .DPR(DPR),
    .FDR(FDR),
    .dot(dot)
);
mux_4x1 U_Mux_4x1_Dot(
    .sel(counter),
    .x0(dot[0]),
    .x1(dot[1]),
    .x2(dot[2]),
    .x3(dot[3]),
    .y(fnd_dot)
);
mux_4x1 U_Mux_4x1_FDR(
    .sel(counter),
    .x0(x0_mux),
    .x1(x1_mux),
    .x2(x2_mux),
    .x3(x3_mux),
    .y(bcd)
);
bcdtoseg U_Bcd2Seg(.bcd(bcd), .fndFont(fnd_7));

endmodule
module dot_comp (
    input  logic [3:0] DPR,
    input  logic [15:0] FDR,
    output logic [3:0] dot
);
    always_comb begin 
        if((FDR % 10) > 4) begin
            dot = ~DPR;
        end else begin
            dot = 4'b1111;
        end
    end
endmodule

module bcdtoseg (
    input  logic[3:0] bcd,     // [3:0] sum 값
    output logic [7:0] fndFont
);
    // always 구문 출력으로 reg type을 가져야 한다
    always_comb begin
        case (bcd)
            4'h0: fndFont = 8'hC0;
            4'h1: fndFont = 8'hF9;
            4'h2: fndFont = 8'hA4;
            4'h3: fndFont = 8'hB0;
            4'h4: fndFont = 8'h99;
            4'h5: fndFont = 8'h92;
            4'h6: fndFont = 8'h82;
            4'h7: fndFont = 8'hF8;
            4'h8: fndFont = 8'h80;
            4'h9: fndFont = 8'h90;
            4'hA: fndFont = 8'h86;  // S
            4'hB: fndFont = 8'hC0;  // O
            4'hC: fndFont = 8'hAF; //r
            4'hD: fndFont = 8'hA1;
            4'hE: fndFont = 8'h86;
            4'hF: fndFont = 8'hff;  // dot
            default: fndFont = 8'hff;
        endcase
    end
endmodule

module digit_splitter (
    input  logic [13:0] i_data,
    output logic [3:0] x0,
    output logic [3:0] x1,
    output logic [3:0] x2,
    output logic [3:0] x3
);
     
    assign x0 = i_data % 10;
    assign x1 = i_data / 10 % 10;
    assign x2 = i_data / 100 % 10;
    assign x3 = i_data / 1000 % 10;
    
endmodule

module mux_4x1 (
    input  logic [1:0] sel,
    input  logic [3:0] x0,
    input  logic [3:0] x1,
    input  logic [3:0] x2,
    input  logic [3:0] x3,
    output logic [3:0] y
);
    always_comb begin
        y = 4'bx;
        case (sel)
            0: y = x0; 
            1: y = x1;
            2: y = x2;
            3: y = x3;
        endcase
    end
endmodule

module decoder (
    input  logic [1:0] counter,
    input  logic       FCR,
    output logic [3:0] fndComm
);
    always_comb begin
        fndComm = 4'bx;
        if(FCR == 0) begin
            fndComm = 4'b1111;  
        end else begin
            case (counter)
                0: fndComm = 4'b1110;
                1: fndComm = 4'b1101;
                2: fndComm = 4'b1011;
                3: fndComm = 4'b0111;
            endcase
        end
    end
endmodule

module counter (
    input  logic PCLK,
    input  logic tick,
    input  logic PRESET,
    output logic [1:0] counter
);
    always_ff @( posedge PCLK, posedge PRESET ) begin
        if(PRESET) begin
            counter <= 0;
        end else begin
            if(tick) begin
                counter <= counter + 1;
            end
        end
    end
endmodule


module clk_div (
    input  logic PCLK,
    input  logic PRESET,
    output logic tick
);
    //100_000_000;
    parameter FCOUNT = 100_000;
    logic [$clog2(FCOUNT)-1:0] clk_count_next, clk_count_reg;
    logic tick_next, tick_reg;
    assign tick = tick_reg;
    always_ff @( posedge PCLK, posedge PRESET ) begin
        if(PRESET) begin
            tick_reg        <= 0;
            clk_count_reg   <= 0;
        end else begin
            tick_reg        <= tick_next;
            clk_count_reg   <= clk_count_next; 
        end
    end
    always_comb begin
        clk_count_next = clk_count_reg;
        tick_next      = 0; 
        if(clk_count_reg == FCOUNT - 1)begin
            tick_next = 1;
            clk_count_next =0;
        end else begin
            tick_next = 0;
            clk_count_next = clk_count_reg + 1;
        end
    end
    
endmodule
