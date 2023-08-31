`timescale 1ns / 1ps
`include "define.vh"

module mem(
    input   wire        rst,
    
    // ����ִ�н׶ε���Ϣ
    input   wire[`RegAddrBus]   wd_i,
    input   wire        wreg_i,
    input   wire[`RegBus]       wdata_i,
    input   wire[`RegBus]       hi_i,
    input   wire[`RegBus]       lo_i,
    input   wire        whilo_i,
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`RegBus]       mem_addr_i,
    input   wire[`RegBus]       reg2_i,
    
    // �����ⲿ���ݴ洢��RAM����Ϣ
    input   wire[`RegBus]       mem_data_i,
    
    // �ô�׶εĽ��
    output  reg[`RegAddrBus]    wd_o,
    output  reg         wreg_o,
    output  reg[`RegBus]        wdata_o,
    output  reg[`RegBus]        hi_o,
    output  reg[`RegBus]        lo_o,
    output  reg         whilo_o,
    
    // �͵��ⲿ���ݴ洢��RAM����Ϣ
    output  reg[`RegBus]        mem_addr_o,
    output  wire        mem_we_o,           // �Ƿ���д������Ϊ1��ʾ��д����
    output  reg[3:0]            mem_sel_o,  // �ֽ�ѡ���ź�
    output  reg[`RegBus]        mem_data_o,
    output  reg         mem_ce_o            // ���ݴ洢��ʹ���ź�
    );
    
    wire[`RegBus] zero32;               // ��lwl��lwr��swl��swrָ���й�
    reg mem_we;
    
    assign mem_we_o = mem_we;           // �ⲿ���ݴ洢��RAM�Ķ���д�ź�
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
//                `EXE_LB_OP: begin           // lbָ��
//                end
//                `EXE_LBU_OP: begin          // lbuָ��
//                end
//                `EXE_LH_OP: begin           // lhָ��
//                end
//                `EXE_LHU_OP: begin          // lhuָ��
//                end
                `EXE_LW_OP: begin           // lwָ��
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    wdata_o <= mem_data_i;
                    mem_sel_o <= 4'b1111;
                    mem_ce_o <= `ChipEnable;
                end
//                `EXE_LWL_OP: begin          // lwlָ��
//                end
//                `EXE_LWR_OP: begin          // lwrָ��
//                end
//                `EXE_SB_OP: begin           // sbָ��
//                end
//                `EXE_SH_OP: begin           // shָ��
//                end
                `EXE_SW_OP: begin           // swָ��
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_data_o <= reg2_i;
                    mem_sel_o <= 4'b1111;
                    mem_ce_o <= `ChipEnable;
                end
//                `EXE_SWL_OP: begin          // swlָ��
//                end
//                `EXE_SWR_OP: begin          // swrָ��
//                end
                default: begin
                    mem_sel_o <= 4'b0000;
                end
            endcase
        end
    end
    
endmodule