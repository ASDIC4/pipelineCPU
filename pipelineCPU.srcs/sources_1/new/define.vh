/***ȫ�ֺ궨��***/
`define RstEnable       1'b1            // ��λ�ź���Ч
`define RstDisable      1'b0            // ��λ�ź���Ч
`define ZeroWord        32'h00000000    // 32λ����ֵ0
`define WriteEnable     1'b1            // ʹ��д
`define WriteDisable    1'b0            // ��ֹд
`define ReadEnable      1'b1            // ʹ�ܶ�
`define ReadDisable     1'b0            // ��ֹ��
`define AluOpBus        7:0             // ����׶ε����aluop_o�Ŀ���
`define AluSelBus       2:0             // ����׶ε����alusel_o�Ŀ���
`define InstValid       1'b0            // ָ����Ч
`define InstInvalid     1'b1            // ָ����Ч
`define Stop            1'b1            // ��ˮ����ͣ
`define NoStop          1'b0            // ��ˮ�߼���
`define InDelaySlot     1'b1            // �����ӳٲ�
`define NotInDelaySlot  1'b0            // �������ӳٲ�
`define Branch          1'b1            // ��ת
`define NotBranch       1'b0            // ����ת
`define True_v          1'b1            // �߼�"��"
`define False_v         1'b0            // �߼�"��"
`define ChipEnable      1'b1            // оƬʹ��
`define ChipDisable     1'b0            // оƬ��ֹ

/***ָ����غ궨��***/
`define EXE_AND         6'b100100       // andָ��Ĺ�����
`define EXE_OR          6'b100101       // orָ��Ĺ�����
`define EXE_XOR         6'b100110       // xorָ��Ĺ�����
`define EXE_NOR         6'b100111       // norָ��Ĺ�����
`define EXE_ANDI        6'b001100       // andiָ��Ĺ�����
`define EXE_ORI         6'b001101       // ָ��ori��ָ����
`define EXE_XORI        6'b001110       // xoriָ��Ĺ�����
`define EXE_LUI         6'b001111       // luiָ��Ĺ�����

`define EXE_SLL         6'b000000       // sllָ��Ĺ�����
`define EXE_SLLV        6'b000100       // sllvָ��Ĺ�����
`define EXE_SRL         6'b000010       // srlָ��Ĺ�����
`define EXE_SRLV        6'b000110       // srlvָ��Ĺ�����
`define EXE_SRA         6'b000011       // sraָ��Ĺ�����
`define EXE_SRAV        6'b000111       // sravָ��Ĺ�����

`define EXE_MOVZ        6'b001010       // movzָ��Ĺ�����
`define EXE_MOVN        6'b001011       // movnָ��Ĺ�����
`define EXE_MFHI        6'b010000       // mfhiָ��Ĺ�����
`define EXE_MTHI        6'b010001       // mthiָ��Ĺ�����
`define EXE_MFLO        6'b010010       // mfloָ��Ĺ�����
`define EXE_MTLO        6'b010011       // mtloָ��Ĺ�����

`define EXE_SLT         6'b101010
`define EXE_SLTU        6'b101011
`define EXE_SLTI        6'b001010
`define EXE_SLTIU       6'b001011   
`define EXE_ADD         6'b100000
`define EXE_ADDU        6'b100001
`define EXE_SUB         6'b100010
`define EXE_SUBU        6'b100011
`define EXE_ADDI        6'b001000
`define EXE_ADDIU       6'b001001

`define EXE_MULT        6'b011000
`define EXE_MULTU       6'b011001
`define EXE_MUL         6'b000010

`define EXE_J           6'b000010
`define EXE_JAL         6'b000011
`define EXE_JALR        6'b001001
`define EXE_JR          6'b001000
`define EXE_BEQ         6'b000100
`define EXE_BGEZ        5'b00001
`define EXE_BGEZAL      5'b10001
`define EXE_BGTZ        6'b000111
`define EXE_BLEZ        6'b000110
`define EXE_BLTZ        5'b00000
`define EXE_BLTZAL      5'b10000
`define EXE_BNE         6'b000101

`define EXE_LB  6'b100000
`define EXE_LBU  6'b100100
`define EXE_LH  6'b100001
`define EXE_LHU  6'b100101
`define EXE_LL  6'b110000
`define EXE_LW  6'b100011
`define EXE_LWL  6'b100010
`define EXE_LWR  6'b100110
`define EXE_SB  6'b101000
`define EXE_SC  6'b111000
`define EXE_SH  6'b101001
`define EXE_SW  6'b101011
`define EXE_SWL  6'b101010
`define EXE_SWR  6'b101110

