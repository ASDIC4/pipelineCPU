`timescale 1ns / 1ps
`include "define.vh"

module if_id(
    input   wire        clk,
    input   wire        rst,
    // ���Կ���ģ����ź�
    input   wire[5:0]           stall,
    // ����ȡָ�׶ε��ź�
    input   wire[`InstAddrBus]  if_pc,
    input   wire[`InstBus]      if_inst,
    // ��Ӧ����׶ε��ź�
    output  reg[`InstAddrBus]   id_pc,
    output  reg[`InstBus]       id_inst
    );
    
    /*  (1)��stall[1]ΪStop��stall[2]ΪNoStopʱ����ʾȡָ�׶���ͣ��
        ������׶μ���������ʹ�ÿ�ָ����Ϊ��һ�����ڶ̽�������׶ε�ָ��
        (2)��stall[1]ΪNoStopʱ��ȡָ�׶μ�����ȡ�õ�ָ���������׶�
        (3)��������£���������׶εļĴ���id_pc��id_inst����
    */
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZeroWord;         // ��λʱPCΪ0
            id_inst <= `ZeroWord;       // ��λʱָ��ҲΪ0�����ǿ�ָ��
        end else if (stall[1] == `Stop && stall[2] == `NoStop) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;        
        end else if (stall[1] == `NoStop) begin
            id_pc <= if_pc;             // ����ʱ�����´���ȡָ�׶ε�ֵ
            id_inst <= if_inst;
        end
    end

endmodule