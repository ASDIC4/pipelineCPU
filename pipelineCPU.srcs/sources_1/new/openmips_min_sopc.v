`timescale 1ns / 1ps
`include "define.vh"

module openmips_min_sopc(
    input   wire        clk,
    input   wire        rst,
    
    // confreg
    output  wire[6:0]   digital_num0,
    output  wire[6:0]   digital_num1,
    output  wire[7:0]   digital_cs
    );
    
    // 连接指令存储器
    wire[`InstAddrBus]  inst_addr;
    wire[`InstBus]      inst;
    wire                rom_ce;
    
    // 连接数据存储器
    wire                mem_we_i;
    wire[`RegBus]       mem_addr_i;
    wire[`RegBus]       mem_data_i;
    wire[`RegBus]       mem_data_o;
    wire[3:0]           mem_sel_i;
    wire                mem_ce_i;
    
    // 连接confreg
    wire                confreg_wen;
//    wire[`RegBus]       data_ram_wdata; // mem_data_i
//    wire[`RegBus]       data_ram_addr;  // mem_addr_i
    wire[`RegBus]       confreg_rdata;
    wire[7:0]           counter_num;
    wire                is_confreg_addr;
    wire[`RegBus]       cpu_rdata;
    wire                ram_wen;
    
    assign is_confreg_addr = mem_addr_i[31:16] == 16'hbfaf ? 1'b1 : 1'b0;
    assign confreg_wen = mem_we_i & is_confreg_addr;
    assign ram_wen = mem_we_i & !is_confreg_addr;
    assign cpu_rdata = is_confreg_addr == 1'b1 ? confreg_rdata : mem_data_o;
    // 例化处理器OpenMIPS
    openmips openmips0 (
        .clk(clk),              .rst(rst),
        .rom_addr_o(inst_addr), .rom_data_i(inst),  .rom_ce_o(rom_ce),
        .ram_data_i(cpu_rdata),    .ram_addr_o(mem_addr_i),    .ram_data_o(mem_data_i),
        .ram_we_o(mem_we_i),        .ram_sel_o(mem_sel_i),      .ram_ce_o(mem_ce_i)
    );
    
    // 例化指令存储器ROM
    inst_rom inst_rom0 (
        .ce(rom_ce),
        .addr(inst_addr),   .inst(inst)
    );
//    ip_inst_rom ip_inst_rom0 (
//        .a(inst_addr[11:2]),
//        .spo(inst)
//    );
    
    // 例化数据存储器RAM
    data_ram data_ram0 (
        .clk(clk),
        .ce(mem_ce_i),          .we(ram_wen),
        .addr(mem_addr_i),      .sel(mem_sel_i),
        .data_i(mem_data_i),    .data_o(mem_data_o)
    );
//    ip_data_ram ip_data_ram0 (
//        .a(mem_addr_i[11:2]),
//        .d(data_i),
//        .clk(clk),
//        .we(mem_we_i),
//        .i_ce(mem_ce_i),
//        .spo(data_o)
//    );
    
    // 例化confreg
    confreg confreg0 (
        .clk(clk),
        .rst(rst),
        .confreg_wen(cofreg_wen),
        .confreg_write_data(mem_data_i),
        .confreg_addr(mem_addr_i),
        
        .confreg_read_data(confreg_rdata),
        .digital_num0(digital_num0),
        .digital_num1(digital_num1),
        .digital_cs(digital_cs),
        .counter_num(counter_num)
    );
    
endmodule
