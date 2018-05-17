`include "bus.h"
//`include "..\stddef.h"

//总线主控多路复用器
module bus_master_mux(
    input   wire    [`WordAddrBus]  m0_addr,
    input   wire                    m0_as_,
    input   wire                    m0_rw,
    input   wire    [`WordDataBus]  m0_wr_data,
    input   wire                    m0_grnt_,

    input   wire    [`WordAddrBus]  m1_addr,
    input   wire                    m1_as_,
    input   wire                    m1_rw,
    input   wire    [`WordDataBus]  m1_wr_data,
    input   wire                    m1_grnt_,

    input   wire    [`WordAddrBus]  m2_addr,
    input   wire                    m2_as_,
    input   wire                    m2_rw,
    input   wire    [`WordDataBus]  m2_wr_data,
    input   wire                    m2_grnt_,

    input   wire    [`WordAddrBus]  m3_addr,
    input   wire                    m3_as_,
    input   wire                    m3_rw,
    input   wire    [`WordDataBus]  m3_wr_data,
    input   wire                    m3_grnt_,

    output  reg     [`WordAddrBus]  s_addr,
    output  reg                     s_as_,
    output  reg                     s_rw,
    output  reg     [`WordDataBus]  s_wr_data
);

    always @(*) begin
        if (m0_grnt_ == `ENABLE_) begin //选择0号主控的信号
            s_addr      = m0_addr;
            s_as_       = m0_as_;
            s_rw       = m0_rw;
            s_wr_data   = m0_wr_data;
        end else if  (m1_grnt_ == `ENABLE_) begin
            s_addr      = m1_addr;
            s_as_       = m1_as_;
            s_rw       = m1_rw;
            s_wr_data   = m1_wr_data;
        end else if  (m2_grnt_ == `ENABLE_) begin
            s_addr      = m2_addr;
            s_as_       = m2_as_;
            s_rw       = m2_rw;
            s_wr_data   = m2_wr_data;
        end else if  (m3_grnt_ == `ENABLE_) begin
            s_addr      = m3_addr;
            s_as_       = m3_as_;
            s_rw       = m3_rw;
            s_wr_data   = m3_wr_data;
        end else begin                  //default
            s_addr      = `WORD_ADDR_W'h0;
            s_as_       = `DISABLE_;
            s_rw       = `READ;
            s_wr_data   = `WORD_DATA_W;
       end
    end

endmodule
