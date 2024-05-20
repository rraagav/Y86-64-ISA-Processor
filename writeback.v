module writeback(
    input clk,                 
    input [3:0] W_icode, W_stat, W_destE, W_destM,
    input [63:0] W_valM, W_valE,
    input g,
    input ge,
    input e,
    input ne,
    input le, 
    input l,  
    output reg halt,          
    output reg [63:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14,
    output reg [63:0] valA,
    output reg [63:0] valB
);
    
    reg [63:0] registers [0:14];

        integer i;
        initial begin
            for(i = 0; i <= 14; i=i+1) 
            begin
                registers[i] = i;
            end
        end 

    reg [63:0] address;
    reg stack_pointer;

    always @(*)
    begin
        if (W_icode == 4'b0000)
        begin
            halt = 1;
        end
        
        if (W_icode == 4'b0010)
        begin
            address = W_destE;
            registers[address] = W_valE;
        end
        if (W_icode == 4'b0011) 
        begin
            address = W_destE;
            registers[address] = W_valE;
        end
        if (W_icode == 4'b0110)
        begin
            address = W_destE;
            registers[address] = W_valE;
        end
        if (W_icode == 4'b0101)
        begin
            address = W_destM;
            registers[address] = W_valM;
        end
        if (W_icode == 4'b1001)
        begin
            stack_pointer = 4;
            registers[stack_pointer] = W_valE;
        end
        if (W_icode == 4'b1010)
        begin
            stack_pointer = 4;
            registers[4] = registers[4] - 8;
        end
        if (W_icode == 4'b1011)
        begin
            stack_pointer = 4;            
            registers[W_destM] = W_valM;
            registers[4] = registers[4] + 8;
        end
        if (W_icode == 4'b1000)
        begin
            stack_pointer = 4;
            registers[stack_pointer] = W_valE;
        end

    end

    always @(posedge clk)
     begin
        reg0 = registers[0];
        reg1 = registers[1];
        reg2 = registers[2];
        reg3 = registers[3];
        reg4 = registers[4];
        reg5 = registers[5];
        reg6 = registers[6];
        reg7 = registers[7];
        reg8 = registers[8];
        reg9 = registers[9];
        reg10 = registers[10];
        reg11 = registers[11];
        reg12 = registers[12];
        reg13 = registers[13];
        reg14 = registers[14];
        
    end

endmodule