`define EXE_SYNC        6'b001111       // syncָ��Ĺ�����
`define EXE_PREF        6'b110011       // prefָ��Ĺ�����
`define EXE_SPECIAL_INST    6'b000000   // SPECIAL��ָ���ָ����
`define EXE_SPECIAL2_INST   6'b011100   // SPECIAL2��ָ���ָ����
`define EXE_REGIMM_INST 6'b000001       // ��ָ֧���ָ����

// AluOp
`define EXE_AND_OP      8'b00100100
`define EXE_OR_OP       8'b00100101
`define EXE_XOR_OP      8'b00100110
`define EXE_NOR_OP      8'b00100111
`define EXE_ANDI_OP     8'b01011001
`define EXE_ORI_OP      8'b01011010
`define EXE_XORI_OP     8'b01011011
`define EXE_LUI_OP      8'b01011100

`define EXE_SLL_OP      8'b01111100
`define EXE_SLLV_OP     8'b00000100
`define EXE_SRL_OP      8'b00000010
`define EXE_SRLV_OP     8'b00000110
`define EXE_SRA_OP      8'b00000011
`define EXE_SRAV_OP     8'b00000111

`define EXE_MOVZ_OP     8'b00001010
`define EXE_MOVN_OP     8'b00001011
`define EXE_MFHI_OP     8'b00010000
`define EXE_MTHI_OP     8'b00010001
`define EXE_MFLO_OP     8'b00010010
`define EXE_MTLO_OP     8'b00010011


`define EXE_SLT_OP      8'b00101010
`define EXE_SLTU_OP     8'b00101011
`define EXE_SLTI_OP     8'b01010111
`define EXE_SLTIU_OP    8'b01011000   
`define EXE_ADD_OP      8'b00100000
`define EXE_ADDU_OP     8'b00100001
`define EXE_SUB_OP      8'b00100010
`define EXE_SUBU_OP     8'b00100011
`define EXE_ADDI_OP     8'b01010101
`define EXE_ADDIU_OP    8'b01010110

`define EXE_MULT_OP     8'b00011000
`define EXE_MULTU_OP    8'b00011001
`define EXE_MUL_OP      8'b10101001

`define EXE_J_OP        8'b01001111
`define EXE_JAL_OP      8'b01010000
`define EXE_JALR_OP     8'b00001001
`define EXE_JR_OP       8'b00001000
`define EXE_BEQ_OP      8'b01010001
`define EXE_BGEZ_OP     8'b01000001
`define EXE_BGEZAL_OP   8'b01001011
`define EXE_BGTZ_OP     8'b01010100
`define EXE_BLEZ_OP     8'b01010011
`define EXE_BLTZ_OP     8'b01000000
`define EXE_BLTZAL_OP   8'b01001010
`define EXE_BNE_OP      8'b01010010
`define EXE_NOP_OP      8'b00000000

`define EXE_LB_OP  8'b11100000
`define EXE_LBU_OP  8'b11100100
`define EXE_LH_OP  8'b11100001
`define EXE_LHU_OP  8'b11100101
`define EXE_LL_OP  8'b11110000
`define EXE_LW_OP  8'b11100011
`define EXE_LWL_OP  8'b11100010
`define EXE_LWR_OP  8'b11100110
`define EXE_PREF_OP  8'b11110011
`define EXE_SB_OP  8'b11101000
`define EXE_SC_OP  8'b11111000
`define EXE_SH_OP  8'b11101001
`define EXE_SW_OP  8'b11101011
`define EXE_SWL_OP  8'b11101010
`define EXE_SWR_OP  8'b11101110

// AluSel
`define EXE_RES_LOGIC   3'b001
`define EXE_RES_SHIFT   3'b010
`define EXE_RES_MOVE    3'b011
`define EXE_RES_ARITHMETIC  3'b100	
`define EXE_RES_MUL     3'b101
`define EXE_RES_JUMP_BRANCH 3'b110
`define EXE_RES_LOAD_STORE 3'b111	

`define EXE_RES_NOP     3'b000

/***��ָ��洢��ROM�йصĺ궨��***/
`define InstAddrBus     31:0            // ROM�ĵ�ַ���߿���
`define InstBus         31:0            // ROM���������߿���
`define InstMemNum      63              // ROM��ʵ�ʴ�СΪ128KB
`define InstMemNumLog2  17              // ROMʵ��ʹ�õĵ�ַ�߿���

/***�����ݴ洢��RAM�йصĺ궨��***/
`define DataAddrBus     31:0
`define DataBus         31:0
`define DataMemNum      63
`define DataMemNumLog2  17
`define ByteWidth       7:0             // һ���ֽڵĿ��ȣ�8bit

/***��ͨ�üĴ���RegFile�йصĺ컨����***/
`define RegAddrBus      4:0             // RegFileģ��ĵ�ַ�߿���
`define RegBus          31:0            // RegFileģ��������߿���
`define RegWidth        32              // ͨ�üĴ����Ŀ���
`define DoubleRegWidth  64              // ������ͨ�üĴ�������
`define DoubleRegBus    63:0              // ������ͨ�üĴ����������߿���
`define RegNum          32              // ͨ�üĴ�������
`define RegNumLog2      5               // ͨ�üĴ���ʹ�õĵ�ַλ��
`define NOPRegAddr      5'b00000