`include "..\..\stddef.h"
`include "cpu.h"
`include "spm.h"
`include "isa.h"
`include "..\bus\bus.h"
`include "..\rom\rom.h"

`include "gpr\gpr.v"
`include "spm\spm.v"
//`include "spm\x_s3e_dpram.v"
`include "if_stage\if_stage.v"
`include "if_stage\bus_if.v"
`include "if_stage\if_reg.v"
`include "id_stage\id_stage.v"
`include "id_stage\id_reg.v"
`include "id_stage\decoder.v"
`include "ex_stage\ex_stage.v"
`include "ex_stage\alu.v"
`include "ex_stage\ex_reg.v"
`include "mem_stage\mem_stage.v"
`include "mem_stage\mem_reg.v"
`include "mem_stage\mem_ctrl.v"
`include "ctrl\ctrl.v"

module cpu(
    input wire                  clk,
    input wire                  clk_,
    input wire                  reset_,

    input  wire [`WordDataBus]  if_bus_rd_data,
    input  wire                 if_bus_rdy_,
    input  wire                 if_bus_grnt_,
    output wire                 if_bus_req_,
    output wire [`WordAddrBus]  if_bus_addr,
    output wire                 if_bus_as_,
    output wire                 if_bus_rw,
    output wire [`WordDataBus]  if_bus_wr_data,

    input wire  [`ByteDataBus]  cpu_irq,

    input  wire [`WordDataBus]  mem_bus_rd_data,
    input  wire                 mem_bus_rdy_,
    input  wire                 mem_bus_grnt_,
    output wire                 mem_bus_req_,
    output wire [`WordAddrBus]  mem_bus_addr,
    output wire                 mem_bus_as_,
    output wire                 mem_bus_rw,
    output wire [`WordDataBus]  mem_bus_wr_data
);

    wire [`WordAddrBus]  new_pc;
    wire                 br_taken;
    wire [`WordAddrBus]  br_addr;

    wire                 if_stall;
    wire                 if_flush;
    wire                 if_busy;
    wire                 id_stall;
    wire                 id_flush;
    wire                 ex_stall;
    wire                 ex_flush;
    wire                 mem_stall;
    wire                 mem_flush;
    wire                 mem_busy;

    //IF/ID 流水线寄存器
    wire [`WordAddrBus]  if_pc;
    wire [`WordDataBus]  if_insn;
    wire                 if_en;

    wire [`WordDataBus]  if_spm_rd_data;
    wire [`WordAddrBus]  if_spm_addr;
    wire                 if_spm_as_;
    wire                 if_spm_rw;
    wire [`WordDataBus]  if_spm_wr_data;

    // ID
    wire [`RegAddrBus]   gpr_rd_addr_0;
    wire [`WordDataBus]  gpr_rd_data_0;
    wire [`RegAddrBus]   gpr_rd_addr_1;
    wire [`WordDataBus]  gpr_rd_data_1;

    wire  [`WordAddrBus] id_pc;
    wire                 id_en;
    wire [`AluOpBus]     id_alu_op;
    wire [`WordDataBus]  id_alu_in_0;
    wire [`WordDataBus]  id_alu_in_1;
    wire                 id_br_flag;
    wire [`MemOpBus]     id_mem_op;
    wire [`WordDataBus]  id_mem_wr_data;
    wire [`CtrlOpBus]    id_ctrl_op;
    wire [`RegAddrBus]   id_dst_addr;
    wire                 id_gpr_we_;
    wire [`IsaExpBus]    id_exp_code;

    wire                 ld_hazard;
    wire                 exe_mode;
    wire [`WordDataBus]  creg_rd_data;
    wire [`RegAddrBus]   creg_rd_addr;

    wire [`WordDataBus]  mem_fwd_data;

//    wire                 ex_en;
//    wire [`RegAddrBus]   ex_dst_addr;
//    wire                 ex_gpr_we_;
    wire [`WordDataBus]  ex_fwd_data;

    wire  [`WordAddrBus] ex_pc;
    wire                 ex_en;
    wire                 ex_br_flag;
    wire [`MemOpBus]     ex_mem_op;
    wire [`WordDataBus]  ex_mem_wr_data;
    wire [`CtrlOpBus]    ex_ctrl_op;
    wire [`RegAddrBus]   ex_dst_addr;
    wire                 ex_gpr_we_;
    wire [`IsaExpBus]    ex_exp_code;
    wire [`WordDataBus]  ex_out;

    wire [`WordDataBus]  mem_spm_rd_data;
    wire [`WordAddrBus]  mem_spm_addr;
    wire                 mem_spm_as_;
    wire                 mem_spm_rw;
    wire [`WordDataBus]  mem_spm_wr_data;

    wire [`WordAddrBus]  mem_pc;
    wire                 mem_en;
    wire                 mem_br_flag;
    wire [`CtrlOpBus]    mem_ctrl_op;
    wire [`RegAddrBus]   mem_dst_addr;
    wire                 mem_gpr_we_;
    wire [`IsaExpBus]    mem_exp_code;
    wire [`WordDataBus]  mem_out;



    /**** IF ****/
    if_stage if_stage0(
        .clk            (clk),
        .reset_         (reset_),

        .bus_rd_data    (if_bus_rd_data),
        .bus_rdy_       (if_bus_rdy_),
        .bus_grnt_      (if_bus_grnt_),
        .bus_req_       (if_bus_req_),
        .bus_addr       (if_bus_addr),
        .bus_as_        (if_bus_as_),
        .bus_rw         (if_bus_rw),
        .bus_wr_data    (if_bus_wr_data),

        //spm
        .spm_rd_data    (if_spm_rd_data),
        .spm_addr       (if_spm_addr),
        .spm_as_        (if_spm_as_),
        .spm_rw         (if_spm_rw),
        .spm_wr_data    (if_spm_wr_data),

        //ctrl
        .stall          (if_stall),
        .flush          (if_flush),
        .busy           (if_busy),
        .new_pc         (new_pc),

        //id_stage
        .br_taken       (br_taken),
        .br_addr        (br_addr),
        .if_pc          (if_pc),
        .if_insn        (if_insn),
        .if_en          (if_en)
    );

    /**** ID ****/
    id_stage id_stage0(
        .clk            (clk),
        .reset_         (reset_),

        .stall          (id_stall),
        .flush          (id_flush),

        .br_taken       (br_taken),
        .br_addr        (br_addr),
        .if_pc          (if_pc),
        .if_insn        (if_insn),
        .if_en          (if_en),

        //gpr
        .gpr_rd_addr_0  (gpr_rd_addr_0),
        .gpr_rd_data_0  (gpr_rd_data_0),
        .gpr_rd_addr_1  (gpr_rd_addr_1),
        .gpr_rd_data_1  (gpr_rd_data_1),

        //
        .mem_fwd_data    (mem_fwd_data),
        //
        .ex_en          (ex_en),
        .ex_dst_addr    (ex_dst_addr),
        .ex_gpr_we_     (ex_gpr_we_),
        .ex_fwd_data    (ex_fwd_data),

        //
        .ld_hazard      (ld_hazard),

        .id_pc          (id_pc),
        .id_en          (id_en),
        .id_alu_op      (id_alu_op),
        .id_alu_in_0    (id_alu_in_0),
        .id_alu_in_1    (id_alu_in_1),
        .id_br_flag     (id_br_flag),
        .id_mem_op      (id_mem_op),
        .id_mem_wr_data (id_mem_wr_data),
        .id_ctrl_op     (id_ctrl_op),
        .id_dst_addr    (id_dst_addr),
        .id_gpr_we_     (id_gpr_we_),
        .id_exp_code    (id_exp_code),

        // 控制寄存器接口
        .exe_mode       (exe_mode),
        .creg_rd_data   (creg_rd_data),
        .creg_rd_addr   (creg_rd_addr)
    );

    /**** EX ****/
    ex_stage ex_stage0(
        .clk            (clk),
        .reset_         (reset_),
        .stall          (ex_stall),
        .flush          (ex_flsuh),
        .int_detect     (int_detect),

        .fwd_data       (ex_fwd_data),
        .id_pc          (id_pc),
        .id_en          (id_en),
        .id_alu_op      (id_alu_op),
        .id_alu_in_0    (id_alu_in_0),
        .id_alu_in_1    (id_alu_in_1),
        .id_br_flag     (id_br_flag),
        .id_mem_op      (id_mem_op),
        .id_mem_wr_data (id_mem_wr_data),
        .id_ctrl_op     (id_ctrl_op),
        .id_dst_addr    (id_dst_addr),
        .id_gpr_we_     (id_gpr_we_),
        .id_exp_code    (id_exp_code),

        .ex_pc          (ex_pc),
        .ex_en          (ex_en),
        .ex_br_flag     (ex_br_flag),
        .ex_mem_op      (ex_mem_op),
        .ex_mem_wr_data (ex_mem_wr_data),
        .ex_ctrl_op     (ex_ctrl_op),
        .ex_dst_addr    (ex_dst_addr),
        .ex_gpr_we_     (ex_gpr_we_),
        .ex_exp_code    (ex_exp_code),
        .ex_out         (ex_out)
    );

    /**** MEM ****/
    mem_stage mem_stage0(
        .clk            (clk),
        .reset_         (reset_),
        .stall          (mem_stall),
        .flush          (mem_flsuh),
        .busy           (mem_busy),

        .fwd_data       (mem_fwd_data),

        .ex_pc          (ex_pc),
        .ex_en          (ex_en),
        .ex_br_flag     (ex_br_flag),
        .ex_mem_op      (ex_mem_op),
        .ex_mem_wr_data (ex_mem_wr_data),
        .ex_ctrl_op     (ex_ctrl_op),
        .ex_dst_addr    (ex_dst_addr),
        .ex_gpr_we_     (ex_gpr_we_),
        .ex_exp_code    (ex_exp_code),
        .ex_out         (ex_out),

        .spm_rd_data    (mem_spm_rd_data),
        .spm_addr       (mem_spm_addr),
        .spm_as_        (mem_spm_as_),
        .spm_rw         (mem_spm_rw),
        .spm_wr_data    (mem_spm_wr_data),

        .mem_pc         (mem_pc),
        .mem_en         (mem_en),
        .mem_br_flag    (mem_br_flag),
        .mem_ctrl_op    (mem_ctrl_op),
        .mem_dst_addr   (mem_dst_addr),
        .mem_gpr_we_    (mem_gpr_we_),
        .mem_exp_code   (mem_exp_code),
        .mem_out        (mem_out),

        .bus_rd_data    (mem_bus_rd_data),
        .bus_rdy_       (mem_bus_rdy_),
        .bus_grnt_      (mem_bus_grnt_),
        .bus_req_       (mem_bus_req_),
        .bus_addr       (mem_bus_addr),
        .bus_as_        (mem_bus_as_),
        .bus_rw         (mem_bus_rw),
        .bus_wr_data    (mem_bus_wr_data)

    );

    ctrl ctrl0(
        .clk            (clk),
        .reset_         (reset_),

        .id_pc             (id_pc),
        .if_stall          (if_stall),
        .if_flush          (if_flush),
        .if_busy           (if_busy),
        .id_stall          (id_stall),
        .id_flush          (id_flush),
        .new_pc            (new_pc),
        .creg_rd_addr      (creg_rd_addr),
        .ld_hazard         (ld_hazard),
        .exe_mode          (exe_mode),
        .creg_rd_data      (creg_rd_data),
        .int_detect        (int_detect),
        .ex_stall          (ex_stall),
        .ex_flush          (ex_flush),
        .mem_stall         (mem_stall),
        .mem_flush         (mem_flush),
        .mem_busy          (mem_busy),

        .mem_pc         (mem_pc),
        .mem_en         (mem_en),
        .mem_br_flag    (mem_br_flag),
        .mem_ctrl_op    (mem_ctrl_op),
        .mem_dst_addr   (mem_dst_addr),
        .mem_gpr_we_    (mem_gpr_we_),
        .mem_exp_code   (mem_exp_code),
        .mem_out        (mem_out),

        .irq            (cpu_irq)
    );

    gpr gpr0(
        .clk            (clk),
        .reset_         (reset_),

        .rd_addr_0      (gpr_rd_addr_0),
        .rd_addr_1      (gpr_rd_addr_1),
        .rd_data_0      (gpr_rd_data_0),
        .rd_data_1      (gpr_rd_data_1),

        .we_            (mem_gpr_we_),
        .wr_addr        (mem_dst_addr),
        .wr_data        (mem_out)
    );

    spm spm0(
        .if_spm_rd_data (if_spm_rd_data),
        .if_spm_addr0    (if_spm_addr),
        .if_spm_as_     (if_spm_as_),
        .if_spm_rw      (if_spm_rw),
        .if_spm_wr_data (if_spm_wr_data),

        .mem_spm_rd_data (mem_spm_rd_data),
        .mem_spm_addr0    (mem_spm_addr),
        .mem_spm_as_     (mem_spm_as_),
        .mem_spm_rw      (mem_spm_rw),
        .mem_spm_wr_data (mem_spm_wr_data)
    );

endmodule
