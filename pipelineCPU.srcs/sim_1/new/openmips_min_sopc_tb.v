`timescale 1ns / 1ps
`include "define.vh"

module openmips_min_sopc_tb();
    
    reg     CLOCK_50;
    reg     rst;
    
    // ÿ��10ns��CLOCK_50�źŷ�תһ�Σ�����һ��������20ns����Ӧ50Hz
    initial begin
        CLOCK_50 = 1'b0;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end
    
    // ���ʱ�̣���λ�ź���Ч���ڵ�195ns����λ�ź���Ч����СSOPC��ʼ����
    // ����1000ns����ͣ����
    initial begin
        rst = `RstEnable;
        #195 rst = `RstDisable;
        #2000 $stop;
    end
    
    // ������СSOPC
    openmips_min_sopc openmips_min_sopc0 (
        .clk(CLOCK_50),
        .rst(rst)
    );
        
endmodule