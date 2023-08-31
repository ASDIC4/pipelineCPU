`timescale 1ns / 1ps
`include "define.vh"

module ex(
    input   wire        rst,
    
    // ����׶��͵�ִ�н׶ε���Ϣ
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegBus]       reg1_i,
    input   wire[`RegBus]       reg2_i,
    input   wire[`RegAddrBus]   wd_i,
    input   wire        wreg_i,
    input   wire[`RegBus]       inst_i,
    
    // ����ִ�н׶ε�ת��ָ��Ҫ����ķ��ص�ַ
    input   wire[`RegBus]       link_address_i,
    
    // ��ǰִ�н׶ε�ָ���Ƿ����ӳٲ�
    input   wire        is_in_delayslot_i,
    
    // HILOģ�������HI��LO�Ĵ���
    input   wire        hi_i,
    input   wire        lo_i,
    
    // ��д�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO�Ĵ��������������������
    input   wire[`RegBus]       wb_hi_i,
    input   wire[`RegBus]       wb_lo_i,
    input   wire        wb_whilo_i,
    
    // �ô�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO�Ĵ��������������������
    input   wire[`RegBus]       mem_hi_i,
    input   wire[`RegBus]       mem_lo_i,
    input   wire        mem_whilo_i,   
    
    // ִ�еĽ��
    output  reg[`RegAddrBus]    wd_o,
    output  reg         wreg_o,
    output  reg[`RegBus]        wdata_o,
    
    // ����ִ�н׶ε�ָ���HI��LO�Ĵ�����д��������
    output  reg[`RegBus]        hi_o,
    output  reg[`RegBus]        lo_o,
    output  reg         whilo_o,
    
    // �����CTRLģ��
    output  reg         stallreq,
    
    // Ϊ���ء��洢ָ��׼��
    output  wire[`AluOpBus]     aluop_o,
    output  wire[`RegBus]       mem_addr_o,
    output  wire[`RegBus]       reg2_o
    );
    
    reg[`RegBus]    logicout;   // �����߼�������
    reg[`RegBus]    shiftres;   // ������λ������
    reg[`RegBus]    moveres;    // �����ƶ������Ľ��
    reg[`RegBus]    arithmeticres;  // ������������Ľ��
    reg[`DoubleRegBus]    mulres;   // ����˷����������Ϊ64λ
    reg[`RegBus]    HI;         // ����HI�Ĵ���������ֵ
    reg[`RegBus]    LO;         // ����LO�Ĵ���������ֵ
    wire        reg1_eq_reg2;   // ��һ���������Ƿ���ڵڶ���������
    wire        reg1_lt_reg2;   // ��һ���������Ƿ�С�ڵڶ���������
    wire[`RegBus]   result_sum; // ����ӷ����
    wire        ov_sum;         // ����������
    wire[`RegBus]   reg2_i_mux; // ��������ĵڶ���������reg2_i�Ĳ���
    wire[`RegBus]   reg1_i_not; // ��������ĵ�һ��������reg1_iȡ�����ֵ
    wire[`RegBus]   opdata1_mult;   // �˷��������еı�����
    wire[`RegBus]   opdata2_mult;   // �˷������еĳ���
    wire[`DoubleRegBus]     hilo_temp;  // ��ʱ����˷����������Ϊ64λ
    
    always @ (*) begin
        stallreq <= 1'b1;
    end
    // aluop_o�ᴫ���ô�׶Σ���ʱ��������ȷ�����ء��洢����
    assign aluop_o = aluop_i;
    
    // mem_addr_o���ݵ��ô�׶Σ��Ǽ��ء��洢ָ���Ӧ�Ĵ洢����ַ
    // �˴���reg1_i��ʱ���ء��洢ָ���е�ַΪbase��ͨ�üĴ�����ֵ��
    // inst_i[15:0]����ָ���е�offset.
    assign mem_addr_o = reg1_i + {{16{inst_i[15]}}, inst_i[15:0]};
    
    // reg2_i�Ǵ洢ָ��Ҫ�洢�����ݣ�����lwl��lwrָ��Ҫ���ص�Ŀ�ļĴ�����ԭʼֵ��
    // ����ֵͨ��reg2_o�ӿڴ��ݵ��ô�׶�
    assign reg2_o = reg2_i;
    
    /*  (1)����Ǽӷ������з������Ƚ����㣬��ôreg2_i_mux���ڵڶ���������reg2_i�Ĳ��룬
        ����reg2_i_mux�͵��ڵڶ���������reg2_i
    */
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) ||
                         (aluop_i == `EXE_SUBU_OP) ||
                         (aluop_i == `EXE_SLT_OP)) ?
                         (~reg2_i)+1 : reg2_i;
    /*  (2)A.����Ǽӷ����㣬reg2_i_mux���ǵڶ��������� reg2_i,result_sum���Ǽӷ�����Ľ��
        B.����Ǽ������㣬reg2_i_mux�ǵڶ���������reg2_i�Ĳ��룬result_sum���Ǽ�������Ľ��
        C.������з��űȽ����㣬reg2_i_mux�ǵڶ���������reg2_i�Ĳ��룬result_sumҲ�Ǽ�������Ľ����
        ����ͨ���жϼ����Ľ���Ƿ�С���㣬�����ж�reg1_i�Ƿ�С��reg2_i
    */
    assign result_sum = reg1_i + reg2_i_mux;
    /*  (3)�����Ƿ�������ӷ�ָ��(add��addi)������ָ��(sub)ִ��ʱ��
        ��Ҫ�ж��Ƿ���������������������֮һʱ���������
        A.reg1_iΪ������reg2_i_muxΪ������������֮��Ϊ����
        B.reg1_iΪ������reg2_i_muxΪ������������֮��Ϊ����
    */
    assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
                    ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
    /*  (4)���������1�Ƿ�С�ڲ�����2�����������:
        A.aluop_iΪEXE_SLT_OP��ʾ�з��űȽ����㣬��ʱ�ַ�3�����
            A1.reg1_iΪ������reg2_iΪ��������Ȼreg1_iС��reg2_i
            A2.reg1_iΪ������reg2_iΪ����������reg1_i��ȥreg2_i��ֵС��0(��result_sumΪ��)����ʱreg1_iС��reg2_i
            A3.reg1_iΪ������reg2_iΪ����������reg1_i��ȥreg2_i��ֵС��0(��result_sumΪ��)����ʱreg1_iС��reg2_i
        B.�޷������Ƚ�ʱ��ֱ��ʹ�ñȽ�������Ƚ�reg1_i��reg2_i
    */
    assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP))?
                          ((reg1_i[31] && !reg2_i[31]) ||
                          (!reg1_i[31] && !reg2_i[31] && result_sum[31]) ||
                          (reg1_i[31] && reg2_i[31] && result_sum[31]))
                          : (reg1_i < reg2_i);       
    /*  (5)�Բ�����1��λȡ��������reg1_i_not
    */
    assign reg1_i_not = ~reg1_i;
    
    /***����aluop_iָʾ�����������ͽ�������***/
    //���ݲ�ͬ�������������ͣ���arithmeticres������ֵ
    always @ (*) begin
        if (rst == `RstEnable) begin
            arithmeticres <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP: begin     // �Ƚ�����
                    arithmeticres <= reg1_lt_reg2;
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin   //  �ӷ�����
                    arithmeticres <= result_sum;
                end  
                `EXE_SUB_OP, `EXE_SUBU_OP: begin    // ��������
                    arithmeticres <= result_sum;
                end
//                `EXE_CLZ_OP: begin                  // ��������clz
//                end
//                `EXE_CLO_OP: begin                  // ��������clo
//                end
                default: begin
                    arithmeticres <= `ZeroWord;
                end
            endcase
        end
    end
    
    // ���г˷�����
    /*  (1)ȡ�ó˷�����ı�������������з������ұ������Ǹ�������ôȡ����
    */
    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || 
                          (aluop_i == `EXE_MULT_OP)) &&
                          (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
    /*  (2)ȡ�ó˷�����ĳ�����������з��ų˷��ҳ����Ǹ�������ôȡ����
    */
    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || 
                          (aluop_i == `EXE_MULT_OP)) &&
                          (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;
    /*  (3)�õ���ʱ�˷�����������ڱ���hilo_temp��
    */
    assign hilo_temp = opdata1_mult * opdata2_mult;
    /*  (4)����ʱ�˷�����������������ն��˷���������ڱ���mulres�У���Ҫ�����㣺
        A.������з��ų˷�ָ��mult��mul����ô��Ҫ������ʱ�˷���������£�
            A1.������������������һ��һ������ô��Ҫ����ʱ�˷����hilo_temp���룬
                ��Ϊ���յĳ˷��������ֵ������mulres.
            A2.��������������ͬ�ţ���ôhilo_temp��ֵ����Ϊ���յĳ˷��������ֵ������mulres.
        B.������޷��ų˷�ָ��multu����ôhilo_temp��ֵ����Ϊ���յĳ˷��������ֵ������mulres.
    */
    always @ (*) begin
        if (rst == `RstEnable) begin
            mulres <= {`ZeroWord, `ZeroWord};
        end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP)) begin
            if (reg1_i[31] ^ reg2_i[31] == 1'b1) begin
                mulres <= ~hilo_temp + 1;
            end else begin
                mulres <= hilo_temp;
            end
        end else begin
            mulres <= hilo_temp;
        end
    end
    
    //�����߼�����
    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP: begin               // �߼�������
                    logicout <= reg1_i | reg2_i;
                end
                `EXE_AND_OP: begin              // �߼�������
                    logicout <= reg1_i & reg2_i;
                end
                `EXE_NOR_OP: begin              // �߼��������
                    logicout <= ~(reg1_i | reg2_i);
                end
                `EXE_XOR_OP: begin              // �߼��������
                    logicout <= reg1_i ^ reg2_i;
                end
                default: begin
                    logicout <= `ZeroWord;
                end
            endcase
        end
    end
    
    // ������λ����
    always @ (*) begin
        if (rst == `RstEnable) begin
            shiftres <=  `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP: begin              // �߼�����
                    shiftres <= reg2_i << reg1_i[4:0];
                end
                `EXE_SRL_OP: begin              // �߼�����
                    shiftres <= reg2_i >> reg1_i[4:0];
                end
                `EXE_SRA_OP: begin              // ��������
                    shiftres <= ({32{reg2_i[31]}}<<(6'd32-{1'b0,reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
                end
                default: begin
                    shiftres <= `ZeroWord;
                end
            endcase
        end
    end
    
    // �õ����µ�HI��LO�Ĵ�����ֵ���˴���������������
    always @ (*) begin
        if (rst == `RstEnable) begin
            {HI, LO} <= {`ZeroWord, `ZeroWord};
        end else if (mem_whilo_i == `WriteEnable) begin
            {HI, LO} <= {mem_hi_i, mem_lo_i};   // �ô�׶ε�ָ��ҪдHI��LO�Ĵ���
        end else if (wb_whilo_i == `WriteEnable) begin
            {HI, LO} <= {wb_hi_i, wb_lo_i};     // ��д�׶ε�ָ��ҪдHI��LO�Ĵ���
        end else begin
            {HI, LO} <= {hi_i, lo_i};
        end
    end
    
    // MFHI��MFLO��MOVN��MOVZָ��
    always @ (*) begin
        if (rst == `RstEnable) begin
            moveres <= `ZeroWord;
        end else begin
            moveres <= `ZeroWord;
            case (aluop_i)
                `EXE_MFHI_OP: begin
                    moveres <= HI;          // mfhiָ���HI��ֵ��Ϊ�ƶ������Ľ��
                end
                `EXE_MFLO_OP: begin
                    moveres <= LO;          // mfloָ���LO��ֵ��Ϊ�ƶ������Ľ��
                end
                `EXE_MOVZ_OP: begin
                    moveres <= reg1_i;      // movzָ���reg1_i��ֵ��Ϊ�ƶ������Ľ��
                end
                `EXE_MOVN_OP: begin
                    moveres <= reg1_i;      // movnָ���reg1_i��ֵ��Ϊ�ƶ������Ľ��
                end
                default: begin
                end
            endcase
        end
    end
    
    /***����alusel_iָʾ���������ͣ�ѡ��һ����������Ϊ���ս��***/
    always @ (*) begin
        wd_o <= wd_i;       // wd_o����wd_i��Ҫд��Ŀ�ļĴ�����ַ
        // �����add��addi��sub��subiָ��ҷ����������ô����wreg_oΪWriteDisable����ʾ��дĿ�ļĴ���
        if (((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) ||
            (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
            wreg_o <= `WriteDisable;
        end else begin
            wreg_o <= wreg_i;   // wreg_o����wreg_i����ʾ�Ƿ�ҪдĿ�ļĴ���
        end
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout;    // ѡ���߼���������Ϊ����������
            end
            `EXE_RES_SHIFT: begin       // ѡ����λ��������Ϊ����������
                wdata_o <= shiftres;
            end
            `EXE_RES_MOVE: begin        // ѡ���ƶ��������Ϊ����������
                wdata_o <= moveres;
            end
            `EXE_RES_ARITHMETIC: begin  // ���˷���ļ���������ָ��Ľ��
                wdata_o <= arithmeticres;
            end
            `EXE_RES_MUL: begin         // �˷�ָ��mul��������
                wdata_o <= mulres[31:0];
            end
            `EXE_RES_JUMP_BRANCH: begin
                wdata_o <= link_address_i;  //  ��תָ����淵�ص�ַ
            end
            default: begin
                wdata_o <= `ZeroWord;
            end
        endcase
    end
    
    // �����MTHI��MTLOָ���Ҫ����whilo_o��hi_o��lo_o��ֵ
    always @ (*) begin
        if (rst == `RstEnable) begin
            whilo_o <= `WriteDisable;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin //mult��multuָ��
            whilo_o <= `WriteEnable;
            hi_o <= mulres[63:32];
            lo_o <= mulres[31:0];
        end else if (aluop_i == `EXE_MTHI_OP) begin
            whilo_o <= `WriteEnable;
            hi_o <= reg1_i;
            lo_o <= LO;         // дHI�Ĵ���������LO���ֲ���
        end else if (aluop_i == `EXE_MTLO_OP) begin
            whilo_o <= `WriteEnable;
            hi_o <= HI;
            lo_o <= reg1_i;     // дLO�Ĵ���������HI���ֲ���
        end else begin
            whilo_o <= `WriteDisable;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end
    end
    
endmodule