module w_reg(

input clk, W_stall,
input [3:0] m_stat, m_icode, m_ifun, m_destE, m_destM,
input [63:0] m_valE, m_valM,

output reg m_cnd,
output reg [3:0] W_stat, W_icode, W_ifun, W_destE, W_destM,
output reg [63:0] W_valE, W_valM
);

always @(posedge clk)
    begin
        if(W_stall == 0)
        begin
            W_stat = m_stat;
            W_icode = m_icode;
            W_ifun = m_ifun;
            W_valE = m_valE;
            W_valM = m_valM;
            W_destE = m_destE; 
            W_destM = m_destM;
        end
    end
endmodule