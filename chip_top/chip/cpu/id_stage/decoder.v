//`include "..\..\..\stddef.h"
//`include "..\cpu.h"
//`include "..\isa.h"

module decoder(
    // IF/ID流水线寄存器
    input wire  [`WordAddrBus]  if_pc,
    input wire  [`WordDataBus]  if_insn,
    input wire                  if_en,  //  ????

    // GPR接口
    output wire [`RegAddrBus]   gpr_rd_addr_0,
    input  wire [`WordDataBus]  gpr_rd_data_0,
    output wire [`RegAddrBus]   gpr_rd_addr_1,
    input  wire [`WordDataBus]  gpr_rd_data_1,

    // 来自ID阶段的数据直通
    input  wire                 id_en,
    input  wire [`RegAddrBus]   id_dst_addr,
    input  wire                 id_gpr_we_,
    input  wire [`MemOpBus]     id_mem_op,

    // 来自EX阶段的数据直通
    input  wire                 ex_en,
    input  wire [`RegAddrBus]   ex_dst_addr,
    input  wire                 ex_gpr_we_,
    input  wire [`WordDataBus]  ex_fwd_data,

    // 来自MEM阶段的数据直通
    input  wire [`WordDataBus]  mem_fwd_data,

    // 控制寄存器接口
    input  wire                 exe_mode,
    input  wire [`WordDataBus]  creg_rd_data,
    output wire [`RegAddrBus]   creg_rd_addr,

    // 解码结果
    output reg  [`AluOpBus]     alu_op,
    output reg  [`WordDataBus]  alu_in_0,
    output reg  [`WordDataBus]  alu_in_1,
    output reg  [`WordAddrBus]  br_addr,
    output reg                  br_taken,
    output reg                  br_flag,
    output reg  [`MemOpBus]     mem_op,
    output wire [`WordDataBus]  mem_wr_data,
    output reg  [`CtrlOpBus]    ctrl_op,
    output reg  [`RegAddrBus]   dst_addr,
    output reg                  gpr_we_,
    output reg  [`IsaExpBus]    exp_code,
    output reg                  ld_hazard
);
    // 指令字段
    wire        [`IsaOpBus]     op      = if_insn[`IsaOpLoc];
    wire        [`RegAddrBus]   ra_addr = if_insn[`IsaRaAddrLoc];
    wire        [`RegAddrBus]   rb_addr = if_insn[`IsaRbAddrLoc];
    wire        [`RegAddrBus]   rc_addr = if_insn[`IsaRcAddrLoc];
    wire        [`IsaImmBus]    imm     = if_insn[`IsaImmLoc];

    // 立即数
    wire        [`WordDataBus]  imm_s   = {{`ISA_EXT_W{imm[`ISA_IMM_MSB]}}, imm};
    wire        [`WordDataBus]  imm_u   = {{`ISA_EXT_W{1'b0}}, imm};

    // 寄存器读取地址
    assign gpr_rd_addr_0 = ra_addr;
    assign gpr_rd_addr_1 = rb_addr;
    assign creg_rd_addr  = ra_addr;

    // 从gpr读取的数据
    reg         [`WordDataBus]  ra_data;
    wire signed [`WordDataBus]  s_ra_data = $signed(ra_data);
    reg         [`WordDataBus]  rb_data;
    wire signed [`WordDataBus]  s_rb_data = $signed(rb_data);
//    assign mem_wr_data = rb_data;

    // 地址
    wire        [`WordAddrBus]  ret_addr  = if_pc + 1'b1;
    wire        [`WordAddrBus]  br_target = if_pc + imm_s[`WORD_ADDR_MSB:0];
    wire        [`WordAddrBus]  jr_target = ra_data[`WordAddrLoc];

    /**************** 数据直通 *********************/
    always @(*) begin
        //Ra 寄存器
        if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && (id_dst_addr == ra_addr)) begin
            ra_data = ex_fwd_data;
        end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && (ex_dst_addr == ra_addr)) begin
            ra_data = mem_fwd_data;
        end else begin
            ra_data = gpr_rd_data_0;
        end
        //Rb 寄存器
        if ((id_en == `ENABLE) && (id_gpr_we_ == `ENABLE_) && (id_dst_addr == rb_addr)) begin
            rb_data = ex_fwd_data;
        end else if ((ex_en == `ENABLE) && (ex_gpr_we_ == `ENABLE_) && (ex_dst_addr == rb_addr)) begin
            rb_data = mem_fwd_data;
        end else begin
            rb_data = gpr_rd_data_1;
        end
    end

    /************** load 冒险检测 *************/
    always @(*) begin
        if ((id_en == `ENABLE) && (id_mem_op == `MEM_OP_LDW) &&
            ((id_dst_addr == ra_addr) || (id_dst_addr == rb_addr))) begin
            ld_hazard = `ENABLE;
        end else begin
            ld_hazard = `DISABLE;
        end
    end

    /*************** 指令解码 ****************/
    always @(*) begin
        // 默认值
        alu_op      = `ALU_OP_NOP;
        alu_in_0    = ra_data;
        alu_in_1    = rb_data;
        br_taken    = `DISABLE;
        br_flag     = `DISABLE;
        br_addr     = {`WORD_ADDR_W{1'b0}};
        mem_op      = `MEM_OP_NOP;
        ctrl_op     = `CTRL_OP_NOP;
        dst_addr    = rb_addr;
        gpr_we_     = `DISABLE_;
        exp_code    = `ISA_EXP_NO_EXP;

        case (op)
            // 算数运算指令
            `ISA_OP_ADDSR: begin
                alu_op      = `ALU_OP_ADDS;
                dst_addr    = rc_addr;
                gpr_we_     = `ENABLE_;
            end
            `ISA_OP_ADDSI: begin
                alu_op      = `ALU_OP_ADDS;
                alu_in_1    = imm_s;
                gpr_we_     = `ENABLE_;
            end
            `ISA_OP_ADDUR: begin
                alu_op      = `ALU_OP_ADDU;
                dst_addr    = rc_addr;
                gpr_we_     = `ENABLE_;
            end
            `ISA_OP_ADDUI: begin
                alu_op      = `ALU_OP_ADDU;
                alu_in_1    = imm_s;
                gpr_we_     = `ENABLE_;
            end
            `ISA_OP_SUBSR: begin
                alu_op      = `ALU_OP_SUBS;
                dst_addr    = rc_addr;
                gpr_we_     = `ENABLE_;
            end
            `ISA_OP_SUBUR: begin
                alu_op      = `ALU_OP_SUBU;
                dst_addr    = rc_addr;
                gpr_we_     = `ENABLE_;
            end

            // 移位指令
            `ISA_OP_SHRLR: begin
                alu_op      = `ALU_OP_SHRL;
                dst_addr    = rc_addr;
                gpr_we_     = `ENABLE_;
            end
            `ISA_OP_SHRLI: begin
                alu_op      = `ALU_OP_SHRL;
                alu_in_1    = imm_u;
                gpr_we_     = `ENABLE_;
            end
            `ISA_OP_SHLLR: begin
                alu_op      = `ALU_OP_SHLL;
                dst_addr    = rc_addr;
                gpr_we_     = `ENABLE_;
            end
            `ISA_OP_SHLLI: begin
                alu_op      = `ALU_OP_SHLL;
                alu_in_1    = imm_u;
                gpr_we_     = `ENABLE_;
            end

            // 分支指令
            `ISA_OP_BE: begin
                br_addr     = br_target;
                br_taken    = (ra_data == rb_data) ? `ENABLE : `DISABLE;
                br_flag     = `ENABLE;
            end
            `ISA_OP_BNE: begin
                br_addr     = br_target;
                br_taken    = (ra_data != rb_data) ? `ENABLE : `DISABLE;
                br_flag     = `ENABLE;
            end
            `ISA_OP_BSGT: begin
                br_addr     = br_target;
                br_taken    = (s_ra_data < s_rb_data) ? `ENABLE : `DISABLE;
                br_flag     = `ENABLE;
            end
            `ISA_OP_BUGT: begin
                br_addr     = br_target;
                br_taken    = (ra_data < rb_data) ? `ENABLE : `DISABLE;
                br_flag     = `ENABLE;
            end
            `ISA_OP_JMP: begin
                br_addr     = jr_target;
                br_taken    = `ENABLE;
                br_flag     = `ENABLE;
            end
            `ISA_OP_CALL: begin
                alu_in_0    = {ret_addr, {`BYTE_OFFSET_W{1'b0}}};
                br_addr     = jr_target;
                br_taken    = `ENABLE;
                br_flag     = `ENABLE;
                dst_addr    = `REG_ADDR_W'd31;
                gpr_we_     = `ENABLE_;
            end

            // 内存访问指令
            `ISA_OP_LDW: begin //字读取
                alu_op      = `ALU_OP_ADDU;
                alu_in_1    = imm_s;
                mem_op      = `MEM_OP_LDW;
                gpr_we_     = `ENABLE_;
            end
            `ISA_OP_STW: begin // 字写入
                alu_op      = `ALU_OP_ADDU;
                alu_in_1    = imm_s;
                mem_op      = `MEM_OP_STW;
            end

            // 系统调用指令
            `ISA_OP_TRAP: begin
                exp_code    = `ISA_EXP_TRAP;
            end

            // 特权指令
            `ISA_OP_RDCR: begin // 读取控制寄存器
                if (exe_mode == `CPU_KERNEL_MODE) begin
                    alu_in_0    = creg_rd_data;
                    gpr_we_     = `ENABLE_;
                end else begin
                    exp_code    = `ISA_EXP_PRV_VIO;
                end
            end
            `ISA_OP_WRCR: begin //写入控制寄存器
                if (exe_mode == `CPU_KERNEL_MODE) begin
                    ctrl_op     = `CTRL_OP_WRCR;
                end else begin
                    exp_code    = `ISA_EXP_PRV_VIO;
                end
            end
            `ISA_OP_EXRT: begin //从异常恢复
                if (exe_mode == `CPU_KERNEL_MODE) begin
                    ctrl_op     = `CTRL_OP_EXRT;
                end else begin
                    exp_code    = `ISA_EXP_PRV_VIO;
                end
            end
            default : begin
                exp_code = `ISA_EXP_UNDEF_INSN;
            end
        endcase
    end

endmodule
