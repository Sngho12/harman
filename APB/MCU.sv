`timescale 1ns / 1ps

module MCU (
    input  logic       clk,
    input  logic       reset,
    //output logic [7:0] GPOA,
    input  logic [7:0] GPIB,
    inout  logic [15:0] GPIOC,
    inout  logic [15:0] GPIOD,
    // FND
    output logic [3:0] fndComm,
    output logic [7:0] fndFont,
    // US
    input  logic       echo,
    output logic       us_start_trigger,
    // DHT
    inout  logic        dht_io,
    // output logic      [5:0] led,
    // UART
    input  logic rx,
    output logic tx
);
    logic        en;
    logic        cal_done;
    logic      [5:0] led;
    logic [7:0] GPOA;
    
    // global signals
    logic        PCLK;
    logic        PRESET;
    // APB Interface Signals
    logic [31:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL_RAM;
    logic        PSEL_GPO;
    logic        PSEL_GPI;
    logic        PSEL_GPIOC;
    logic        PSEL_GPIOD;
    logic        PSEL_FNDE;
    logic        PSEL_TIMER;
    logic        PSEL_UART; 
    logic        PSEL_US;
    logic        PSEL_DHT;
    logic [31:0] PRDATA_RAM;
    logic [31:0] PRDATA_GPO;
    logic [31:0] PRDATA_GPI;
    logic [31:0] PRDATA_GPIOC;
    logic [31:0] PRDATA_GPIOD;
    logic [31:0] PRDATA_FNDE;
    logic [31:0] PRDATA_TIMER;
    logic [31:0] PRDATA_UART;
    logic [31:0] PRDATA_US;
    logic [31:0] PRDATA_DHT;
    logic        PREADY_RAM;
    logic        PREADY_GPO;
    logic        PREADY_GPI;
    logic        PREADY_GPIOC;
    logic        PREADY_GPIOD;
    logic        PREADY_FNDE;
    logic        PREADY_TIMER;
    logic        PREADY_UART;
    logic        PREADY_US;
    logic        PREADY_DHT;

    // CPU - APB_Master Signals
    // Internal Interface Signals
    logic        transfer;  // trigger signal
    logic        ready;
    logic [31:0] addr;
    logic [31:0] wdata;
    logic [31:0] rdata;
    logic        write;  // 1:write, 0:read
    logic        dataWe;
    logic [31:0] dataAddr;
    logic [31:0] dataWData;
    logic [31:0] dataRData;

    // ROM Signals
    logic [31:0] w_instrCode, instrCode;
    logic [31:0] instrMemAddr;

    assign PCLK = clk;
    assign PRESET = reset;
    assign addr = dataAddr;
    assign wdata = dataWData;
    assign dataRData = rdata;
    assign write = dataWe;

    rom U_ROM (
        .addr(instrMemAddr),
        .data(w_instrCode)
    );
    
    register U_wait (
        .clk  (clk),
        .reset(reset),
        .d    (w_instrCode),
        .q    (instrCode)
    );
    RV32I_Core U_Core (.*);

    APB_Master U_APB_Master (
        .*,
        .PSEL0  (PSEL_RAM),
        .PSEL1  (PSEL_GPO),
        .PSEL2  (PSEL_GPI),
        .PSEL3  (PSEL_GPIOC),
        .PSEL4  (PSEL_GPIOD),
        .PSEL5  (PSEL_FNDE),
        .PSEL6  (PSEL_TIMER),
        .PSEL7  (PSEL_UART),
        .PSEL8  (PSEL_US),
        .PSEL9  (PSEL_DHT),
        .PRDATA0(PRDATA_RAM),
        .PRDATA1(PRDATA_GPO),
        .PRDATA2(PRDATA_GPI),
        .PRDATA3(PRDATA_GPIOC),
        .PRDATA4(PRDATA_GPIOD),
        .PRDATA5(PRDATA_FNDE),
        .PRDATA6(PRDATA_TIMER),
        .PRDATA7(PRDATA_UART),
        .PRDATA8(PRDATA_US),
        .PRDATA9(PRDATA_DHT),
        .PREADY0(PREADY_RAM),
        .PREADY1(PREADY_GPO),
        .PREADY2(PREADY_GPI),
        .PREADY3(PREADY_GPIOC),
        .PREADY4(PREADY_GPIOD), 
        .PREADY5(PREADY_FNDE),
        .PREADY6(PREADY_TIMER),
        .PREADY7(PREADY_UART),
        .PREADY8(PREADY_US),
        .PREADY9(PREADY_DHT)
    );

    ram U_RAM (
        .*,
        .PSEL  (PSEL_RAM),
        .PRDATA(PRDATA_RAM),
        .PREADY(PREADY_RAM)
    );

    GPO_Periph U_GPOA (
        .*,
        .PSEL   (PSEL_GPO),
        .PRDATA (PRDATA_GPO),
        .PREADY (PREADY_GPO),
        // export signals
        .outPort(GPOA)
    );

    GPI_Periph U_GPIB (
        .*,
        .PSEL  (PSEL_GPI),
        .PRDATA(PRDATA_GPI),
        .PREADY(PREADY_GPI),
        // inport signals
        .inPort(GPIB)
    );

    GPIO_Periph U_GPIOC(
    .*,
    .PSEL(PSEL_GPIOC),
    .PRDATA(PRDATA_GPIOC), 
    .PREADY(PREADY_GPIOC),
    .inoutPort(GPIOC)
    );
    GPIO_Periph U_GPIOD(
    .*,
    .PSEL(PSEL_GPIOD),
    .PRDATA(PRDATA_GPIOD),
    .PREADY(PREADY_GPIOD),
    .inoutPort(GPIOD)
    );
    FND_Periph U_FNDE(
        .*,
        .PSEL(PSEL_FNDE),
        .PRDATA(PRDATA_FNDE),
        .PREADY(PREADY_FNDE)
    );
    timer_periph U_TIMER(
        .*,
        .PSEL(PSEL_TIMER),
        .PRDATA(PRDATA_TIMER),
        .PREADY(PREADY_TIMER)
    );

    UART_Periph U_UART (
        .*,
        .PSEL(PSEL_UART),
        .PRDATA(PRDATA_UART),
        .PREADY(PREADY_UART),
        .rx(rx),
        .tx(tx)
    );

    UltraSonic_Periph U_US(
        .*,
        .PSEL(PSEL_US),
        .PRDATA(PRDATA_US),
        .PREADY(PREADY_US),
        .echo(echo),
        .start_trigger(us_start_trigger)
        );

    dht_periph U_DHT (
        .*,
        .PSEL(PSEL_DHT),
        .PRDATA(PRDATA_DHT),
        .PREADY(PREADY_DHT),
        .dht_io(dht_io),
        .led(led)
    );
endmodule
