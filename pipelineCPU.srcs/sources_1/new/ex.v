`timescale 1ns / 1ps
`include "define.vh"

module ex(
    input   wire        rst,
    
    // 译码阶段送到执行阶段的信息
    input   wire[`AluOpBus]     aluop_i,
    input   wire[`AluSelBus]    alusel_i,
    input   wire[`RegBus]       reg1_i,
    input   wire[`RegBus]       reg2_i,
    input   wire[`RegAddrBus]   wd_i,
    input   wire        wreg_i,
    input   wire[`RegBus]       inst_i,
    
    // 处于执行阶段的转移指令要保存的返回地址
    input   wire[`RegBus]       link_address_i,
    
    // 当前执行阶段的指令是否处于延迟槽
    input   wire        is_in_delayslot_i,
    
    // HILO模块给出的HI、LO寄存器
    input   wire        hi_i,
    input   wire        lo_i,
    
    // 回写阶段的指令是否要写HI、LO，用于检测HI、LO寄存器带来的数据相关问题
    input   wire[`RegBus]       wb_hi_i,
    input   wire[`RegBus]       wb_lo_i,
    input   wire        wb_whilo_i,
    
    // 访存阶段的指令是否要写HI、LO，用于检测HI、LO寄存器带来的数据相关问题
    input   wire[`RegBus]       mem_hi_i,
    input   wire[`RegBus]       mem_lo_i,
    input   wire        mem_whilo_i,   
    
    // 执行的结果
    output  reg[`RegAddrBus]    wd_o,
    output  reg         wreg_o,
    output  reg[`RegBus]        wdata_o,
    
    // 处于执行阶段的指令对HI、LO寄存器的写操作请求
    output  reg[`RegBus]        hi_o,
    output  reg[`RegBus]        lo_o,
    output  reg         whilo_o,
    
    // 输出到CTRL模块
    output  reg         stallreq,
    
    // 为加载、存储指令准备
    output  wire[`AluOpBus]     aluop_o,
    output  wire[`RegBus]       mem_addr_o,
    output  wire[`RegBus]       reg2_o
    );
    
    reg[`RegBus]    logicout;   // 保存逻辑运算结果
    reg[`RegBus]    shiftres;   // 保存移位运算结果
    reg[`RegBus]    moveres;    // 保存移动操作的结果
    reg[`RegBus]    arithmeticres;  // 保存算术运算的结果
    reg[`DoubleRegBus]    mulres;   // 保存乘法结果，宽度为64位
    reg[`RegBus]    HI;         // 保存HI寄存器的最新值
    reg[`RegBus]    LO;         // 保存LO寄存器的最新值
    wire        reg1_eq_reg2;   // 第一个操作数是否等于第二个操作数
    wire        reg1_lt_reg2;   // 第一个操作数是否小于第二个操作数
    wire[`RegBus]   result_sum; // 保存加法结果
    wire        ov_sum;         // 保存溢出情况
    wire[`RegBus]   reg2_i_mux; // 保存输入的第二个操作数reg2_i的补码
    wire[`RegBus]   reg1_i_not; // 保存输入的第一个操作数reg1_i取反后的值
    wire[`RegBus]   opdata1_mult;   // 乘法操作数中的被乘数
    wire[`RegBus]   opdata2_mult;   // 乘法操作中的乘数
    wire[`DoubleRegBus]     hilo_temp;  // 临时保存乘法结果，宽度为64位
    
    always @ (*) begin
        stallreq <= 1'b1;
    end
    // aluop_o会传到访存阶段，届时将利用其确定加载、存储类型
    assign aluop_o = aluop_i;
    
    // mem_addr_o传递到访存阶段，是加载、存储指令对应的存储器地址
    // 此处的reg1_i计时加载、存储指令中地址为base的通用寄存器的值，
    // inst_i[15:0]就是指令中的offset.
    assign mem_addr_o = reg1_i + {{16{inst_i[15]}}, inst_i[15:0]};
    
    // reg2_i是存储指令要存储的数据，或者lwl、lwr指令要加载到目的寄存器的原始值，
    // 将该值通过reg2_o接口传递到访存阶段
    assign reg2_o = reg2_i;
    
    /*  (1)如果是加法或者有符号数比较运算，那么reg2_i_mux等于第二个操作数reg2_i的补码，
        否则reg2_i_mux就等于第二个操作数reg2_i
    */
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) ||
                         (aluop_i == `EXE_SUBU_OP) ||
                         (aluop_i == `EXE_SLT_OP)) ?
                         (~reg2_i)+1 : reg2_i;
    /*  (2)A.如果是加法运算，reg2_i_mux就是第二个操作数 reg2_i,result_sum就是加法运算的结果
        B.如果是减法运算，reg2_i_mux是第二个操作数reg2_i的补码，result_sum就是减法运算的结果
        C.如果是有符号比较运算，reg2_i_mux是第二个操作数reg2_i的补码，result_sum也是减法运算的结果，
        可以通过判断减法的结果是否小于零，进而判断reg1_i是否小于reg2_i
    */
    assign result_sum = reg1_i + reg2_i_mux;
    /*  (3)计算是否溢出，加法指令(add和addi)、减法指令(sub)执行时，
        需要判断是否溢出，满足以下两种情况之一时，有溢出：
        A.reg1_i为正数，reg2_i_mux为正数，但两者之和为负数
        B.reg1_i为负数，reg2_i_mux为负数，但两者之和为正数
    */
    assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
                    ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
    /*  (4)计算操作数1是否小于操作数2，分两种情况:
        A.aluop_i为EXE_SLT_OP表示有符号比较运算，此时又分3种情况
            A1.reg1_i为负数、reg2_i为正数，显然reg1_i小于reg2_i
            A2.reg1_i为正数，reg2_i为正数，并且reg1_i减去reg2_i的值小于0(即result_sum为负)，此时reg1_i小于reg2_i
            A3.reg1_i为负数、reg2_i为负数，并且reg1_i减去reg2_i的值小于0(即result_sum为负)，此时reg1_i小于reg2_i
        B.无符号数比较时，直接使用比较运算符比较reg1_i和reg2_i
    */
    assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP))?
                          ((reg1_i[31] && !reg2_i[31]) ||
                          (!reg1_i[31] && !reg2_i[31] && result_sum[31]) ||
                          (reg1_i[31] && reg2_i[31] && result_sum[31]))
                          : (reg1_i < reg2_i);       
    /*  (5)对操作数1按位取反，赋给reg1_i_not
    */
    assign reg1_i_not = ~reg1_i;
    
    /***依据aluop_i指示的运算子类型进行运算***/
    //依据不同的算术运算类型，给arithmeticres变量赋值
    always @ (*) begin
        if (rst == `RstEnable) begin
            arithmeticres <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP: begin     // 比较运算
                    arithmeticres <= reg1_lt_reg2;
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin   //  加法运算
                    arithmeticres <= result_sum;
                end  
                `EXE_SUB_OP, `EXE_SUBU_OP: begin    // 减法运算
                    arithmeticres <= result_sum;
                end
