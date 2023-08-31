`timescale 1ns / 1ps
`include "define.vh"

module inst_rom(
    input   wire        ce,
    input   wire[`InstAddrBus]  addr,
    output  reg[`InstBus]      inst
    );
    
    // ����һ�����飬��СΪInstMemNum��Ԫ�ؿ���ΪInstBus
    reg[`InstBus]   inst_mem[0:`InstMemNum-1];
    
    // ʹ���ļ�inst_rom.data��ʼ��ָ��洢��
    initial begin
    $readmemh("D:/1.txt", inst_mem);
    end
    // ����λ�ź���Чʱ����������ĵ�ַ������ָ��洢��ROM�ж�Ӧ��Ԫ��
    always @ (*) begin
        if (ce == `ChipDisable) begin
            inst <= `ZeroWord;
        end else begin
            inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end
    
endmodule