`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/06/05 12:37:35
// Design Name: 
// Module Name: pipeline_register
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


module pipeline_register_s0_s1 (
    input  logic       pclk,
    input  logic       DE_s0,
    input  logic       v_sync_s0,
    input  logic       h_sync_s0,
    input  logic [9:0] x_pixel_s0,
    input  logic [9:0] y_pixel_s0,
    output logic       DE_s1,
    output logic       v_sync_s1,
    output logic       h_sync_s1,
    output logic [9:0] x_pixel_s1,
    output logic [9:0] y_pixel_s1
);
    always_ff @(posedge pclk) begin
        DE_s1      <= DE_s0;
        v_sync_s1  <= v_sync_s0;
        h_sync_s1  <= h_sync_s0;
        x_pixel_s1 <= x_pixel_s0;
        y_pixel_s1 <= y_pixel_s0;
    end
endmodule

module pipeline_register_s1_s2 (
    input  logic       pclk,
    input  logic       DE_s1,
    input  logic       v_sync_s1,
    input  logic       h_sync_s1,
    input  logic [9:0] x_pixel_s1,
    input  logic [9:0] y_pixel_s1,
    output logic       DE_s2,
    output logic       v_sync_s2,
    output logic       h_sync_s2,
    output logic [9:0] x_pixel_s2,
    output logic [9:0] y_pixel_s2
);
    always_ff @(posedge pclk) begin
        DE_s2      <= DE_s1;
        v_sync_s2  <= v_sync_s1;
        h_sync_s2  <= h_sync_s1;
        x_pixel_s2 <= x_pixel_s1;
        y_pixel_s2 <= y_pixel_s1;
    end
endmodule

module pipeline_register_s2_s3 (
    input  logic       pclk,
    input  logic       DE_s2,
    input  logic       v_sync_s2,
    input  logic       h_sync_s2,
    input  logic [9:0] x_pixel_s2,
    input  logic [9:0] y_pixel_s2,
    output logic       DE_s3,
    output logic       v_sync_s3,
    output logic       h_sync_s3,
    output logic [9:0] x_pixel_s3,
    output logic [9:0] y_pixel_s3
);
    always_ff @(posedge pclk) begin
        DE_s3      <= DE_s2;
        v_sync_s3  <= v_sync_s2;
        h_sync_s3  <= h_sync_s2;
        x_pixel_s3 <= x_pixel_s2;
        y_pixel_s3 <= y_pixel_s2;
    end
endmodule


module pipeline_register_s3_s4 (
    input  logic        pclk,
    input  logic [11:0] data_00_s3_g,
    input  logic [11:0] data_01_s3_g,
    input  logic [11:0] data_02_s3_g,
    input  logic [11:0] data_10_s3_g,
    input  logic [11:0] data_11_s3_g,
    input  logic [11:0] data_12_s3_g,
    input  logic [11:0] data_20_s3_g,
    input  logic [11:0] data_21_s3_g,
    input  logic [11:0] data_22_s3_g,
    output logic [11:0] data_00_s4_g,
    output logic [11:0] data_01_s4_g,
    output logic [11:0] data_02_s4_g,
    output logic [11:0] data_10_s4_g,
    output logic [11:0] data_11_s4_g,
    output logic [11:0] data_12_s4_g,
    output logic [11:0] data_20_s4_g,
    output logic [11:0] data_21_s4_g,
    output logic [11:0] data_22_s4_g
);
    always_ff @(posedge pclk) begin
        data_00_s4_g <= data_00_s3_g;
        data_01_s4_g <= data_01_s3_g;
        data_02_s4_g <= data_02_s3_g;
        data_10_s4_g <= data_10_s3_g;
        data_11_s4_g <= data_11_s3_g;
        data_12_s4_g <= data_12_s3_g;
        data_20_s4_g <= data_20_s3_g;
        data_21_s4_g <= data_21_s3_g;
        data_22_s4_g <= data_22_s3_g;
    end
endmodule
