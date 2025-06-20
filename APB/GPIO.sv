`timescale 1ns / 1ps

module GPIO_Periph (
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
    inout logic [ 15:0] inoutPort
);

    logic [15:0] moder;
    logic [15:0] odr;
    logic [15:0] idr;
    APB_SlaveIntf_GPIO U_APB_Intf_GPIO (.*);
    GPIO U_GPIO_IP (.*);
endmodule

module APB_SlaveIntf_GPIO (
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
    output logic [15:0] moder,
    input  logic [15:0] idr,
    output logic [ 15:0] odr
);
    logic [31:0] slv_reg0, slv_reg1, slv_reg2;// slv_reg3;

    assign moder = slv_reg0[15:0];
    assign odr   = slv_reg2[15:0];
    assign slv_reg1[15:0] = idr;
    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            //slv_reg1 <= 0;
            slv_reg2 <= 0;
            // slv_reg3 <= 0;
        end else begin
            if (PSEL && PENABLE) begin
                PREADY <= 1'b1;
                if (PWRITE) begin
                    case (PADDR[3:2])
                        2'd0: slv_reg0 <= PWDATA;
                        2'd1: ;//slv_reg1 <= PWDATA;
                        2'd2: slv_reg2 <= PWDATA;
                        // 2'd3: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                    PRDATA <= 32'bx;
                    case (PADDR[3:2])
                        2'd0: PRDATA <= slv_reg0;
                        2'd1: PRDATA <= slv_reg1;
                        2'd2: PRDATA <= slv_reg2;
                        // 2'd3: PRDATA <= slv_reg3;
                    endcase
                end
            end else begin
                PREADY <= 1'b0;
            end
        end
    end

endmodule

module GPIO (
    input  logic [15:0] moder,
    output logic [15:0] idr,
    input  logic [15:0] odr,
    inout  logic [15:0] inoutPort
);

    genvar i;
    generate
        for (i = 0; i < 16; i++) begin
            assign inoutPort[i] = moder[i] ? odr[i] : 1'bz; //output 
            assign idr[i] = ~moder[i] ? inoutPort[i] : 1'bz; //input
        end
    endgenerate

    /*
    always_comb begin
        for (int i=0; i<8; i++) begin
            outPort[i] = moder[i] ? odr[i] : 1'bz;
        end
    end
*/
    /*
    assign outPort = moder[0] ? odr[0] : 1'bz;
    assign outPort = moder[1] ? odr[1] : 1'bz;
    assign outPort = moder[2] ? odr[2] : 1'bz;
    assign outPort = moder[3] ? odr[3] : 1'bz;
    assign outPort = moder[4] ? odr[4] : 1'bz;
    assign outPort = moder[5] ? odr[5] : 1'bz;
    assign outPort = moder[6] ? odr[6] : 1'bz;
    assign outPort = moder[7] ? odr[7] : 1'bz;
    */
endmodule
