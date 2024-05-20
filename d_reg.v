module d_reg(
input clk, 
input D_stall, 
input D_bubble,
input [3:0] f_icode, f_ifun, f_stat,
input [3:0] f_rA, f_rB,
input [63:0] f_valC, f_valP,
input hlt, instr_valid, imem_err,

output reg [3:0] D_icode, D_ifun, D_stat,
output reg [3:0] D_rA, D_rB,
output reg [63:0] D_valC, D_valP
);

always @(posedge clk)
begin 
   
   if(D_stall==0)
   begin
      if(D_bubble == 0) 
      begin
         D_rA = f_rA;
         D_rB = f_rB;
         D_icode = f_icode; 
         D_ifun = f_ifun;
         D_valC = f_valC;
         D_valP = f_valP;
         
         if(hlt == 1)
         begin
            D_stat = 4'h2 ;
         end
         else if(imem_err == 1)
         begin
            D_stat = 4'h3 ;
         end
         else if(instr_valid == 1)
         begin
            D_stat = 4'h4;
         end
         else
            D_stat = f_stat;
      end

      else if(D_bubble == 1) 
      begin 
         D_icode = 4'b1;
         D_ifun  = 4'b0;
      end
   end
end
endmodule




