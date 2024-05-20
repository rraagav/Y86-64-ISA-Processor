module m_reg(
    input clk, 
    input M_bubble,
    input e_cnd,
    input [3:0] e_stat, e_icode, e_ifun, e_destE, e_destM,
    input [63:0] e_valA, e_valE, 
    output reg M_cnd,
    output reg [63:0] M_valA, M_valE, 
    output reg [3:0] M_stat, M_icode, M_ifun, M_destE, M_destM
);

always@(posedge clk)
    begin
        if(M_bubble == 1)
        begin
            M_icode = 4'b1;
            M_destE = 4'hF;
            M_destM = 4'hF;
        end

        else if (M_bubble == 0)
        begin
            M_icode = e_icode;
            M_destE = e_destE;
            M_destM = e_destM;
        end

        M_valA = e_valA;
        M_valE = e_valE;
        M_stat = e_stat;
        M_cnd = e_cnd;
        M_ifun = e_ifun;
        
    end
endmodule