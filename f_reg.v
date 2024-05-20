module f_reg(
    input clk,
    input F_stall,
    input [3:0] F_stat,
    input [63:0] predPC,
    input [63:0] F_pc,
    output reg [63:0] F_predPC,
    output reg [3:0] f_stat
);

always @(*)
begin
    f_stat = F_stat;
    //$display ("heloo");
    if(F_stall == 0)
    begin
        
        F_predPC = predPC;
    end

    else
    begin
        F_predPC = F_pc;
    end
end
endmodule