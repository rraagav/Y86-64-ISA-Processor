
module fetch(
    input clk,                 
    input [63:0] F_pc,  

    input D_stall, 
    input D_bubble,
    input [3:0] f_stat,
   
    output reg [63:0] f_valC,        
    output reg [63:0] f_valP,         
    output reg [3:0] f_rA,           
    output reg [3:0] f_rB,           
    output reg [3:0] f_icode,       
    output reg [3:0] f_ifun,     
    output reg imem_error,        
    output reg halt, 
    output reg instr_valid , 
    output reg [63:0] predPC,
    output reg [3:0] D_icode, D_ifun, D_stat,
    output reg [3:0] D_rA, D_rB,
    output reg [63:0] D_valC, D_valP
);

reg [7:0]  memory[0:1023]; // 1 KB
reg [0:79] instruction; 

reg needvalc;
integer i;  

initial begin 
    $readmemh("instructions_mispred.txt", memory);
    $display("%h",memory[0]);
end

always @(*)
begin
    imem_error = 0;
    if(F_pc > 1023 || F_pc < 0)
    begin
        imem_error = 1;
    end 

    instruction = {
    memory[F_pc],
    memory[F_pc+1],
    memory[F_pc+2],
    memory[F_pc+3],
    memory[F_pc+4],
    memory[F_pc+5],
    memory[F_pc+6],
    memory[F_pc+7],
    memory[F_pc+8],
    memory[F_pc+9]
  };
  
    f_icode = instruction[0:3];    // Correct if f_icode is the most significant 4 bits
    f_ifun = instruction [4:7];    // Correct if f_ifun follows f_icode

    //needvalc 
    needvalc = 0;

    if (f_icode == 3 || 4 || 5 || 7 || 8)
    begin
        needvalc = 1;
    end

    //instr_valid
    instr_valid = 0;  
    halt = 0;  

    if (f_icode == 4'b0000 || f_icode == 4'b0001 || f_icode == 4'b0010 || f_icode == 4'b0011 || 
    f_icode == 4'b0100 || f_icode == 4'b0101 || f_icode == 4'b0110 || f_icode == 4'b0111 || 
    f_icode == 4'b1000 || f_icode == 4'b1001 || f_icode == 4'b1010 || f_icode == 4'b1011)
    begin

        if(f_icode == 2 || f_icode == 7)
        begin
            if(f_ifun > 6)
            instr_valid = 1;
        end

        else if((f_icode == 6) && (f_ifun > 4))
        begin
            instr_valid = 1;
        end

        else
        instr_valid = 0;    
    end

    if((f_icode == 0) || (f_icode == 1) || (f_icode == 9)) 
    begin
        f_valP = F_pc + 64'd1; 
        if (f_icode == 0)
        begin
           f_valP = F_pc;
        end
    end
    
    else if((f_icode == 2) || (f_icode == 6) || (f_icode == 4'b1010) || (f_icode == 4'b1011))
    begin
        f_rA = instruction[8:11];
        f_rB = instruction[12:15];
        f_valP = F_pc + 64'd2;
    end

    else if((f_icode == 3) || (f_icode == 4) || (f_icode == 5))
    begin
        f_rA = instruction[8:11];
        f_rB = instruction[12:15];
        f_valC = {instruction[72:79],instruction[64:71],instruction[56:63],instruction[48:55],instruction[40:47],instruction[32:39],instruction[24:31],instruction[16:23]};
        f_valP = F_pc + 64'd10;
    end
    
    else if((f_icode == 7) || (f_icode == 8))
    begin
        f_valC = {instruction[64:71],instruction[56:63],instruction[48:55],instruction[40:47],instruction[32:39],instruction[24:31],instruction[16:23],instruction[8:15]};
        f_valP = F_pc + 64'd9;
    end
end

always @(f_valP or f_valC or f_icode )
//always@(*)
begin
    if(f_icode == 7 || f_icode == 8)
    begin
        predPC = f_valC;
    end

    else
    begin
        predPC = f_valP;
    end
end

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
         
         if(halt == 1)
         begin
            D_stat = 4'h2 ;
         end
         else if(imem_error == 1)
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