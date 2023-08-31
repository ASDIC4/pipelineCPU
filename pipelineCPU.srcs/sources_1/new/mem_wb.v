`timescale 1ns / 1ps
`include "define.vh"

module mem_wb(
    input   wire        clk,
    input   wire        rst,
    
    // ���Կ���ģ�����Ϣ
    input   wire[5:0]   stall,
    
    // �ô�׶εĽ��
    input   wire[`RegAddrBus]   mem_wd,
    input   wire        mem_wreg,
    input   wire[`RegBus]       mem_wdata,
    input   wire[`RegBus]       mem_hi,
    input   wire[`RegBus]       mem_lo,
    input   wire        mem_whilo,
    
    // �͵�д�ؽ׶ε���Ϣ
    output reg[`RegAddrBus]     wb_wd,
    output  reg         wb_wreg,
    output  reg[`RegBus]        wb_wdata,
    output  reg[`RegBus]        wb_hi,
    output  reg[`RegBus]        wb_lo,
    output  reg         wb_whilo
    );
    
    /*  (1)��stall[4]ΪStop��stall[5]ΪNoStopʱ����ʾ�ô�׶���ͣ��
        ����д�׶μ���������ʹ�ÿ�ָ����Ϊ��һ���ڼ����д�׶ε�ָ��
        (2)��stall[4]ΪNoStopʱ���ô�׶μ������ô���ָ������д�׶�
        (3)��������£����ֻ�д�׶εļĴ���wb_wd��wb_wreg�Ȳ���
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