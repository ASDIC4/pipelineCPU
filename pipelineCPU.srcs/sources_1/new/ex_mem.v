`timescale 1ns / 1ps
`include "define.vh"

module ex_mem(
    input   wire        clk,
    input   wire        rst,
    
    // ���Կ���ģ�����Ϣ
    input   wire[5:0]   stall,
    
    // ����ִ�н׶ε���Ϣ
    input   wire[`RegAddrBus]   ex_wd,
    input   wire        ex_wreg,
    input   wire[`RegBus]       ex_wdata,
    input   wire[`RegBus]       ex_hi,
    input   wire[`RegBus]       ex_lo,
    input   wire        ex_whilo,
    
    // Ϊʵ�ּ��ء��洢ָ������ӵ�����ӿ�
    input   wire[`AluOpBus]     ex_aluop,
    input   wire[`RegBus]       ex_mem_addr,
    input   wire[`RegBus]       ex_reg2,
          
    // �͵��ô�׶ε���Ϣ
    output  reg[`RegAddrBus]    mem_wd,
    output  reg         mem_wreg,
    output  reg[`RegBus]        mem_wdata,
    output  reg[`RegBus]        mem_hi,
    output  reg[`RegBus]        mem_lo,
    output  reg         mem_whilo,
    
    // Ϊʵ�ּ��ء��洢ָ������ӵ�����ӿ�
    output  reg[`AluOpBus]      mem_aluop,
    output  reg[`RegBus]        mem_mem_addr,
    output  reg[`RegBus]        mem_reg2
    );
    
    /*  (1)��stall[3]ΪStop��stall[4]ΪNoStopʱ����ʾִ�н׶���ͣ��
        ���ô�׶μ���������ʹ�ÿ�ָ����Ϊ��һ���ڽ���ô�׶ε�ָ��
        (2)��stall[3]ΪNoStopʱ��ִ�н׶μ�����ִ�к��ָ�����ô�׶�
        (3)��������£����ַô�׶εļĴ���mem_wb��mem_wreg�Ȳ���
    */
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_hi <= `ZeroWord;
            mem_lo <= `ZeroWord;
            mem_whilo <= `WriteDisable;
            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2 <= `ZeroWord;
        end else if (stall[3] == `Stop && stall[4] == `NoStop) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_hi <= `ZeroWord;
            mem_lo <= `ZeroWord;
            mem_whilo <= `WriteDisable;
            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2 <= `ZeroWord; 
        end else if (stall[3]== `NoStop) begin
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_hi <= ex_hi;
            mem_lo <= ex_lo;
            mem_whilo <= ex_whilo;
            mem_aluop <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
            mem_reg2 <= ex_reg2;
        end
    end
    
endmodule