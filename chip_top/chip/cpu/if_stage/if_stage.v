//`include "..\..\..\stddef.h"
//`include "..\cpu.h"
//`include "bus_if.v"
//`include "if_reg.v"

module if_stage(
    /***** 共同 *****/
    input wire                  clk,
    input wire                  reset_,
    input  wire                 stall,
    input  wire                 flush,

    /***** bus_if *****/
    output wire                  busy,

    //SPM
    input  wire [`WordDataBus]  spm_rd_data,
    output wire [`WordAddrBus]  spm_addr,
    output wire                 spm_as_,
    output wire                 spm_rw,
    output wire [`WordDataBus]  spm_wr_data,

    //BUS
    input  wire [`WordDataBus]  bus_rd_data,
    input  wire                 bus_rdy_,
    input  wire                 bus_grnt_,
    output wire                 bus_req_,
    output wire [`WordAddrBus]  bus_addr,
    output wire                 bus_as_,
    output wire                 bus_rw,
    output wire [`WordDataBus]  bus_wr_data,

    /****** if_reg *******/
//    input wire  [`WordDataBus]  insn,

    //流水线控制信号
    input  wire [`WordAddrBus]  new_pc,
    input  wire                 br_taken,
    input  wire [`WordAddrBus]  br_addr,

    //IF/ID 流水线寄存器
    output wire [`WordAddrBus]  if_pc,
    output wire [`WordDataBus]  if_insn,
    output wire                 if_en

);
    wire    [`WordDataBus]  temp_rd_data;

    if_reg if_reg0(
        .clk            (clk),
        .reset_         (reset_),
        .stall          (stall),
        .flush          (flush),

        .insn           (temp_rd_data),

        .new_pc         (new_pc),
        .br_taken       (br_taken),
        .br_addr        (br_addr),
        .if_pc          (if_pc),
        .if_insn        (if_insn),
        .if_en          (if_en)
    );

    bus_if bus_if0(
        .clk            (clk),
        .reset_         (reset_),

        //流水线控制信号
        .stall          (stall),
        .flush          (flush),
        .busy           (busy),

        //CPU接口
        .addr           (if_pc),
        .as_            (`ENABLE_),
        .rw             (`READ),
        .wr_data        (`WORD_DATA_W'h0),
        .rd_data        (temp_rd_data),

        //SPM
        .spm_rd_data    (spm_rd_data),
        .spm_addr       (spm_addr),
        .spm_as_        (spm_as_),
        .spm_rw         (spm_rw),
        .spm_wr_data    (spm_wr_data),

        //BUS
        .bus_rd_data    (bus_rd_data),
        .bus_rdy_       (bus_rdy_),
        .bus_grnt_      (bus_grnt_),
        .bus_req_       (bus_req_),
        .bus_addr       (bus_addr),
        .bus_as_        (bus_as_),
        .bus_rw         (bus_rw),
        .bus_wr_data    (bus_wr_data)
    );

endmodule
