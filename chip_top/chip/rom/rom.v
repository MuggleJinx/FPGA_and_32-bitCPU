`include "stddef.h"
`include "rom.h"
`include "x_s3e_sprom.v"

module rom(
    input  wire                 clk,
    input  wire                 reset_,

    input  wire                 cs_,
    input  wire                 as_,
    input  wire [`WordAddrBus]   addr,
    output wire [`WordDataBus]  rd_data,
    output reg                  rdy_
);

    wire [`RomAddrBus]      rom_addr;
    assign rom_addr = addr[`RomAddrLoc];

    x_s3e_sprom x_s3e_sprom (
        .clka   (clk),
        .addra  (rom_addr),
        .douta  (rd_data)
    );

    always @ (posedge clk or negedge reset_) begin
        if (reset_ == `ENABLE_) begin
            rdy_    <= #1 `DISABLE_;
        end else begin
            if ((cs_ == `ENABLE_) && (as_ == `ENABLE_)) begin
                rdy_    <= #1 `ENABLE_;
            end else begin
                rdy_    <= #1 `DISABLE_;
            end
        end
    end

endmodule
