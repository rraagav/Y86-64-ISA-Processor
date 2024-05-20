module select_PC(
    input clk, 
    input [63:0] F_predPC, 
    input [63:0] W_valM, 
    input [63:0] M_valA, 
    input [3:0] M_icode, 
    input [3:0] W_icode, 
    input M_cnd, 
    output reg [63:0] PC_new
);

always @(*)
    begin
        if(M_icode == 7 && M_cnd==0)
        begin
            PC_new = M_valA;
        end

        else if(W_icode == 9)
        begin
            PC_new = W_valM;
        end
        
        else
        begin
            //$display ("heloo");
            PC_new = F_predPC;
        end
    end

endmodule