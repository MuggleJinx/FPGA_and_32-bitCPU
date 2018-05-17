//`include "uart.h"
//`include "..\stddef.h"

module uart_tx(
    input wire                  clk,
    input wire                  reset_,

    // 控制信号
    input  wire                 tx_start,
    input  wire  [`ByteDataBus] tx_data,
    output wire                 tx_busy,
    output reg                  tx_end,

    // uart发送信号
    output reg                  tx
);

    reg                         state;
    reg     [`UartDivCntBus]    div_cnt;
    reg     [`UartBitCntBus]    bit_cnt;
    reg     [`ByteDataBus]      sh_reg;

    assign tx_busy = (state == `UART_STATE_TX) ?
                     `ENABLE : `DISABLE;

    /**** 发送逻辑电路 *****/
    always @(posedge clk or negedge reset_) begin
        if (reset_ == `ENABLE_) begin
            state   <= #1 `UART_STATE_IDLE;
            div_cnt <= #1 `UART_DIV_RATE;
            bit_cnt <= #1 `UART_BIT_CNT_START;
            sh_reg  <= #1 `BYTE_DATA_W'h0;
            tx_end  <= #1 `DISABLE;
            tx      <= #1 `UART_STOP_BIT;
        end else begin
            // 发送状态
            case (state)
                `UART_STATE_IDLE    : begin
                    if (tx_start == `ENABLE) begin
                        state   <= #1 `UART_STATE_TX;
                        sh_reg  <= #1 tx_data;
                        tx      <= #1 `UART_START_BIT;
                    end
                    tx_end  <= #1 `DISABLE;
                end
                // 发送中
                `UART_STATE_TX      : begin
                    // 通过时钟调整波特率
                    if (div_cnt == {`UART_DIV_CNT_W{1'b0}}) begin
                        // 发送下一个数据
                        case (bit_cnt)
                            `UART_BIT_CNT_MSB   : begin
                                bit_cnt <= #1 `UART_STATE_IDLE;
                                tx_end  <= #1 `UART_STOP_BIT;
                            end
                            `UART_BIT_CNT_STOP  : begin
                                state   <= #1 `UART_STATE_IDLE;
                                bit_cnt <= #1 `UART_BIT_CNT_START;
                                tx_end  <= #1 `ENABLE;
                            end
                            default             : begin
                                bit_cnt <= #1 bit_cnt + 1'b1;
                                sh_reg  <= #1 sh_reg +1'b1;
                                tx      <= #1 sh_reg[`LSB];
                            end
                        endcase
                        div_cnt <= #1 `UART_DIV_RATE;
                    end else begin
                        div_cnt <= #1 div_cnt - 1'b1;
                    end
                end
            endcase
        end
    end

endmodule
