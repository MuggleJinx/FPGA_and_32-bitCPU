//`include "id_reg.v"
//`include "decoder.v"

module id_stage(
    /**** decoder ****/
    input wire                  clk,
    input wire                  reset_,

    input wire  [`WordAddrBus]  if_pc,
    input wire  [`WordDataBus]  if_insn,
    input wire                  if_en,

    output wire [`RegAddrBus]   gpr_rd_addr_0,
    input  wire [`WordDataBus]  gpr_rd_data_0,
    output wire [`RegAddrBus]   gpr_rd_addr_1,
    input  wire [`WordDataBus]  gpr_rd_data_1,

    input  wire                 exe_mode,
    input  wire [`WordDataBus]  creg_rd_data,
    output wire [`RegAddrBus]   creg_rd_addr,

    // 来自ID阶段的数据直通
//    input  wire                 id_en,
//    input  wire [`RegAddrBus]   id_dst_addr,
//    input  wire                 id_gpr_we_,
//    input  wire [`MemOpBus]     id_mem_op,

    // 来自EX阶段的数据直通
    input  wire                 ex_en,
    input  wire [`RegAddrBus]   ex_dst_addr,
    input  wire                 ex_gpr_we_,
    input  wire [`WordDataBus]  ex_fwd_data,

    // 来自MEM阶段的数据直通
    input  wire [`WordDataBus]  mem_fwd_data,

    output wire [`WordAddrBus]  br_addr,
    output wire                 br_taken,
    output wire                 ld_hazard,

    /**** id_reg ****/
    input wire                  stall,
    input wire                  flush,

    output wire  [`WordAddrBus] id_pc,
    output wire                 id_en,
    output wire [`AluOpBus]     id_alu_op,
    output wire [`WordDataBus]  id_alu_in_0,
    output wire [`WordDataBus]  id_alu_in_1,
    output wire                 id_br_flag,
    output wire [`MemOpBus]     id_mem_op,
    output wire [`WordDataBus]  id_mem_wr_data,
    output wire [`CtrlOpBus]    id_ctrl_op,
    output wire [`RegAddrBus]   id_dst_addr,
    output wire                 id_gpr_we_,
    output wire [`IsaExpBus]    id_exp_code
);

    wire [`AluOpBus]     alu_op;
    wire [`WordDataBus]  alu_in_0;
    wire [`WordDataBus]  alu_in_1;

    wire                 br_flag;
    wire [`MemOpBus]     mem_op;
    wire [`WordDataBus]  mem_wr_data;
    wire [`CtrlOpBus]    ctrl_op;
    wire [`RegAddrBus]   dst_addr;
    wire                 gpr_we_;
    wire [`IsaExpBus]    exp_code;

    decoder decoder0(
        // IF/ID流水线寄存器
        .if_pc          (if_pc),
        .if_insn        (if_insn),
        .if_en          (if_en),

        // GPR接口
        .gpr_rd_addr_0  (gpr_rd_addr_0),
        .gpr_rd_data_0  (gpr_rd_data_0),
        .gpr_rd_addr_1  (gpr_rd_addr_1),
        .gpr_rd_data_1  (gpr_rd_data_1),

        // 来自ID阶段的数据直通
        .id_en          (id_en),
        .id_dst_addr    (id_dst_addr),
        .id_gpr_we_     (id_gpr_we_),
        .id_mem_op      (id_mem_op),

        // 来自EX阶段的数据直通
        .ex_en          (ex_en),
        .ex_dst_addr    (ex_dst_addr),
        .ex_gpr_we_     (ex_gpr_we_),
        .ex_fwd_data    (ex_fwd_data),

        // 来自MEM阶段的数据直通
        .mem_fwd_data   (mem_fwd_data),

        // 控制寄存器接口
        .exe_mode       (exe_mode),
        .creg_rd_data   (creg_rd_data),
        .creg_rd_addr   (creg_rd_addr),

        // 解码结果
        .br_taken       (br_taken),
        .br_addr        (br_addr),
        .ld_hazard      (ld_hazard),

        .alu_op         (alu_op),
        .alu_in_0       (alu_in_0),
        .alu_in_1       (alu_in_1),
        .br_flag        (br_flag),

        .mem_op         (mem_op),
        .mem_wr_data    (mem_wr_data),
        .ctrl_op        (ctrl_op),
        .dst_addr       (dst_addr),
        .gpr_we_        (gpr_we_),
        .exp_code       (exp_code)
    );

    id_reg  id_reg0(
        .clk            (clk),
        .reset_         (reset_),

        .stall          (stall),
        .flush          (flush),

        // 解码结果
        .alu_op         (alu_op),
        .alu_in_0       (alu_in_0),
        .alu_in_1       (alu_in_1),
        .br_flag        (br_flag),

        .mem_op         (mem_op),
        .mem_wr_data    (mem_wr_data),
        .ctrl_op        (ctrl_op),
        .dst_addr       (dst_addr),
        .gpr_we_        (gpr_we_),
        .exp_code       (exp_code),

        .if_pc          (if_pc),
        .if_en          (if_en),

        //output
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
        .id_exp_code    (id_exp_code)
    );



endmodule
