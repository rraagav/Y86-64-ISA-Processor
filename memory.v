module memory(
    input clk,
    input [63:0] M_valA, M_valB, M_valE,     
    input [3:0] M_icode, M_ifun, M_stat, M_destE, M_destM,
    // input [63:0] valP,
    output reg [63:0] m_valA, m_valB, m_valE, m_valM, 
    output reg [3:0]  m_icode, m_ifun, m_stat, m_destE, m_destM
);

reg [63:0] memory[0:1023]; 
reg [63:0] address;

always @(*)
    begin
        m_valA = M_valA;
        m_valB = M_valB;
        m_valE = M_valE;
        m_icode = M_icode;
        m_ifun = M_ifun;
        m_stat = M_stat;
        m_destE = M_destE;
        m_destM = M_destM;
    end

always@(*)
    begin
        //rmmovq
        if(M_icode == 4'b0100) 
        begin
            address = M_valE;
            memory[address] = M_valA;
        end

        // pushq 
        else if(M_icode == 4'b1010)
        begin
            address = M_valE;
            memory[address]= M_valA;
        end

        // call
        else if (M_icode == 4'b1000) 
        begin 
            address = M_valE;
            memory[address] = M_valA;
            //memory[address] = valP; not seq don;t do thjis?
            //THIS COULD POTENTIALLY FUCK UP THE CODE PLEASE TAKE A LOOK AT THIS BEFORE!!!!!

        end
    end

always@(*)
    begin
        //mrmovq
        if(M_icode == 4'b0101)
        begin
            address = M_valE;
            m_valM = memory[address];
        end

        //popq (We dont know if its M_valB or valA
        if(M_icode==4'b1011)
        begin
            address = M_valE;
            m_valM = memory[address];
        end

        //ret
         else if (M_icode == 4'b1001) 
         begin
            address = M_valA;
            m_valM = memory[address];
        end
    end
  
endmodule