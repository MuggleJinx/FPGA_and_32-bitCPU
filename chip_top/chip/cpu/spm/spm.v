//Scratch Pad Memory
//`include "spm.h"
`include "spm\x_s3e_dpram.v"

module spm(
    input  wire                 clk,

    input  wire [`WordAddrBus]   if_spm_addr0,
    input  wire                 if_spm_as_,
    input  wire                 if_spm_rw,
    input  wire [`WordDataBus]  if_spm_wr_data,
    output wire [`WordDataBus]  if_spm_rd_data,

    input  wire [`WordAddrBus]   mem_spm_addr0,
    input  wire                 mem_spm_as_,
    input  wire                 mem_spm_rw,
    input  wire [`WordDataBus]  mem_spm_wr_data,
    output wire [`WordDataBus]  mem_spm_rd_data

);
    wire [`SpmAddrBus]  if_spm_addr;
    wire [`SpmAddrBus]  mem_spm_addr;
    reg     wea;
    reg     web;

    assign if_spm_addr  = if_spm_addr0[`SpmAddrLoc];
    assign mem_spm_addr = mem_spm_addr0[`SpmAddrLoc];

    // 写入信号的生成
    always @(*) begin
        // port A
        if ((if_spm_as_ == `ENABLE_) && (if_spm_rw == `WRITE)) begin
            wea = `ENABLE; // MEM_ENABLE
        end else begin
            wea = `DISABLE;
        end
        // port B
        if ((mem_spm_as_ == `ENABLE_) && (mem_spm_rw == `WRITE)) begin
            web = `ENABLE; // MEM_ENABLE
        end else begin
            web = `DISABLE;
        end
    end

    x_s3e_dpram x_s3e_dpram(
        .clka       (clk),
        .addra      (if_spm_addr),
        .dina       (if_spm_wr_data),
        .wea        (wea),
        .douta      (if_spm_rd_data),

        .clkb       (clk),
        .addrb      (mem_spm_addr),
        .dinb       (mem_spm_wr_data),
        .web        (web),
        .doutb      (mem_spm_rd_data)
    );

endmodule
