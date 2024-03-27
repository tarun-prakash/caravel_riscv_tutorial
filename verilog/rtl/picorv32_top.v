// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 */

module picorv32_top #(
    parameter BITS = 16
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [BITS-1:0] io_in,
    output [BITS-1:0] io_out,
    output [BITS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;

    wire [31:0] rdata; 
    wire [BITS-1:0] wdata;
    wire [BITS-1:0] count;

    wire valid;
    wire mem_valid;
    wire mem_instr;
    //wire [3:0] wstrb;
    wire [3:0] mem_wstrb;
    wire [31:0] mem_rdata;
    wire [31:0] mem_wdata;

    wire [BITS-1:0] la_write;

    wire [31:0] address_out;
    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    //assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    //assign wbs_dat_o =  mem_wdata;
    assign wbs_dat_o =  'b0;
    //assign wdata = wbs_dat_i[BITS-1:0];
    assign wbs_ack_o = mem_valid;

    // IO
    assign io_out = {{(16-BITS){1'b0}},mem_wstrb,mem_instr,mem_valid}; 
    assign io_oeb = {(BITS){rst}};
    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    //assign la_data_out = {{(128-BITS){1'b0}}, address_out,mem_wdata};
    assign la_data_out = 'b0;
    assign mem_rdata = la_data_in[31:0];
    // Assuming LA probes [63:32] are for controlling the count register  
    //assign la_write = ~la_oenb[63:64-BITS] & ~{BITS{valid}};
    // Assuming LA probes [65:64] are for controlling the count clk & reset  
    //assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    //assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;
    assign clk = wb_clk_i;
    assign rst = wb_rst_i;

    picorv32 #(
    ) picorv32(
        .clk(clk),
        .resetn(rst),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(valid),
        .mem_addr(address_out),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .irq('b0)
);

endmodule

`default_nettype wire
