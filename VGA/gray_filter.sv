`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/05 14:08:29
// Design Name: 
// Module Name: gray_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module grayscale_filter (
    input  logic        pclk,
    input  logic        clk,
    input  logic [11:0] data_00_i,
    input  logic [11:0] data_01_i,
    input  logic [11:0] data_02_i,
    input  logic [11:0] data_10_i,
    input  logic [11:0] data_11_i,
    input  logic [11:0] data_12_i,
    input  logic [11:0] data_20_i,
    input  logic [11:0] data_21_i,
    input  logic [11:0] data_22_i,
    output logic [11:0] data_00_o,
    output logic [11:0] data_01_o,
    output logic [11:0] data_02_o,
    output logic [11:0] data_10_o,
    output logic [11:0] data_11_o,
    output logic [11:0] data_12_o,
    output logic [11:0] data_20_o,
    output logic [11:0] data_21_o,
    output logic [11:0] data_22_o
);
    localparam S0 = 0, S1 = 1, S2 = 2, S3 = 3;
    logic [1:0] state, state_next;
    logic [11:0] data_0_i, data_1_i, data_2_i;
    logic [11:0] data_0_o, data_1_o, data_2_o;
    logic [11:0] data_00_o_reg, data_00_o_next;
    logic [11:0] data_01_o_reg, data_01_o_next;
    logic [11:0] data_02_o_reg, data_02_o_next;
    logic [11:0] data_10_o_reg, data_10_o_next;
    logic [11:0] data_11_o_reg, data_11_o_next;
    logic [11:0] data_12_o_reg, data_12_o_next;
    logic [11:0] data_20_o_reg, data_20_o_next;
    logic [11:0] data_21_o_reg, data_21_o_next;
    logic [11:0] data_22_o_reg, data_22_o_next;
    assign data_00_o = data_00_o_reg;
    assign data_01_o = data_01_o_reg;
    assign data_02_o = data_02_o_reg;
    assign data_10_o = data_10_o_reg;
    assign data_11_o = data_11_o_reg;
    assign data_12_o = data_12_o_reg;
    assign data_20_o = data_20_o_reg;
    assign data_21_o = data_21_o_reg;
    assign data_22_o = data_22_o_reg;
    always_ff @(posedge clk, posedge pclk) begin
        if (pclk) begin
            state <= S0;
            data_00_o_reg <= 0;
            data_01_o_reg <= 0;
            data_02_o_reg <= 0;
            data_10_o_reg <= 0;
            data_11_o_reg <= 0;
            data_12_o_reg <= 0;
            data_20_o_reg <= 0;
            data_21_o_reg <= 0;
            data_22_o_reg <= 0;
        end else begin
            state <= state_next;
            data_00_o_reg <= data_00_o_next;
            data_01_o_reg <= data_01_o_next;
            data_02_o_reg <= data_02_o_next;
            data_10_o_reg <= data_10_o_next;
            data_11_o_reg <= data_11_o_next;
            data_12_o_reg <= data_12_o_next;
            data_20_o_reg <= data_20_o_next;
            data_21_o_reg <= data_21_o_next;
            data_22_o_reg <= data_22_o_next;
        end
    end

    always_comb begin
        state_next = state;
        data_00_o_next = data_00_o_reg;
        data_01_o_next = data_01_o_reg;
        data_02_o_next = data_02_o_reg;
        data_10_o_next = data_10_o_reg;
        data_11_o_next = data_11_o_reg;
        data_12_o_next = data_12_o_reg;
        data_20_o_next = data_20_o_reg;
        data_21_o_next = data_21_o_reg;
        data_22_o_next = data_22_o_reg;
        data_0_i = data_20_i;
        data_1_i = data_21_i;
        data_2_i = data_22_i;
        case (state)
            S0: begin
                data_0_i = data_00_i;
                data_1_i = data_01_i;
                data_2_i = data_02_i;
                data_00_o_next = data_0_o;
                data_01_o_next = data_1_o;
                data_02_o_next = data_2_o;
                state_next = S1;
            end
            S1: begin
                data_0_i = data_10_i;
                data_1_i = data_11_i;
                data_2_i = data_12_i;
                data_10_o_next = data_0_o;
                data_11_o_next = data_1_o;
                data_12_o_next = data_2_o;
                state_next = S2;
            end
            S2: begin
                data_0_i = data_20_i;
                data_1_i = data_21_i;
                data_2_i = data_22_i;
                data_20_o_next = data_0_o;
                data_21_o_next = data_1_o;
                data_22_o_next = data_2_o;
                state_next = S3;
            end
            S3: begin
                state_next = S0;
            end
        endcase
    end
    grayscale_converter U_GRAY_00 (
        .red_port  (data_0_i[11:8]),
        .green_port(data_0_i[7:4]),
        .blue_port (data_0_i[3:0]),
        .g_port    (data_0_o)
    );
    grayscale_converter U_GRAY_01 (
        .red_port  (data_1_i[11:8]),
        .green_port(data_1_i[7:4]),
        .blue_port (data_1_i[3:0]),
        .g_port    (data_1_o)
    );
    grayscale_converter U_GRAY_02 (
        .red_port  (data_2_i[11:8]),
        .green_port(data_2_i[7:4]),
        .blue_port (data_2_i[3:0]),
        .g_port    (data_2_o)
    );
endmodule



module grayscale_converter (
    input  logic [ 3:0] red_port,
    input  logic [ 3:0] green_port,
    input  logic [ 3:0] blue_port,
    output logic [11:0] g_port
);
    logic [10:0] red;
    logic [11:0] green;
    logic [ 8:0] blue;
    logic [12:0] gray;
    assign red = (red_port * 77);
    assign green = (green_port * 150);
    assign blue = (blue_port * 29);
    assign gray = red + green + blue;

    assign g_port = gray[12:1];
endmodule
