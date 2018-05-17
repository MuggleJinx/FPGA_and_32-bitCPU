`include "uart.h"
`include "stddef.h"
`include "uart_rx.v"
`include "uart_tx.v"
`include "uart_ctrl.v"


module uart(
    input wire                  clk,
    input wire                  reset_,

    input  wire                 cs_,
    input  wire                 as_,
    input  wire                 rw,
    input  wire [`WordAddrBus]  addr,
    input  wire [`WordDataBus]  wr_data,
    output wire [`WordDataBus]  rd_data,
    output wire                 rdy_,

    output wire                 irq_rx,
    output wire                 irq_tx,

    output wire                 u_tx,
    input  wire                 u_rx
);

    wire                 rx_busy;
    wire                 rx_end;
    wire [`ByteDataBus]  rx_data;

    wire                 tx_start;
    wire                 tx_busy;
    wire [`ByteDataBus]  tx_data;

    uart_ctrl uart_ctrl0(
        .clk        (clk),
        .reset_     (reset_),

        .cs_        (cs_),
        .as_        (as_),
        .rw         (rw),
        .addr       (addr),
        .wr_data    (wr_data),
        .rd_data    (rd_data),
        .rdy_       (rdy_),

        .irq_rx     (irq_rx),
        .irq_tx     (irq_tx)
    );

    uart_tx uart_tx(
        .clk        (clk),
        .reset_     (reset_),

        .tx_start   (tx_start),
        .tx_data    (tx_data),
        .tx_busy    (tx_busy),
        .tx_end     (tx_end),

        // uart发送信号
        .tx         (u_tx)
    );

    uart_rx uart_rx(
        .clk        (clk),
        .reset_     (reset_),

        .rx_busy    (rx_busy),
        .rx_end     (rx_end),
        .rx_data    (rx_data),

        .rx         (u_rx)
    );

endmodule
