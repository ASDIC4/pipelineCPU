`timescale 1ns / 1ps
`include "define.vh"

module inst_rom(
    input   wire        ce,
    input   wire[`InstAddrBus]  addr,
    output  reg[`InstBus]      inst
    );
    
    // 定义一个数组，大小为InstMemNum，元素宽度为InstBus
    reg[`InstBus]   inst_mem[0:`InstMemNum-1];
    
    // 使用文件inst_rom.data初始化指令存储器
    initial begin
    $readmemh("D:/1.txt", inst_mem);
    end
    // 当复位信号无效时，依据输入的地址，给出指令存储器ROM中对应的元素
    always @ (*) begin
        if (ce == `ChipDisable) begin
            inst <= `ZeroWord;
        end else begin
            inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end
    
endmodule
