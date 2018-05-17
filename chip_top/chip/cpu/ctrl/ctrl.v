//`include "..\..\..\stddef.h"
//`include "..\cpu.h"
//`include "..\isa.h"
//`include "..\spm\spm.h"
//`include "..\..\rom\rom.h"

module ctrl(
    input wire                  clk,
    input wire                  reset_,

    // 控制寄存器接口
    input wire  [`RegAddrBus]   creg_rd_addr,
    output reg  [`WordDataBus]  creg_rd_data,
    output reg                  exe_mode,

    // 中断
    input wire  [`ByteDataBus]  irq,
    output reg                  int_detect,

    // ID/EX 流水线寄存器
    input wire  [`WordAddrBus]  id_pc,

    // MEM/WB 流水线寄存器
    input wire  [`WordAddrBus]  mem_pc,
    input wire                  mem_en,
    input wire                  mem_br_flag,
    input wire  [`CtrlOpBus]    mem_ctrl_op,
    input wire  [`RegAddrBus]   mem_dst_addr,
    input wire                  mem_gpr_we_,
    input wire  [`IsaExpBus]    mem_exp_code,
    input wire  [`WordDataBus]  mem_out,  //input or output???

    // 流水线的状态
    input wire    if_busy, //[`WordDataBus]
    input wire                  ld_hazard,
    input wire                  mem_busy,

    // 延迟信号
    output wire                 if_stall,
    output wire                 id_stall,
    output wire                 ex_stall,
    output wire                 mem_stall,

    // 刷新信号
    output wire                 if_flush,
    output wire                 id_flush,
    output wire                 ex_flush,
    output wire                 mem_flush,
    output reg  [`WordAddrBus]  new_pc
);
    // 控制寄存器
    reg                         int_en;
    reg                         pre_exe_mode;
    reg                         pre_int_en;
    reg     [`WordAddrBus]      epc;
    reg     [`WordAddrBus]      exp_vector;
    reg     [`IsaExpBus]        exp_code;
    reg                         dly_flag;
    reg     [`ByteDataBus]      mask;
    reg     [`WordAddrBus]      pre_pc;
    reg                         br_flag;

    /************* 流水线控制信号 *********************/
    wire    stall       = if_busy | mem_busy;
    assign  if_stall    = stall | ld_hazard;
    assign  id_stall    = stall;
    assign  ex_stall    = stall;
    assign  mem_stall   = stall;

    reg     flush;
    assign  ex_flush    = flush;
    assign  id_flush    = flush | ld_hazard;
    assign  ex_flush    = flush;
    assign  mem_flush   = flush;

    always  @(*)    begin
        new_pc  = `WORD_ADDR_W'h0;
        flush   = `DISABLE;
        // 流水线刷新
        if (mem_en == `ENABLE) begin
            if (mem_exp_code != `ISA_EXP_NO_EXP) begin
                new_pc  = exp_vector;
                flush   = `ENABLE;
            end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin
                new_pc  = epc;
                flush   = `ENABLE;
            end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin
                new_pc  = mem_pc;
                flush   = `ENABLE;
            end
        end
    end

    /************* 中断检测 ************/
    always @(*) begin
        if ((int_en == `ENABLE) && ((|((~mask) & irq)) == `ENABLE)) begin
            int_detect  = `ENABLE;
        end else begin
            int_detect  = `DISABLE;
        end
    end

    /************* 读取访问 *************/
    always  @(*) begin
        case (creg_rd_addr)
            `CREG_ADDR_STATUS       : begin     //0
                creg_rd_data    = {{`WORD_DATA_W-2{1'b0}}, int_en, exe_mode};
            end
            `CREG_ADDR_PRE_STATUS   : begin     //1
                creg_rd_data    = {{`WORD_DATA_W-2{1'b0}}, pre_int_en, pre_exe_mode};
            end
            `CREG_ADDR_PC           : begin     //2
                creg_rd_data    = {id_pc, `BYTE_OFFSET_W'h0};
            end
            `CREG_ADDR_EPC          : begin     //3
                creg_rd_data    = {epc, `BYTE_OFFSET_W'h0};
            end
            `CREG_ADDR_EXP_VECTOR   : begin     //4
                creg_rd_data    = {exp_vector, `BYTE_OFFSET_W'h0};
            end
            `CREG_ADDR_CAUSE        : begin     //5
                creg_rd_data    = {{`WORD_DATA_W-1-`ISA_EXP_W{1'b0}}, dly_flag, exp_code};
            end
            `CREG_ADDR_INT_MASK     : begin     //6
                creg_rd_data    = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, mask};
            end
            `CREG_ADDR_IRQ          : begin     //7
                creg_rd_data    = {{`WORD_DATA_W-`CPU_IRQ_CH{1'b0}}, irq};
            end
            `CREG_ADDR_ROM_SIZE     : begin     //29
                creg_rd_data    = $unsigned(`ROM_SIZE);
            end
            `CREG_ADDR_SPM_SIZE     : begin
                creg_rd_data    = $unsigned(`SPM_SIZE);
            end
            default                 : begin
                creg_rd_data    = `WORD_DATA_W'h0;
            end
        endcase
    end

    /************* CPU的控制 *********/
    always @ (posedge clk or negedge reset_) begin
        if (reset_ == `ENABLE_) begin
            exe_mode            <= #1 `CPU_KERNEL_MODE;
            int_en              <= #1 `DISABLE;
            pre_exe_mode        <= #1 `CPU_KERNEL_MODE;
            pre_int_en          <= #1 `DISABLE;
            exp_code            <= #1 `ISA_EXP_NO_EXP;
            mask                <= #1 {`CPU_IRQ_CH{`ENABLE}};
            dly_flag            <= #1 `DISABLE;
            epc                 <= #1 `WORD_ADDR_W'h0;
            exp_vector          <= #1 `WORD_ADDR_W'h0;
            pre_pc              <= #1 `WORD_ADDR_W'h0;
            br_flag             <= #1 `DISABLE;
        end else begin
            // 更新cpu状态
            if ((mem_en == `ENABLE) && (stall == `DISABLE)) begin
                // pc和分支标志
                pre_pc      <= #1 mem_pc;
                br_flag     <= #1 mem_br_flag;
                //cpu状态控制
                if (mem_exp_code != `ISA_EXP_NO_EXP) begin
                    exe_mode            <= #1 `CPU_KERNEL_MODE;
                    int_en              <= #1 `DISABLE;
                    pre_exe_mode        <= #1 exe_mode;
                    pre_int_en          <= #1 int_en;
                    exp_code            <= #1 mem_exp_code;
                    dly_flag            <= #1 br_flag;
                    epc                 <= #1 pre_pc;
                end else if (mem_ctrl_op == `CTRL_OP_EXRT) begin
                    exe_mode             <= #1 pre_exe_mode;
                    int_en              <= #1 pre_int_en;
                end else if (mem_ctrl_op == `CTRL_OP_WRCR) begin
                    // 写入控制寄存器
                    case (mem_dst_addr)
                        `CREG_ADDR_STATUS       : begin
                            exe_mode        <= #1 mem_out[`CregExeModeLoc];
                            int_en          <= #1 mem_out[`CregIntEnableLoc];
                        end
                        `CREG_ADDR_PRE_STATUS   : begin
                            pre_exe_mode    <= #1 mem_out[`CregExeModeLoc];
                            pre_int_en      <= #1 mem_out[`CregIntEnableLoc];
                        end
                        `CREG_ADDR_EXP_VECTOR   : begin
                            exp_vector      <= #1 mem_out[`WordAddrLoc];
                        end
                        `CREG_ADDR_CAUSE        : begin
                            dly_flag        <= #1 mem_out[`CregDlyFlagLoc];
                            exp_code        <= #1 mem_out[`CregExpCodeLoc];
                        end
                        `CREG_ADDR_INT_MASK     : begin
                            mask            <= #1 mem_out[`CPU_IRQ_CH-1:0];
                        end
                    endcase
                end
            end
        end
    end

endmodule
