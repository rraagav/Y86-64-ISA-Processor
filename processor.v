 `timescale 1ns / 1ps
`include "select_PC.v"
`include "f_reg.v"
`include "fetch.v"
`include "d_reg.v"
`include "decoder.v"
`include "e_reg.v"
`include "execute.v"
`include "m_reg.v"
`include "memory.v"
`include "w_reg.v"
`include "writeback.v"
`include "controllogic.v"
`include "pcupdate.v"

module processor();

// Testbench signals
reg clk;                 
reg [63:0] F_pc;         
wire [63:0] f_valC;        
wire [63:0] f_valP;         
wire [3:0] f_rA;           
wire [3:0] f_rB;           
wire [3:0] f_icode;       
wire [3:0] f_ifun;     
wire imem_error;        
wire halt; 
wire instr_valid;   
wire [63:0]valA;
wire [63:0]valB;
wire [63:0]valE;
wire [63:0]valM;
wire [63:0]destE;
wire [63:0]destM;
wire g;
wire ge;
wire e;
wire ne;
wire l;
wire le;
wire [63:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14;
wire [63:0] newPC;
wire [63:0] val_temp;
wire [63:0] F_predPC; 
wire [63:0] W_valM;
wire [63:0] M_valA,M_valB; 
wire [3:0] W_icode; 
wire M_cnd; 
wire [63:0] PC_new;
wire F_stall;
wire [3:0] F_stat;
wire [63:0] predPC;
wire [3:0] f_stat;
wire e_cnd;
wire [3:0] m_stat, W_stat, d_srcA, d_srcB, E_destM;
wire [3:0]  D_icode, E_icode;
wire set_cc;
wire D_bubble, E_bubble, M_bubble; 
wire D_stall, W_stall;
wire [63:0] d_valA ,d_valB, d_valC;
wire [3:0]d_destE ,d_destM, d_icode ,d_ifun, d_stat;
wire [63:0]E_valA, E_valB, E_valC;
wire [3:0] E_destE, E_ifun, E_stat, e_stat;
wire [3:0] e_icode, e_ifun, e_destE, e_destM;
wire [63:0] e_valA, e_valE, M_valE; 
wire [3:0] M_stat, M_destE, M_destM;
wire [3:0] m_icode, m_ifun,m_destE, m_destM;
wire [63:0] m_valA, m_valB, m_valE;
wire [3:0] W_destE, W_destM;
wire [63:0] W_valE;
wire [3:0]  W_ifun;
wire [63:0] m_valM;
wire [63:0] D_valC, D_valP;
wire [3:0] D_stat, D_rA, D_rB;
wire [3:0] D_ifun;
wire [3:0] M_icode, M_ifun;




select_PC uut1(clk, F_predPC, W_valM, M_valA, M_icode, W_icode, M_cnd, PC_new);

f_reg uut2(clk, F_stall, F_stat, predPC, F_pc, F_predPC, f_stat);
fetch uut3(clk, F_pc,D_stall,D_bubble,f_stat, f_valC, f_valP, f_rA, f_rB, f_icode, f_ifun, imem_error, halt, instr_valid,predPC,D_icode, D_ifun, D_stat,D_rA, D_rB, D_valC, D_valP);

controllogic uut4(clk, e_cnd, m_stat, W_stat, d_srcA, d_srcB, E_destM, D_icode, E_icode, M_icode, set_cc, D_bubble, E_bubble, M_bubble, F_stall, D_stall, W_stall);

//d_reg uut5(clk, D_stall, D_bubble, f_icode, f_ifun, f_stat, f_rA, f_rB, f_valC, f_valP, halt, instr_valid, imem_error, D_icode, D_ifun, D_stat, D_rA, D_rB, D_valC, D_valP);
decoder uut6(clk, D_rA, D_rB, D_icode, D_ifun, D_valC, D_stat, g, ge, e, ne, le, l, W_valM, m_valM, e_valE, M_valE, W_valE, D_valP, W_destE, W_destM, M_destM, e_destE, M_destE, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14, d_valA, d_valB, d_valC, d_destE, d_destM, d_stat,d_icode, d_ifun, d_srcA, d_srcB);

e_reg uut7(clk, E_bubble, d_valA, d_valB, d_valC, d_srcA, d_srcB, d_destE, d_destM, d_icode, d_ifun, d_stat, E_valA, E_valB, E_valC, E_destE, E_destM, E_icode, E_ifun, E_stat);
execute uut8(clk,E_valA, E_valB, E_valC, E_icode, E_ifun, E_destE ,E_destM, E_stat, e_valA, e_valE, e_destE, e_destM, e_icode, e_ifun, e_stat, e_cnd, g, ge, e, ne, le, l, val_temp);

m_reg uut9(clk, M_bubble, e_cnd, e_stat, e_icode, e_ifun, e_destE, e_destM,e_valA, e_valE, M_cnd, M_valA, M_valE, M_stat, M_icode, M_ifun, M_destE, M_destM);
memory uut10(clk, M_valA, M_valB, M_valE, M_icode, M_ifun, M_stat, M_destE, M_destM, m_valA, m_valB, m_valE, m_valM, m_icode, m_ifun, m_stat, m_destE, m_destM);

w_reg uut11(clk, W_stall, m_stat, m_icode, m_ifun, m_destE, m_destM, m_valE, m_valM, m_cnd, W_stat, W_icode, W_ifun, W_destE, W_destM, W_valE, W_valM);
writeback uut12(clk, W_icode, W_stat, W_destE, W_destM, W_valM, W_valE, g, ge, e, ne, le, l, halt, reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12, reg13, reg14,valA, valB);

//pcupdate uut13(clk, F_predPC, f_valP, f_valC, f_icode, predPC);


initial begin
    clk = 0;
    F_pc = 0;
    // forever #5 clk = ~clk;
end

always #5 clk = ~clk;
// begin
//     clk = ~clk;
// end

// initial begin
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
//     #5;
    
//     $finish;
// end
always #250 $finish;


initial begin
    $dumpfile("processor_2.vcd");
    $dumpvars(0, processor);
    // clk = 0;
end

    always@(posedge clk) begin
        F_pc = PC_new;
        if (imem_error == 1)
        begin
            $display("Instruction memory error");
        end
        if(halt == 1)
        begin
            $display("halt");
            $finish;
        end
        if (instr_valid == 1)
        begin
            $display("Instruction invalid");
        end
    
    end

    //always@(*)
    //begin
      //   F_pc = PC_new;
    //end
 
initial begin
            $monitor("Time: %t | F_PC: %d | icode: %h | ifun: %h | rA: %h | rB: %h | valC: %d | valP: %d | valE: %d\n| fstall: %d|predpc: %d",$time, F_pc, W_icode, W_ifun, f_rA, f_rB, f_valC, f_valP, m_valE,F_stall,predPC);
        end
endmodule