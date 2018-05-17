`include "chip.v"
`include "clk_gen.v"

module chip_top(
    input wire      clk_ref,
    input wire      reset_sw,

    output wire     uart_rx,
    input  wire     uart_tx,

    input  wire [3:0]     gpio_in,
    output wire [17:0]    gpio_out,
    inout  wire [15:0]     gpio_io
);

    wire    clk;
    wire    clk_;
    wire    chip_reset_;

    clk_gen clk_gen(
        .clk_ref    (clk_ref),
        .reset_sw  (reset_sw),

        .clk        (clk),
        .clk_       (clk_),
        .chip_reset_ (chip_reset_)
    );

    chip chip(
        .clk        (clk),
        .clk_       (clk_),
        .reset_     (chip_reset_),

        .uart_tx    (uart_tx),
        .uart_rx    (uart_rx),

        .gpio_in    (gpio_in),
        .gpio_out   (gpio_out),
        .gpio_io    (gpio_io)
    );

endmodule
