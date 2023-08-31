`timescale 1ns / 1ps
`include "define.vh"

`define DIGITAL_NUM_ADDR    16'h8000 // 0xbfaf_8000


module confreg(
    input   wire        clk,
    input   wire        rst,

    input   wire        confreg_wen,
    input   wire[31:0]  confreg_write_data, // CPU向外设传输的数据
    input   wire[31:0]  confreg_addr, //CPU写外设的地址
    output  wire[31:0]  confreg_read_data, //外设向CPU传输的数�?

    output  wire[6:0]   digital_num0,
    output  wire[6:0]   digital_num1,
    // digital_num0/1：数码管0-3位，4-7位显示数字；
    output  wire[7:0]   digital_cs, //digcs：八位片选信号，控制数码管的八个数字�?
    // output  reg[3:0]    counter_num // 给vga的数�? 4�?
    output  reg[5:0]    counter_num // 给vga的数�? 6�?
    );
    
    reg[31:0]   digital_num_v;
    
    //vag and serial port output num
    always@(posedge clk) begin
        // if(!rst) counter_num<=4'b0; // 此时要复�?
        // else counter_num<=digital_num_v[27:24];
        if(!rst) counter_num<=6'b0; // 此时要复�?
        else counter_num<=digital_num_v[29:24];
    end
    
    // read confreg
    assign confreg_read_data = get_confreg_read_data(confreg_addr);
    function [31:0] get_confreg_read_data(input [31:0] confreg_addr);
    begin
        case(confreg_addr[15:0])
        `DIGITAL_NUM_ADDR   : get_confreg_read_data = digital_num_v;
        default: get_confreg_read_data = 32'b0;
        endcase
    end
endfunction
    // 如果来的地址confreg_addr�?0x8000 那么把数据digital_num_v给到数据

    /*********** digital num ***********/
    reg[19:0] count;
//    reg[3:0] scan_data1, scan_data2;
    reg[5:0] scan_data1;
    reg[7:0] scan_enable;
    reg[6:0] num_a_g1, num_a_g2;

    wire write_digital_num;
    assign write_digital_num = confreg_wen & (confreg_addr[15:0] == `DIGITAL_NUM_ADDR);
    // 能否�? confreg_wen 外设写使�? 地址是否正�'
    
    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            digital_num_v <= 32'b0;
        end else begin
            if (write_digital_num) begin
                digital_num_v <= confreg_write_data;
            end
        end
    end

    assign digital_cs = scan_enable;
    assign digital_num0 = num_a_g1;
    assign digital_num1 = num_a_g2;

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            count <= 20'b0;
        end else begin
            count <= count + 1;
        end
    end

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
        //    scan_data1 <= 4'b0;
            scan_data1 <= 6'b0;
            scan_enable <= 8'b0;
        end else begin
        $display("aaa");
//            case(count[18])
            // 不要变的太快�?
//            1'b0: begin
//                scan_data1 <= digital_num_v[31:28];
//                scan_enable <= 8'b0000_0010;
//            end
//            1'b1: begin
                begin
//                scan_data1 <= digital_num_v[27:24];
                scan_data1 <= digital_num_v[29:24];
//                scan_enable <= 8'b0000_0001;
                scan_enable <= 8'b1111_1111;
            end
//            default: ;
//            endcase
        end
    end

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            num_a_g1 <= 7'b0;
            num_a_g2 <= 7'b0;
        end else begin
            case(scan_data1 % 10)
            4'd0: num_a_g1 <= 7'b111_1110; // 0
            4'd1: num_a_g1 <= 7'b011_0000; // 1
            4'd2: num_a_g1 <= 7'b110_1101; // 2
            4'd3: num_a_g1 <= 7'b111_1001; // 3
            4'd4: num_a_g1 <= 7'b011_0011; // 4
            4'd5: num_a_g1 <= 7'b101_1011; // 5
            4'd6: num_a_g1 <= 7'b101_1111; // 6
            4'd7: num_a_g1 <= 7'b111_0000; // 7
            4'd8: num_a_g1 <= 7'b111_1111; // 8
            4'd9: num_a_g1 <= 7'b111_1011; // 9
            // 4'd10: num_a_g1 <= 7'b111_0111; // 10
            // 4'd11: num_a_g1 <= 7'b001_1111; // 11
            // 4'd12: num_a_g1 <= 7'b100_1110; // 12
            // 4'd13: num_a_g1 <= 7'b011_1101; // 13
            // 4'd14: num_a_g1 <= 7'b100_1111; // 14
            // 4'd15: num_a_g1 <= 7'b100_0111; // 15
            default: ;
            endcase

            case(scan_data1 / 10)
            4'd0: 
            begin 
            num_a_g2 <= 7'b111_1110; // 0
            end
            4'd1: num_a_g2 <= 7'b011_0000; // 1
            4'd2: num_a_g2 <= 7'b110_1101; // 2
            4'd3: num_a_g2 <= 7'b111_1001; // 3
            4'd4: num_a_g2 <= 7'b011_0011; // 4
            4'd5: num_a_g2 <= 7'b101_1011; // 5
            4'd6: num_a_g2 <= 7'b101_1111; // 6
            4'd7: num_a_g2 <= 7'b111_0000; // 7
            4'd8: num_a_g2 <= 7'b111_1111; // 8
            4'd9: num_a_g2 <= 7'b111_1011; // 9
            default: ;
            endcase

        end
    end
endmodule
