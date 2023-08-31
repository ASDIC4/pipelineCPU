`timescale 1ns / 1ps
`include "define.vh"

module mem(
    input   wire        rst,
    
    // 来自执行阶段的信息
    input   wire[`RegAddrBus]   wd_i,
    input   wire        wreg_i,
    input   wire[`RegBus]       wdata_i,
    input   wire[`RegBus]       hi_i,
    input   wire[`RegBus]       lo_i,
    input   wire        whilo_i,
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`RegBus]       mem_addr_i,
    input   wire[`RegBus]       reg2_i,
    
    // 来自外部数据存储器RAM的信息
    input   wire[`RegBus]       mem_data_i,
    
    // 访存阶段的结果
    output  reg[`RegAddrBus]    wd_o,
    output  reg         wreg_o,
    output  reg[`RegBus]        wdata_o,
    output  reg[`RegBus]        hi_o,
    output  reg[`RegBus]        lo_o,
    output  reg         whilo_o,
    
    // 送到外部数据存储器RAM的信息
    output  reg[`RegBus]        mem_addr_o,
    output  wire        mem_we_o,           // 是否是写操作，为1表示是写操作
    output  reg[3:0]            mem_sel_o,  // 字节选择信号
    output  reg[`RegBus]        mem_data_o,
    output  reg         mem_ce_o            // 数据存储器使能信号
    );
    
    wire[`RegBus] zero32;               // 与lwl、lwr、swl、swr指令有关
    reg mem_we;
    
    assign mem_we_o = mem_we;           // 外部数据存储器RAM的读、写信号
    assign zero32 = `ZeroWord;
    
    always @ (*) begin
        if (rst == `RstEnable) begin
            wd_o <= `NOPRegAddr;
            wreg_o <= `WriteDisable;
            wdata_o <= `ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;
            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b0000;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipDisable;
        end else begin
            wd_o <= wd_i;
            wreg_o <= wreg_i;
            wdata_o <= wdata_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            whilo_o <= whilo_i;
            mem_we <= `WriteDisable;
            mem_addr_o <= `ZeroWord;
            mem_sel_o <= 4'b1111;
            mem_ce_o <= `ChipDisable;
            case (aluop_i)
//                `EXE_LB_OP: begin           // lb指令
//                end
//                `EXE_LBU_OP: begin          // lbu指令
//                end
//                `EXE_LH_OP: begin           // lh指令
//                end
//                `EXE_LHU_OP: begin          // lhu指令
//                end
                `EXE_LW_OP: begin           // lw指令
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    wdata_o <= mem_data_i;
                    mem_sel_o <= 4'b1111;
                    mem_ce_o <= `ChipEnable;
                end
//                `EXE_LWL_OP: begin          // lwl指令
//                end
//                `EXE_LWR_OP: begin          // lwr指令
//                end
//                `EXE_SB_OP: begin           // sb指令
//                end
//                `EXE_SH_OP: begin           // sh指令
//                end
                `EXE_SW_OP: begin           // sw指令
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_data_o <= reg2_i;
                    mem_sel_o <= 4'b1111;
                    mem_ce_o <= `ChipEnable;
                end
//                `EXE_SWL_OP: begin          // swl指令
//                end
//                `EXE_SWR_OP: begin          // swr指令
//                end
                default: begin
                    mem_sel_o <= 4'b0000;
                end
            endcase
        end
    end
    
endmodule
