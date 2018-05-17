`include "stddef.h"
`include "cpu.v"
`include "gpio.v"
`include "timer.v"
`include "uart.v"
`include "rom.v"
`include "bus.v"

//`include "bus.h"

module chip(
    input wire                  clk,
    input wire                  clk_,
    input wire                  reset_,

    input  wire                 uart_rx,
    output wire                 uart_tx,

    input  wire [3:0]           gpio_in,
    output wire [17:0]          gpio_out,
    inout  wire [15:0]          gpio_io
);

    wire        m0_req_;
    wire        m1_req_;
    wire        m2_req_;
    wire        m3_req_;
    wire        m0_grnt_;   //
    wire        m1_grnt_;
    wire        m2_grnt_;
    wire        m3_grnt_;

    //
    wire    [`WordAddrBus]  if_bus_addr;
    wire                    if_bus_as_;
    wire                    if_bus_rw;
    wire    [`WordDataBus]  if_bus_wr_data;

    wire    [`WordAddrBus]  mem_bus_addr;
    wire                    mem_bus_as_;
    wire                    mem_bus_rw;
    wire    [`WordDataBus]  mem_bus_wr_data;

    wire    [`WordAddrBus]  m2_addr;
    wire                    m2_as_;
    wire                    m2_rw;
    wire    [`WordDataBus]  m2_wr_data;

    wire    [`WordAddrBus]  m3_addr;
    wire                    m3_as_;
    wire                    m3_rw;
    wire    [`WordDataBus]  m3_wr_data;

    wire    [`WordDataBus]  m_rd_data;
    wire                    m_rdy_;

    wire    [`WordAddrBus]  s_addr;
    wire                    s_as_;
    wire                    s_rw;
    wire    [`WordDataBus]  s_wr_data;
/*
    wire                    s0_cs_;
    wire                    s1_cs_;
    wire                    s2_cs_;
    wire                    s3_cs_;
    wire                    s4_cs_;
    wire                    s5_cs_;
    wire                    s6_cs_;
    wire                    s7_cs_;
*/
    //
    wire    [`WordDataBus]  s0_rd_data;
    wire                    s0_rdy_; //就绪

    wire    [`WordDataBus]  s1_rd_data;
    wire                    s1_rdy_; //就绪

    wire    [`WordDataBus]  s2_rd_data;
    wire                    s2_rdy_; //就绪

    wire    [`WordDataBus]  s3_rd_data;
    wire                    s3_rdy_; //就绪

    wire    [`WordDataBus]  s4_rd_data;
    wire                    s4_rdy_; //就绪

    wire    [`WordDataBus]  s5_rd_data;
    wire                    s5_rdy_; //就绪

    wire    [`WordDataBus]  s6_rd_data;
    wire                    s6_rdy_; //就绪

    wire    [`WordDataBus]  s7_rd_data;
    wire                    s7_rdy_; //就绪


    wire [`ByteDataBus] cpu_irq = {{5{`DISABLE}}, irq_timer, irq_tx, irq_rx};

    cpu cpu(
        .clk            (clk),
        .clk_           (clk_),
        .reset_         (reset_),

        .cpu_irq        (cpu_irq),

        .if_bus_rd_data (m_rd_data),
        .if_bus_rdy_    (m_rdy_),
        .if_bus_grnt_   (if_bus_grnt_),
        .if_bus_req_    (if_bus_req_),
        .if_bus_addr    (if_bus_addr),
        .if_bus_as_     (if_bus_as_),
        .if_bus_rw      (if_bus_rw),
        .if_bus_wr_data (if_bus_wr_data),

        .mem_bus_rd_data (m_rd_data),
        .mem_bus_rdy_    (m_rdy_),
        .mem_bus_grnt_   (mem_bus_grnt_),
        .mem_bus_req_    (mem_bus_req_),
        .mem_bus_addr    (mem_bus_addr),
        .mem_bus_as_     (mem_bus_as_),
        .mem_bus_rw      (mem_bus_rw),
        .mem_bus_wr_data (mem_bus_wr_data)

    );

    bus bus(
        .clk            (clk),
        .reset_         (reset_),

        .m_rdy_         (m_rdy_),
        .m_rd_data      (m_rd_data),

        .m0_addr        (if_bus_addr),
        .m0_grnt_       (if_bus_grnt_),
        .m0_as_         (if_bus_as_),
        .m0_rw          (if_bus_rw),
        .m0_wr_data     (if_bus_wr_data),
        .m0_req_        (if_bus_req_),

        .m1_addr        (mem_bus_addr),
        .m1_grnt_       (mem_bus_grnt_),
        .m1_as_         (mem_bus_as_),
        .m1_rw          (mem_bus_rw),
        .m1_wr_data     (mem_bus_wr_data),
        .m1_req_        (mem_bus_req_),

        .m2_addr        (`WORD_ADDR_W'h0),
//        .m2_grnt_       (`DISABLE_),
        .m2_as_         (`DISABLE_),
        .m2_rw          (`READ),
        .m2_wr_data     (`WORD_DATA_W'h0),
        .m2_req_        (`DISABLE_),

        .m3_addr        (`WORD_ADDR_W'h0),
//        .m3_grnt_       (`DISABLE_),
        .m3_as_         (`DISABLE_),
        .m3_rw          (`READ),
        .m3_wr_data     (`WORD_DATA_W'h0),
        .m3_req_        (`DISABLE_),

        .s_as_          (s_as_),
        .s_rw           (s_rw),
        .s_addr         (s_addr),
        .s_wr_data      (s_wr_data),

        .s0_rd_data     (s0_rd_data),
        .s0_rdy_        (s0_rdy_),
        .s0_cs_         (s0_cs_),

        .s2_rd_data     (s2_rd_data),
        .s2_rdy_        (s2_rdy_),
        .s2_cs_         (s2_cs_),

        .s3_rd_data     (s3_rd_data),
        .s3_rdy_        (s3_rdy_),
        .s3_cs_         (s3_cs_),

        .s4_rd_data     (s4_rd_data),
        .s4_rdy_        (s4_rdy_),
        .s4_cs_         (s4_cs_),

        .s5_rd_data     (`WORD_DATA_W'h0),
        .s5_rdy_        (`DISABLE_),
//        .s5_cs_         (`DISABLE_),

        .s6_rd_data     (`WORD_DATA_W'h0),
        .s6_rdy_        (`DISABLE_),
//        .s6_cs_         (`DISABLE_),

        .s7_rd_data     (`WORD_DATA_W'h0),
        .s7_rdy_        (`DISABLE_)
//        .s7_cs_         (`DISABLE_)
    );

    rom rom(
        .clk            (clk),
        .reset_         (reset_),

        .rd_data        (s0_rd_data),
        .rdy_           (s0_rdy_),
        .cs_            (s0_cs_),
        .as_            (s_as_),
        .addr           (s_addr)
    );

    timer timer(
        .clk            (clk),
        .reset_         (reset_),

        .rd_data        (s1_rd_data),
        .rdy_           (s1_rdy_),
        .cs_            (s1_cs_),
        .as_            (s_as_),
        .addr           (s_addr),
        .rw             (s_rw),
        .wr_data        (s_wr_data),
        .irq            (irq_timer)
    );

    uart uart(
        .clk            (clk),
        .reset_         (reset_),

        .rd_data        (s2_rd_data),
        .rdy_           (s2_rdy_),
        .cs_            (s2_cs_),
        .as_            (s_as_),
        .addr           (s_addr),
        .rw             (s_rw),
        .wr_data        (s_wr_data),

        .irq_tx         (irq_tx),
        .irq_rx         (irq_rx),
        .u_rx           (uart_rx),
        .u_tx           (uart_tx)
    );

    gpio gpio(
        .clk            (clk),
        .reset_         (reset_),

        .rd_data        (s4_rd_data),
        .rdy_           (s4_rdy_),
        .cs_            (s4_cs_),
        .as_            (s_as_),
        .addr           (s_addr),
        .rw             (s_rw),
        .wr_data        (s_wr_data),

        .gpio_in        (gpio_in),
        .gpio_out       (gpio_out),
        .gpio_io        (gpio_io)
    );

endmodule
