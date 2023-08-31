`timescale 1ns / 1ps
`include "define.vh"

module pc_reg(
    input   wire        clk,
    input   wire        rst,
    
    // ���Կ���ģ��CTRL
    input   wire[5:0]   stall,
    
    // ��������׶�IDģ�����Ϣ
    input   wire        branch_flag_i,
    input   wire[`RegBus]       branch_target_address_i,
    
    output  reg[`InstAddrBus]   pc,
    output  reg         ce
    );

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable;             // ��λʱָ��洢������
        end else begin
            ce <= `ChipEnable;              // ��λ������ָ��洢��ʹ��
        end
    end

    always @ (posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= 32'h00000000;             // ָ��Ĵ�������ʱ��PCΪ0
        end else if (stall[0] == `NoStop) begin // ��stall[0]ΪNoStopʱ��pc��4�����򣬱���pc����
            if (branch_flag_i == `Branch) begin
                pc <= branch_target_address_i;
            end else begin
                pc <= pc + 4'h4;                // ָ��Ĵ���ʹ�ܵ�ʱ��PC��ֵÿʱ�����ڼ�4
            end
        end
    end

endmodule