module e_reg(
input clk, 
input E_bubble,
input [63:0] d_valA ,d_valB, d_valC,
input [3:0] d_srcA ,d_srcB, d_destE ,d_destM, d_icode ,d_ifun, d_stat,

output reg [63:0] E_valA, E_valB, E_valC,
output reg [3:0] E_destE, E_destM, E_icode, E_ifun, E_stat
);

always @(posedge clk)
begin 
   if(E_bubble == 0)
   begin
      E_destE = d_destE ;
      E_destM = d_destM ;
      E_icode = d_icode;
      E_ifun = d_ifun ;
   end

   else if (E_bubble == 1)
   begin
      E_icode = 4'b1; //call the nop instruction, dynamically insert the bubble at Execute (put h'F)
      E_destE = 4'hF ;
      E_destM = 4'hF ;
   end

   E_valA = d_valA ;
   E_valB = d_valB ;
   E_valC = d_valC ;
   E_stat = d_stat ;
   
end
endmodule