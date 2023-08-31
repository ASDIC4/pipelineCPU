`timescale 1ns / 1ps
`include "define.vh"

module ctrl(
    input   wire        rst,
    input   wire        stallreq_from_id,   // ��������׶ε���ͣ����
    input   wire        stallreq_from_ex,   // ����ִ�н׶ε���ͣ����
    output  reg[5:0]    stall
    );
    
    /*  stall[0]��ʾȡָ��ַPC�Ƿ񱣳ֲ��䣬Ϊ1��ʾ���ֲ���
        stall[1]��ʾ��ˮ��ȡָ�׶��Ƿ���ͣ��Ϊ1�������ͣ
        stall[2]��ʾ��ˮ������׶��Ƿ���ͣ��Ϊ1�������ͣ
        stall[3]��ʾ��ˮ��ִ�н׶��Ƿ���ͣ��Ϊ1�������ͣ
        stall[4]��ʾ��ˮ�߷ô�׶��Ƿ���ͣ��Ϊ1�������ͣ
        stall[5]��ʾ��ˮ�߻�д�׶��Ƿ���ͣ��Ϊ1�������ͣ
    */
    always @ (*) begin
        if (rst == `RstEnable) begin
            stall <= 6'b000000;
        end else if (stallreq_from_ex == `Stop) begin
            stall <= 6'b001111;
        end else if (stallreq_from_id == `Stop) begin
            stall <= 6'b000111;
        end else begin
            stall <= 6'b000000;
        end
    end
    
endmodule