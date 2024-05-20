

module decoder(
    input clk,                 
    input [3:0] D_rA,           
    input [3:0] D_rB,           
    input [3:0] D_icode,       
    input [3:0] D_ifun,     
    input [63:0] D_valC,
    input [3:0] D_stat,

    input g,
    input ge,
    input e,
    input ne,
    input le, 
    input l,        

    input [63:0] W_valM,
    input [63:0] m_valM,
    input [63:0] e_valE,
    input [63:0] M_valE,
    input [63:0] W_valE,
    input [63:0] D_valP,

    input [3:0] W_destE, W_destM, M_destM, e_destE, M_destE,

    input [63:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14,

    output reg [63:0] d_valA, d_valB, d_valC,
    output reg [3:0] d_destE, d_destM, d_stat, d_icode, d_ifun,d_srcA, d_srcB

);

        reg [63:0] registers [0:14];

        integer i;
        initial begin
            for(i = 0; i <= 14; i = i + 1) begin
                registers[i] = 0;
            end
        end 

    
    reg stack_pointer;

    always @(*)
    begin
        registers[0] = reg0;
        registers[1] = reg1;
        registers[2] = reg2;
        registers[3] = reg3;
        registers[4] = reg4;
        registers[5] = reg5;
        registers[6] = reg6;
        registers[7] = reg7;
        registers[8] = reg8;
        registers[9] = reg9;
        registers[10] = reg10;
        registers[11] = reg11;
        registers[12] = reg12;
        registers[13] = reg13;
        registers[14] = reg14;

        d_icode = D_icode;
        d_stat = D_stat;
        d_ifun = D_ifun;
        d_valC = D_valC;

        d_destM = 4'b1111;
        d_destE = 4'b1111;

        //halt and nop - do nothing.
        if (D_icode == 4'b0010)
        begin
            //cmovXX
            d_srcA = D_rA;
            d_destE = D_rB;
            //valA = registers[rA];
        end

        if (D_icode == 4'b0011)
        begin
            //irmovq
            d_destE = D_rB;
            //valA = registers[rB];
        end

        if (D_icode == 4'b0100)
        begin
            //rmmovq
            d_srcA = D_rA;
            d_srcB = D_rB;
        end

        if (D_icode == 4'b0101)
        begin
            //mrmovq
            d_srcB = D_rB;
            d_destM = D_rA;
            //valB = registers[rB];
        end 

        if (D_icode == 4'b0110)
        begin
            //OPq
            d_srcA = D_rA;
            d_srcB = D_rB;
            d_destE = D_rB;
            //valA = registers[rA];
            //valB = registers[rB];
        end

        if (D_icode == 4'b1000)
        begin
        //call
        d_srcB = 4'b0100;
        d_destE = 4'b0100;
            //stack_pointer = 4;
            // valA = registers[stack_pointer];   
            // valB = registers[stack_pointer];   
        end

        if (D_icode == 4'b1001)
        begin
            //ret
            //stack_pointer = 4;
            // valA = registers[stack_pointer];   
            //valB = registers[stack_pointer];
            d_destE = 4'b0100;
            d_srcA = 4'b0100;
            d_srcB = 4'b0100;
        end

        if (D_icode == 4'b1010)
        begin
            //pushq
            //stack_pointer = 4;
            //valA = registers[rA];
            //valB = registers[stack_pointer];
            d_srcA = D_rA;
            d_srcB = 4'b0100;
            d_destE = 4'b0100;

        end

        if (D_icode == 4'b1011)
        begin
            //popq
            d_srcA = 4'b0100;
            d_srcB = 4'b0100;
            d_destM = D_rA;
            d_destE = 4'b0100;
            //stack_pointer = 4;
            //valB = registers[stack_pointer];
        end 
    end

    always @(*)
    begin
         
        if (D_icode == 7 || D_icode == 8 )
            begin
                d_valA = D_valP;
            end
        else if(d_srcA == e_destE)
        begin
            d_valA = e_valE;
        end
        else if(d_srcA == M_destM)
        begin
            d_valA = m_valM;
        end
        else if(d_srcA == M_destE)
        begin
            d_valA = M_valE;
        end
        else if(d_srcA == W_destM)
        begin
            d_valA = W_valM;
        end
        else if(d_srcA == W_destE)
        begin
            d_valA = W_valE;
        end
        else
        begin
            d_valA = registers[d_srcA];
        end
    end 

    always @(*)
    begin
        if(d_srcB == e_destE)
        begin
            d_valB = e_valE;
        end
        else if(d_srcB == M_destM)
        begin
            d_valB = m_valM;
        end
        else if(d_srcB == M_destE)
        begin
            d_valB = M_valE;
        end
        else if(d_srcB == W_destM)
        begin
            d_valB = W_valM;
        end
        else if(d_srcB == W_destE)
        begin
            d_valB = W_valE;
        end
        else
        begin
            d_valB = registers[d_srcB];
        end
    end

endmodule
