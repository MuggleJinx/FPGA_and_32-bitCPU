//`include "mem_ctrl.v"
//`include "..\if_stage\bus_if.v"
//`include "mem_reg.v"

module mem_stage(
    input wire                  clk,
    input wire                  reset_,
    input  wire                 stall,
    input  wire                 flush,

    output wire [`WordDataBus] fwd_data,

    //bus_if
    input  wire [`WordDataBus]  bus_rd_data,
    input  wire                 bus_rdy_,
    input  wire                 bus_grnt_,
    output wire                 bus_req_,
    output wire [`WordAddrBus]  bus_addr,
    output wire                 bus_as_,
    output wire                 bus_rw,
    output wire [`WordDataBus]  bus_wr_data,
    //spm
    input  wire [`WordDataBus]  spm_rd_data,
    output wire [`WordAddrBus]  spm_addr,
    output wire                 spm_as_,
    output wire                 spm_rw,
    output wire [`WordDataBus]  spm_wr_data,

    output wire                 busy,

    //mem_ctrl
    input wire                 ex_en,
    input wire [`MemOpBus]     ex_mem_op,
    input wire [`WordDataBus]  ex_mem_wr_data,
    input wire [`WordDataBus]  ex_out,

    // mem_reg
    input wire [`WordAddrBus]  ex_pc,
    input wire                 ex_br_flag,
    input wire [`CtrlOpBus]    ex_ctrl_op,
    input wire [`RegAddrBus]   ex_dst_addr,
    input wire                 ex_gpr_we_,
    input wire [`IsaExpBus]    ex_exp_code,

    // mem/wb reg
    output wire [`WordAddrBus]  mem_pc,
    output wire                 mem_en,
    output wire                 mem_br_flag,
    output wire [`CtrlOpBus]    mem_ctrl_op,
    output wire [`RegAddrBus]   mem_dst_addr,
    output wire                 mem_gpr_we_,
    output wire [`IsaExpBus]    mem_exp_code,
    output wire [`WordDataBus]  mem_out
);

    wire [`WordDataBus]  rd_data;
    wire [`WordAddrBus]  addr;
    wire                 as_;
    wire                 rw;
    wire [`WordDataBus]  wr_data;

    wire [`WordDataBus]  out;
    wire                 miss_align;

    bus_if bus_if1(
        .clk            (clk),
        .reset_         (reset_),

        //流水线控制信号
        .stall          (stall),
        .flush          (flush),
        .busy           (busy),

        //CPU接口
        .addr           (addr),
        .as_            (as_),
        .rw             (rw),
        .wr_data        (wr_data),
        .rd_data        (rd_data),

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

    mem_ctrl mem_ctrl0(
        .ex_en          (ex_en),
        .ex_mem_op      (ex_mem_op),
        .ex_mem_wr_data (ex_mem_wr_data),
        .ex_out         (ex_out),

        .rd_data        (rd_data),
        .addr           (addr),
        .as_            (as_),
        .rw             (rw),
        .wr_data        (wr_data),

        .out            (out),
        .miss_align     (miss_align)
    );

    mem_reg mem_reg0(
        .clk            (clk),
        .reset_         (reset_),

        //流水线控制信号
        .stall          (stall),
        .flush          (flush),

        .out            (out),
        .miss_align     (miss_align),

        .ex_pc          (ex_pc),
        .ex_en          (ex_en),
        .ex_br_flag     (ex_br_flag),
        .ex_ctrl_op     (ex_ctrl_op),
        .ex_dst_addr    (ex_dst_addr),
        .ex_gpr_we_     (ex_gpr_we_),
        .ex_exp_code    (ex_exp_code),

        .mem_pc         (mem_pc),
        .mem_en         (mem_en),
        .mem_br_flag    (mem_br_flag),
        .mem_ctrl_op    (mem_ctrl_op),
        .mem_dst_addr   (mem_dst_addr),
        .mem_gpr_we_    (mem_gpr_we_),
        .mem_exp_code   (mem_exp_code),
        .mem_out        (mem_out)
    );

endmodule
