`include "bus.h"
//`include "..\stddef.h"

`include "bus_arbiter.v"
`include "bus_master_mux.v"
`include "bus_addr_dec.v"
`include "bus_slave_mux.v"

module bus(
    input   wire        clk,
    input   wire        reset_,

    input   wire        m0_req_,
    input   wire        m1_req_,
    input   wire        m2_req_,
    input   wire        m3_req_,
    output  wire        m0_grnt_,   //
    output  wire        m1_grnt_,
    output  wire        m2_grnt_,
    output  wire        m3_grnt_,

    //
    input   wire    [`WordAddrBus]  m0_addr,
    input   wire                    m0_as_,
    input   wire                    m0_rw,
    input   wire    [`WordDataBus]  m0_wr_data,

    input   wire    [`WordAddrBus]  m1_addr,
    input   wire                    m1_as_,
    input   wire                    m1_rw,
    input   wire    [`WordDataBus]  m1_wr_data,

    input   wire    [`WordAddrBus]  m2_addr,
    input   wire                    m2_as_,
    input   wire                    m2_rw,
    input   wire    [`WordDataBus]  m2_wr_data,

    input   wire    [`WordAddrBus]  m3_addr,
    input   wire                    m3_as_,
    input   wire                    m3_rw,
    input   wire    [`WordDataBus]  m3_wr_data,

    output  wire    [`WordAddrBus]  s_addr,
    output  wire                    s_as_,
    output  wire                    s_rw,
    output  wire    [`WordDataBus]  s_wr_data,

    //
    output  wire                    s0_cs_,
    output  wire                    s1_cs_,
    output  wire                    s2_cs_,
    output  wire                    s3_cs_,
    output  wire                    s4_cs_,
    output  wire                    s5_cs_,
    output  wire                    s6_cs_,
    output  wire                    s7_cs_,

    //
    input   wire    [`WordDataBus]  s0_rd_data,
    input   wire                    s0_rdy_, //就绪

    input   wire    [`WordDataBus]  s1_rd_data,
    input   wire                    s1_rdy_,

    input   wire    [`WordDataBus]  s2_rd_data,
    input   wire                    s2_rdy_,

    input   wire    [`WordDataBus]  s3_rd_data,
    input   wire                    s3_rdy_,

    input   wire    [`WordDataBus]  s4_rd_data,
    input   wire                    s4_rdy_,

    input   wire    [`WordDataBus]  s5_rd_data,
    input   wire                    s5_rdy_,

    input   wire    [`WordDataBus]  s6_rd_data,
    input   wire                    s6_rdy_,

    input   wire    [`WordDataBus]  s7_rd_data,
    input   wire                    s7_rdy_,

    output  wire    [`WordDataBus]  m_rd_data,
    output  wire                    m_rdy_
);

    bus_arbiter arbiter (
        .clk        (clk),
        .reset_     (reset_),

        .m0_req_    (m0_req_),
        .m1_req_    (m1_req_),
        .m2_req_    (m2_req_),
        .m3_req_    (m3_req_),
        .m0_grnt_   (m0_grnt_),
        .m1_grnt_   (m0_grnt_),
        .m2_grnt_   (m0_grnt_),
        .m3_grnt_   (m0_grnt_)
    );

//    wire mm0_req_ = m0_req_;
//    wire mm1_req_ = m1_req_;
//    wire mm2_req_ = m2_req_;
//    wire mm3_req_ = m3_req_;

    bus_master_mux master_mux(
        .m0_addr    (m0_addr),
        .m0_as_     (m0_as_),
        .m0_rw      (m0_rw),
        .m0_wr_data (m0_wr_data),
        .m0_grnt_   (m0_grnt_),

        .m1_addr    (m1_addr),
        .m1_as_     (m1_as_),
        .m1_rw      (m1_rw),
        .m1_wr_data (m1_wr_data),
        .m1_grnt_   (m1_grnt_),

        .m2_addr    (m2_addr),
        .m2_as_     (m2_as_),
        .m2_rw      (m2_rw),
        .m2_wr_data (m2_wr_data),
        .m2_grnt_   (m2_grnt_),

        .m3_addr    (m3_addr),
        .m3_as_     (m3_as_),
        .m3_rw      (m3_rw),
        .m3_wr_data (m3_wr_data),
        .m3_grnt_   (m3_grnt_),

        .s_addr     (s_addr),
        .s_as_      (s_as_),
        .s_rw       (s_rw),
        .s_wr_data  (s_wr_data)
    );

    bus_addr_dec adder_dec(
        .s_addr     (s_addr),
        .s0_cs_     (s0_cs_),
        .s1_cs_     (s1_cs_),
        .s2_cs_     (s2_cs_),
        .s3_cs_     (s3_cs_),
        .s4_cs_     (s4_cs_),
        .s5_cs_     (s5_cs_),
        .s6_cs_     (s6_cs_),
        .s7_cs_     (s7_cs_)
    );

    bus_slave_mux slave_mux(
        .s0_cs_     (s0_cs_),
        .s0_rd_data (s0_rd_data),
        .s0_rdy_    (s0_rdy_),

        .s1_cs_     (s1_cs_),
        .s1_rd_data (s1_rd_data),
        .s1_rdy_    (s1_rdy_),

        .s2_cs_     (s2_cs_),
        .s2_rd_data (s2_rd_data),
        .s2_rdy_    (s2_rdy_),

        .s3_cs_     (s3_cs_),
        .s3_rd_data (s3_rd_data),
        .s3_rdy_    (s3_rdy_),

        .s4_cs_     (s4_cs_),
        .s4_rd_data (s4_rd_data),
        .s4_rdy_    (s4_rdy_),

        .s5_cs_     (s5_cs_),
        .s5_rd_data (s5_rd_data),
        .s5_rdy_    (s5_rdy_),

        .s6_cs_     (s6_cs_),
        .s6_rd_data (s6_rd_data),
        .s6_rdy_    (s6_rdy_),

        .s7_cs_     (s7_cs_),
        .s7_rd_data (s7_rd_data),
        .s7_rdy_    (s7_rdy_),

        .m_rd_data  (m_rd_data),
        .m_rdy_     (m_rdy_)
    );

endmodule
