`timescale 1ns / 1ps
`include "define.vh"

module mem_wb(
    input   wire        clk,
    input   wire        rst,
    
    // 来自控制模块的信息
    input   wire[5:0]   stall,
    
    // 访存阶段的结果
    input   wire[`RegAddrBus]   mem_wd,
    input   wire        mem_wreg,
    input   wire[`RegBus]       mem_wdata,
    input   wire[`RegBus]       mem_hi,
    input   wire[`RegBus]       mem_lo,
    input   wire        mem_whilo,
    
    // 送到写回阶段的信息
    output reg[`RegAddrBus]     wb_wd,
    output  reg         wb_wreg,
    output  reg[`RegBus]        wb_wdata,
    output  reg[`RegBus]        wb_hi,
    output  reg[`RegBus]        wb_lo,
    output  reg         wb_whilo
    );
    
    /*  (1)当stall[4]为Stop，stall[5]为NoStop时，表示访存阶段暂停，
        而回写阶段继续，所以使用空指令作为下一周期计入回写阶段的指令
        (2)当stall[4]为NoStop时，访存阶段继续，访存后的指令进入回写阶段
        (3)其余情况下，保持回写阶段的寄存器wb_wd、wb_wreg等不变
    */
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <= `ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;
        end else if (stall[4] == `Stop && stall[5] == `NoStop) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <= `ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;
        end else if (stall[4] == `NoStop) begin
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_whilo <= mem_whilo;
        end
    end
    
endmodule