//                `EXE_CLZ_OP: begin                  // 计数运算clz
//                end
//                `EXE_CLO_OP: begin                  // 计数运算clo
//                end
                default: begin
                    arithmeticres <= `ZeroWord;
                end
            endcase
        end
    end
    
    // 进行乘法运算
    /*  (1)取得乘法运算的被乘数，如果是有符号数且被乘数是负数，那么取补码
    */
    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || 
                          (aluop_i == `EXE_MULT_OP)) &&
                          (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;
    /*  (2)取得乘法运算的乘数，如果是有符号乘法且乘数是负数，那么取补码
    */
    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || 
                          (aluop_i == `EXE_MULT_OP)) &&
                          (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;
    /*  (3)得到临时乘法结果，保存在变量hilo_temp中
    */
    assign hilo_temp = opdata1_mult * opdata2_mult;
    /*  (4)对临时乘法结果进行修正，最终都乘法结果保存在变量mulres中，主要有两点：
        A.如果是有符号乘法指令mult、mul，那么需要修正临时乘法结果，如下：
            A1.如果被乘数与乘数两者一正一负，那么需要对临时乘法结果hilo_temp求补码，
                作为最终的乘法结果，赋值给变量mulres.
            A2.如果被乘数与乘数同号，那么hilo_temp的值就作为最终的乘法结果，赋值给变量mulres.
        B.如果是无符号乘法指令multu，那么hilo_temp的值就作为最终的乘法结果，赋值给变量mulres.
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
    
    //进行逻辑运算
    always @ (*) begin
        if (rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP: begin               // 逻辑或运算
                    logicout <= reg1_i | reg2_i;
                end
                `EXE_AND_OP: begin              // 逻辑与运算
                    logicout <= reg1_i & reg2_i;
                end
                `EXE_NOR_OP: begin              // 逻辑或非运算
                    logicout <= ~(reg1_i | reg2_i);
                end
                `EXE_XOR_OP: begin              // 逻辑异或运算
                    logicout <= reg1_i ^ reg2_i;
                end
                default: begin
                    logicout <= `ZeroWord;
                end
            endcase
        end
    end
    
    // 进行移位运算
    always @ (*) begin
        if (rst == `RstEnable) begin
            shiftres <=  `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP: begin              // 逻辑左移
                    shiftres <= reg2_i << reg1_i[4:0];
                end
                `EXE_SRL_OP: begin              // 逻辑右移
                    shiftres <= reg2_i >> reg1_i[4:0];
                end
                `EXE_SRA_OP: begin              // 算术右移
                    shiftres <= ({32{reg2_i[31]}}<<(6'd32-{1'b0,reg1_i[4:0]})) | reg2_i >> reg1_i[4:0];
                end
                default: begin
                    shiftres <= `ZeroWord;
                end
            endcase
        end
    end
    
    // 得到最新的HI、LO寄存器的值，此处解决数据相关问题
    always @ (*) begin
        if (rst == `RstEnable) begin
            {HI, LO} <= {`ZeroWord, `ZeroWord};
        end else if (mem_whilo_i == `WriteEnable) begin
            {HI, LO} <= {mem_hi_i, mem_lo_i};   // 访存阶段的指令要写HI、LO寄存器
        end else if (wb_whilo_i == `WriteEnable) begin
            {HI, LO} <= {wb_hi_i, wb_lo_i};     // 回写阶段的指令要写HI、LO寄存器
        end else begin
            {HI, LO} <= {hi_i, lo_i};
        end
    end
    
    // MFHI、MFLO、MOVN、MOVZ指令
    always @ (*) begin
        if (rst == `RstEnable) begin
            moveres <= `ZeroWord;
        end else begin
            moveres <= `ZeroWord;
            case (aluop_i)
                `EXE_MFHI_OP: begin
                    moveres <= HI;          // mfhi指令，将HI的值作为移动操作的结果
                end
                `EXE_MFLO_OP: begin
                    moveres <= LO;          // mflo指令，将LO的值作为移动操作的结果
                end
                `EXE_MOVZ_OP: begin
                    moveres <= reg1_i;      // movz指令，将reg1_i的值作为移动操作的结果
                end
                `EXE_MOVN_OP: begin
                    moveres <= reg1_i;      // movn指令，将reg1_i的值作为移动操作的结果
                end
                default: begin
                end
            endcase
        end
    end
    
    /***依据alusel_i指示的运算类型，选择一个运算结果作为最终结果***/
    always @ (*) begin
        wd_o <= wd_i;       // wd_o等于wd_i，要写的目的寄存器地址
        // 如果是add、addi、sub、subi指令，且发生溢出，那么设置wreg_o为WriteDisable，表示不写目的寄存器
        if (((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) ||
            (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
            wreg_o <= `WriteDisable;
        end else begin
            wreg_o <= wreg_i;   // wreg_o等于wreg_i，表示是否要写目的寄存器
        end
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout;    // 选择逻辑运算结果作为最终运算结果
            end
            `EXE_RES_SHIFT: begin       // 选择移位运算结果作为最终运算结果
                wdata_o <= shiftres;
            end
            `EXE_RES_MOVE: begin        // 选择移动操作结果为最终运算结果
                wdata_o <= moveres;
            end
            `EXE_RES_ARITHMETIC: begin  // 除乘法外的简单算数操作指令的结果
                wdata_o <= arithmeticres;
            end
            `EXE_RES_MUL: begin         // 乘法指令mul的运算结果
                wdata_o <= mulres[31:0];
            end
            `EXE_RES_JUMP_BRANCH: begin
                wdata_o <= link_address_i;  //  跳转指令，保存返回地址
            end
            default: begin
                wdata_o <= `ZeroWord;
            end
        endcase
    end
    
    // 如果是MTHI、MTLO指令，需要给出whilo_o、hi_o、lo_o的值
    always @ (*) begin
        if (rst == `RstEnable) begin
            whilo_o <= `WriteDisable;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin //mult、multu指令
            whilo_o <= `WriteEnable;
            hi_o <= mulres[63:32];
            lo_o <= mulres[31:0];
        end else if (aluop_i == `EXE_MTHI_OP) begin
            whilo_o <= `WriteEnable;
            hi_o <= reg1_i;
            lo_o <= LO;         // 写HI寄存器，所以LO保持不变
        end else if (aluop_i == `EXE_MTLO_OP) begin
            whilo_o <= `WriteEnable;
            hi_o <= HI;
            lo_o <= reg1_i;     // 写LO寄存器，所以HI保持不变
        end else begin
            whilo_o <= `WriteDisable;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end
    end
    
endmodule
