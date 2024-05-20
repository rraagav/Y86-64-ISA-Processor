`include "final.v"

module execute (
    input clk,
    input [63:0] E_valA, E_valB, E_valC,
    input [3:0] E_icode, E_ifun,
    input [3:0]  E_destE ,E_destM, E_stat,
    output reg [63:0] e_valA, e_valE,
    output reg [3:0] e_destE, e_destM,
    output reg [3:0] e_icode, e_ifun, e_stat,
    output reg e_cnd,
    output reg g,
    output reg ge,
    output reg e,
    output reg ne,
    output reg le,
    output reg l,
    output reg [63:0] val_temp
);

    wire [63:0] sum, diff, and_out, xor_out;
    wire overflow;

    wire [63:0] sum1, diff1, and_out1, xor_out1;
    wire overflow1;

    wire [63:0] sum2, diff2, and_out2, xor_out2;
    wire overflow2;

    wire [63:0] sum3, diff3, and_out3, xor_out3;
    wire overflow3;

    wire [63:0] sum4, diff4, and_out4, xor_out4;
    wire overflow4;

    reg overflowflag;
    
    reg ZF,SF,OF;
    
    initial 
    begin
        ZF = 0;
        SF = 0;
        OF = 0;
        g = 0;
        ge = 0;
        e = 0;
        ne = 0;
        le = 0;
        l = 0;
    end

    final final_module0(1'b0, 1'b0, E_valA, E_valB, sum, diff, and_out, xor_out, overflow);

    final final_module1(1'b0, 1'b0, E_valC, E_valB, sum1, diff1, and_out1, xor_out1, overflow1);

    final final_module2(1'b1, 1'b1,E_valA, E_valB, sum2,diff2, and_out2, xor_out2, overflow2);

    final final_module3(1'b1, 1'b0, E_valA, E_valB, sum3, diff3, and_out3, xor_out3, overflow3);

    final final_module4(1'b0, 1'b1, E_valA, E_valB, sum4, diff4, and_out4, xor_out4, overflow4);

    always @(*) begin

        e_valA = E_valA;
        e_icode = E_icode;
        e_ifun = E_ifun;
        e_stat = E_stat;
        e_destE = E_destE; 
        e_destM = E_destM;
        e_cnd = 0;

            case(E_icode)
                4'b0100, 4'b0101: begin // rmmovq and mrmovq
                    e_valE = sum1;
                    //is it E_valC or (E_valA + E_valB) or (E_valA + E_valC)
                end

                4'b0100: begin // push
                    e_valE = E_valB - 64'd8; //changed from E_valA 
                end

                4'b0101: begin // pop
                    e_valE = E_valB + 64'd8;
                end

                8: begin // call
                    e_valE = E_valB + 64'd8;
                end

                9: begin // ret
                    e_valE = E_valB - 64'd8;
                end

                3: begin // irmovq
                    e_valE = E_valC;
                    //could be valC (this was orignially valA)
                    //THIS COULD POTENTIALLY FUCK UP THE CODE PLEASE TAKE A LOOK AT THIS BEFORE!!!!!
                end

                2: begin // rrmovq
                    e_valE = E_valA;
                    if(E_ifun == 4'b0000)
                        e_cnd = 1;
                    if(E_ifun == 4'b0001)
                        e_cnd = le;
                    if(E_ifun == 4'b0010)
                        e_cnd = l;
                    if(E_ifun == 4'b0011)
                        e_cnd = e;
                    if(E_ifun == 4'b0100)
                        e_cnd = ne;
                    if(E_ifun == 4'b0101)
                        e_cnd = ge;
                    if(E_ifun == 4'b0110)
                        e_cnd = g;
                end                    
                //THIS COULD POTENTIALLY FUCK UP THE CODE PLEASE TAKE A LOOK AT THIS BEFORE!!!!!

                6: begin // Add, Subtract, And, Xor
                    case(E_ifun)
                        0: begin // Add
                            e_valE = sum;
                            val_temp = e_valE;
                            overflowflag = overflow;
                        end
                        1: begin // Subtract
                            e_valE = E_valB - E_valA;
                            val_temp = e_valE;
                            overflowflag = overflow3;
                        end
                        2: begin // And
                            e_valE = and_out4;
                            val_temp = e_valE;
                            overflowflag = overflow4;
                        end
                        3: begin // Xor
                            e_valE = xor_out2;
                            val_temp = e_valE;
                            overflowflag = overflow2;
                        end
                    endcase
                end
            
                7: begin //jXX
                    if(E_ifun == 4'b0000)
                        e_cnd = 1;
                    if(E_ifun == 4'b0001)
                        e_cnd = le;
                    if(E_ifun == 4'b0010)
                        e_cnd = l;
                    if(E_ifun == 4'b0011)
                        e_cnd = e;
                    if(E_ifun == 4'b0100)
                        e_cnd = ne;
                    if(E_ifun == 4'b0101)
                        e_cnd = ge;
                    if(E_ifun == 4'b0110)
                        e_cnd = g;
                end
            endcase

        if(val_temp == 0)
        begin
            ZF = 1;
        end

        if(val_temp < 0)
        begin
            SF = 1;
        end

        if(val_temp > 0)
        begin
            ZF = 0;
            SF = 0;
        end

        if(overflowflag == 1)
        begin
            OF = 1;
        end
        
        g = ~(SF ^ OF) && (~ZF);
        ge = ~(SF ^ OF);
        e = ZF;
        ne = ~ZF;
        le = (SF ^ OF) || ZF;
        l = SF ^ OF;
        
    end
endmodule
