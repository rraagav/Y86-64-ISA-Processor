module proc_pipe();

reg clk;                 
reg [9:0] pc;         
wire [63:0] valC;        
wire [63:0] valP;         
wire [3:0] rA;           
wire [3:0] rB;           
wire [3:0] icode;       
wire [3:0] ifun;     
wire imem_error;        
wire mem_error;
wire instr_valid;
wire [63:0]valA;
wire [63:0]valB;
wire [63:0]valE;
wire [63:0]valM;
wire [63:0]destE;
wire g;
wire ge;
wire e;
wire ne;
wire l;
wire le;
wire [63:0] rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14;
wire [63:0] newPC;
wire [63:0] val_temp;

reg [63:0] registers [0:14];

integer i;
initial begin
    for(i = 0; i <= 14; i=i+1) begin
        registers[i] = 0;
    end
end


initial begin
    clk = 0;
    pc = 0;
    forever #5 clk = ~clk;
end
fetch uut(clk, pc, valC, valP,rA,rB,icode,ifun,imem_error,mem_error,instr_valid);
decoder uut1(clk,rA,rB,icode,ifun,valC,g,ge,e,ne,le,l,valM,valE,valP,valA,valB);
execute uut2(clk,valA,valB,icode,ifun,valC,valE,g,ge,e,ne,le,l,val_temp);
memory uut3(clk,icode,valA,valB,valE,valP,valM);
pcupdate uut4(icode,ifun,valC,valM,valP,le,l,e,ne,ge,g,newPC);
writeback uut5(clk, rA, rB, icode, ifun, valC, g, ge, e, ne, le, l, valM, valE, valP, destE, valA, valB);

initial begin
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    #5;
    $finish;
end
initial begin
    $dumpfile("processor.vcd");
    $dumpvars(0, proc_pipe);
end

    always@(posedge clk) begin
        if (imem_error == 1)
        begin
            $display("Instruction memory error");
        end
        if(mem_error == 1)
        begin
            $display("halt");
            $finish;
        end
        if (instr_valid == 1)
        begin
            $display("Instruction invalid");
        end
    pc = newPC;
    end
 
initial begin
    // Monitor changes and display outputs
    $monitor("Time: %t | PC: %d | icode: %h | ifun: %h | rA: %h | rB: %h | valC: %d | valP: %d |r0 = %d |r1: %d |r2 :%d| valE: %d\n e:%d| val_temp: %d ",$time, pc, icode, ifun, rA, rB, valC, valP, rax, rcx, rdx,valE,e,val_temp);

end

endmodule


module fetch(
    input clk,                 
    input [9:0] pc,         
    output reg [63:0] valC,        
    output reg [63:0] valP,         
    output reg [3:0] rA,           
    output reg [3:0] rB,           
    output reg [3:0] icode,       
    output reg [3:0] ifun,     
    output reg imem_error,        
    output reg mem_error, 
    output reg instr_valid   
);

reg [7:0]  memory[0:1023]; // 1 KB
reg [0:79] instruction; 

reg needvalc;

integer i;

initial begin 
    $readmemh("instructions_1.txt", memory);
    $display("%h",memory[0]);
end

always @(*)
begin
    imem_error = 0;
    if(pc > 1023 || pc < 0)
    begin
        imem_error = 1;
    end 

    instruction = {
    memory[pc],
    memory[pc+1],
    memory[pc+2],
    memory[pc+3],
    memory[pc+4],
    memory[pc+5],
    memory[pc+6],
    memory[pc+7],
    memory[pc+8],
    memory[pc+9]
  };
  
    icode = instruction[0:3];    // Correct if icode is the most significant 4 bits
    ifun = instruction [4:7];    // Correct if ifun follows icode

    

    //needvalc 
    needvalc = 0;

    if (icode == 3 || 4 || 5 || 7 || 8)
    begin
        needvalc = 1;
    end

    //instr_valid
    instr_valid = 0;  
    mem_error = 0;  
    if (icode == 4'b0000 || icode == 4'b0001 || icode == 4'b0010 || icode == 4'b0011 || 
    icode == 4'b0100 || icode == 4'b0101 || icode == 4'b0110 || icode == 4'b0111 || 
    icode == 4'b1000 || icode == 4'b1001 || icode == 4'b1010 || icode == 4'b1011)
    begin

        if(icode == 2 || icode == 7)
        begin
            if(ifun > 6)
            instr_valid = 1;
        end

        else if((icode == 6) && (ifun > 4))
        begin
            instr_valid = 1;
        end

        else
        instr_valid = 0;    
    end

    if((icode == 0) || (icode == 1) || (icode == 9)) 
    begin
        valP = pc + 64'd1; 
        if (icode == 0)
        begin
           mem_error = 1;
        end
    end
    
    else if((icode == 2) || (icode == 6) || (icode == 4'b1010) || (icode == 4'b1011))
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valP = pc + 64'd2;
    end

    else if((icode == 3) || (icode == 4) || (icode == 5))
    begin
        rA = instruction[8:11];
        rB = instruction[12:15];
        valC = {instruction[72:79],instruction[64:71],instruction[56:63],instruction[48:55],instruction[40:47],instruction[32:39],instruction[24:31],instruction[16:23]};
        valP = pc + 64'd10;
    end

    else if((icode == 7) || (icode == 8))
    begin
        valC = {instruction[64:71],instruction[56:63],instruction[48:55],instruction[40:47],instruction[32:39],instruction[24:31],instruction[16:23],instruction[8:15]};
        valP = pc + 64'd9;
    end
end
endmodule

module decoder(
    input clk,                 
    input [3:0] rA,           
    input [3:0] rB,           
    input [3:0] icode,       
    input [3:0] ifun,     
    input [63:0] valC,
    input g,
    input ge,
    input e,
    input ne,
    input le, 
    input l,        
    input [63:0] valM,
    input [63:0] valE,
    input [63:0] valP,
    output reg [63:0] valA,
    output reg [63:0] valB
);

    reg stack_pointer;
    reg [63:0] destE, destM;

    always @(*)
    begin
        //halt and nop - do nothing.
        if (icode == 4'b0010)
        begin
            //cmovXX
            valA = proc_pipe.registers[rA];
        end

        if (icode == 4'b0011)
        begin
            //irmovq
            valA = proc_pipe.registers[rB];
        end

        if (icode == 4'b0100)
        begin
            //rmmovq
            valA = proc_pipe.registers[rA];
            valB = proc_pipe.registers[rB];
        end

        if (icode == 4'b0101)
        begin
            //mrmovq
            valB = proc_pipe.registers[rB];
        end 

        if (icode == 4'b0110)
        begin
            //OPq
            valA = proc_pipe.registers[rA];
            valB = proc_pipe.registers[rB];
        end

        if (icode == 4'b1000)
        begin
            //call
            stack_pointer = 4;
            // valA = proc_pipe.registers[stack_pointer];   
            valB = proc_pipe.registers[stack_pointer];   
        end

        if (icode == 4'b1001)
        begin
            //ret
            stack_pointer = 4;
            // valA = proc_pipe.registers[stack_pointer];   
            valB = proc_pipe.registers[stack_pointer];
        end

        if (icode == 4'b1010)
        begin
            //pushq
            stack_pointer = 4;
            valA = proc_pipe.registers[rA];
            valB = proc_pipe.registers[stack_pointer];
        end

        if (icode == 4'b1011)
        begin
            //popq
            stack_pointer = 4;
            valB = proc_pipe.registers[stack_pointer];
        end
    end

endmodule

`include "mux.v"

module adder (
    input [63:0] A, 
    input [63:0] B, 
    input M, 
    output [63:0] sum
);
    genvar i;
    wire [64:0] C;
    wire [63:0] AXORB, BXORM;
    wire [63:0] AND1, AND2;

    assign C[0] = M;

    generate
        for (i = 0; i <= 63; i = i + 1) 
        begin 
            xor x1(BXORM[i], C[0], B[i]);
            xor x2(AXORB[i], A[i], BXORM[i]);
            xor x3(sum[i], AXORB[i], C[i]);
            and a1(AND1[i], A[i], BXORM[i]);
            and a2(AND2[i], AXORB[i], C[i]);
            or o1(C[i+1], AND1[i], AND2[i]);
        end
    endgenerate
endmodule

module subtractor (
    input [63:0] A, 
    input [63:0] B, 
    input M, 
    output [63:0] diff
);
    genvar i;
    wire [64:0] C;
    wire [63:0] AXORB, BXORM;
    wire [63:0] AND1, AND2;

    assign C[0] = M;

    generate    
        for (i = 0; i <= 63; i = i + 1) 
        begin 
            xor x1(BXORM[i], C[0], B[i]);
            xor x2(AXORB[i], A[i], BXORM[i]);
            xor x3(diff[i], AXORB[i], C[i]);
            and a1(AND1[i], A[i], BXORM[i]);
            and a2(AND2[i], AXORB[i], C[i]);
            or o1(C[i+1], AND1[i], AND2[i]);
        end
    endgenerate
endmodule

module andder (
    input [63:0] A, 
    input [63:0] B, 
    output [63:0] and_out
);
    genvar i;
    generate
        for (i = 0; i <= 63; i = i + 1) 
        begin 
            and a1(and_out[i], A[i], B[i]);
        end
    endgenerate
endmodule

module xor_calc (
    input [63:0] A, 
    input [63:0] B, 
    output [63:0] xor_out
);
    genvar i;
    generate
        for (i = 0; i <= 63; i = i + 1) 
        begin 
            xor x1(xor_out[i], A[i], B[i]);
        end
    endgenerate
endmodule

//Final Implementation
module final (
    input S0, 
    input S1, 
    input [63:0] A, 
    input [63:0] B, 
    output [63:0] sum, 
    output [63:0] diff, 
    output [63:0] and_out, 
    output [63:0] xor_out, 
    output reg overflow
);
    wire D0, D1, D2, D3;
    mux d1(S0, S1, D0, D1, D2, D3);
    wire [63:0] Aadd, Badd, Asub, Bsub, Aand, Band, Axor, Bxor;
    genvar i;
    generate
        for (i = 0; i <= 63; i = i + 1) 
        begin 
            and a1(Aadd[i], A[i], D0);
            and a2(Badd[i], B[i], D0);
            and a3(Asub[i], A[i], D1);
            and a4(Bsub[i], B[i], D1);
            and a5(Aand[i], A[i], D2);
            and a6(Band[i], B[i], D2);
            and a7(Axor[i], A[i], D3);
            and a8(Bxor[i], B[i], D3);
        end
    endgenerate

    adder add1(.A(Aadd), .B(Badd), .M(D1), .sum(sum));
    subtractor sub1(.A(Asub), .B(Bsub), .M(D1), .diff(diff));
    andder and1(.A(Aand), .B(Band), .and_out(and_out));  
    xor_calc xor1(.A(Axor), .B(Bxor), .xor_out(xor_out));

    always @* begin 
        if ((S0 == 0) && (S1 == 0)) begin
            if (((Aadd > 0) && (Badd > 0) && (sum < 0)) || ((sum >= 0) && (Aadd < 0) && (Badd < 0))) begin
                overflow = 1;
            end
            else begin
                overflow = 0;
            end
        end
        else begin
            overflow = 0;
        end
    end

    always @* begin
        if ((S0 == 1) && (S1 == 0)) begin
            if (((Asub > 0) && (Bsub < 0) && (diff < 0)) || ((diff > 0) && (Asub < 0) && (Bsub > 0))) begin
                overflow = 1;
            end
            else begin
                overflow = 0;
            end
        end
        else begin
            overflow = 0;
        end
    end
endmodule

module execute (
    input clk,
    input [63:0] valA,
    input [63:0] valB,
    input [3:0] icode,
    input [3:0] ifun,
    input [63:0] valC,
    output reg [63:0] valE,
    output reg g,
    output reg ge,
    output reg e,
    output reg ne,
    output reg le,
    output reg l,
    output reg [63:0] val_temp
);

    wire [63:0] sum, diff, and_out, xor_out;
    wire overflow;

    wire [63:0] sum1, diff1, and_out1, xor_out1;
    wire overflow1;

    wire [63:0] sum2, diff2, and_out2, xor_out2;
    wire overflow2;

    wire [63:0] sum3, diff3, and_out3, xor_out3;
    wire overflow3;

    wire [63:0] sum4, diff4, and_out4, xor_out4;
    wire overflow4;

    reg overflowflag;
    
    reg ZF,SF,OF;
    
    initial begin
        ZF = 0;
        SF = 0;
        OF = 0;
    end

    final final_module(1'b0, 1'b0, valA, valB, sum, diff, and_out, xor_out, overflow);

    final final_module2(1'b0, 1'b0, valC, valB, sum1, diff1, and_out1, xor_out1, overflow1);

    final final_module3(1'b1, 1'b1,valA, valB, sum2,diff2, and_out2, xor_out2, overflow2);

    final final_module4(1'b1, 1'b0, valA, valB, sum3, diff3, and_out3, xor_out3, overflow3);

    final final_module5(1'b0, 1'b1, valA, valB, sum4, diff4, and_out4, xor_out4, overflow4);


    always @* begin
            case(icode)
                4'b0100, 4'b0101: begin // rmmovq and mrmovq
                    valE = sum1;
                    //is it valC or (valA + valB) or (valA + valC)
                     
                end
                4'b0100: begin // push
                    valE = valB - 64'd8; //changed from valA 
                end
                4'b0101: begin // pop
                    valE = valB + 64'd8;
                end
                8: begin // call
                    valE = valB + 64'd8;
                end
                9: begin // ret
                    valE = valB - 64'd8;
                end
                3: begin // irmovq
                    valE = valA;
                end
                2: begin // rrmovq
                    valE = valA;
                end
                6: begin // Add, Subtract, And, Xor
                    case(ifun)
                        0: begin // Add
                            valE = sum;
                            val_temp = valE;
                            overflowflag = overflow;
                        end
                        1: begin // Subtract
                            valE = diff3;
                            val_temp = valE;
                            overflowflag = overflow3;
                        end
                        2: begin // And
                            valE = and_out4;
                            val_temp = valE;
                            overflowflag = overflow4;
                        end
                        3: begin // Xor
                            valE = xor_out2;
                            val_temp = valE;
                            overflowflag = overflow2;
                        end
                    endcase
                end
            endcase

        if(val_temp == 0)
        begin
            ZF = 1;
        end

        if(val_temp < 0)
        begin
            SF = 1;
        end

        if(val_temp > 0)
        begin
            ZF = 0;
            SF = 0;
        end

        if(overflowflag == 1)
        begin
            OF = 1;
        end
        
        g = ~(SF ^ OF) && (~ZF);
        ge = ~(SF ^ OF);
        e = ZF;
        ne = ~ZF;
        le = (SF ^ OF) || ZF;
        l = SF ^ OF;
    end
endmodule

module memory(
    input clk,
    input [3:0] icode,      
    input [63:0] valA,        
    input [63:0] valB,
    input [63:0] valE,          
    input [63:0] valP,
    output reg [63:0] valM     
);

reg [63:0] memory[0:1023]; 
reg [63:0] address, data;

always@(posedge clk)
    begin
        //rmmovq
        if(icode == 4'b0100) 
        begin
            address = valE;
            memory[address] = valA;
        end

        // pushq 
        else if(icode == 4'b1010)
        begin
            address = valE;
            memory[address]= valA;
        end

        // call
        else if (icode == 4'b1000) 
        begin 
            address = valE;
            memory[address] = valP;
        end
    end

    always@(*)
    begin
        //mrmovq
        if(icode == 4'b0101)
        begin
            address = valE;
            valM = memory[address];
        end

        //popq (We dont know if its valB or valA
        if(icode==4'b1011)
        begin
            address = valB;
            valM = memory[address];
        end

        //ret
         else if (icode == 4'b1001) 
         begin
            address = valB;
            valM = memory[address];
        end
    end
  
endmodule

module writeback(
    input clk,                 
    input [3:0] rA,           
    input [3:0] rB,           
    input [3:0] icode,       
    input [3:0] ifun,     
    input [63:0] valC,
    input g,
    input ge,
    input e,
    input ne,
    input le, 
    input l,        
    input [63:0] valM,
    input [63:0] valE,
    input [63:0] valP,
    output reg [63:0] destE,
    output reg [63:0] valA,
    output reg [63:0] valB
);
    reg stack_pointer;
    
    always @(posedge clk)
    begin
        
        if (icode == 4'b0010)
        begin
            //rrmovq
            if(ifun == 4'b0000)
            begin
                destE = rB;
                proc_pipe.registers[destE] = valE;
            end

            //cmovle
            if((ifun == 4'b0001) && (le == 1))
            begin
                destE = rB;
                proc_pipe.registers[destE] = valE;
            end

            //cmovl
            if((ifun == 4'b0010) && (l == 1))
            begin
                destE = rB;
                proc_pipe.registers[destE] = valE;
            end

            //cmove
            if((ifun == 4'b0011) && (e == 1))
            begin
                destE = rB;
                proc_pipe.registers[destE] = valE;
            end

            //cmovne
            if((ifun == 4'b0100) && (ne == 1))
            begin
                destE = rB;
                proc_pipe.registers[destE] = valE;
            end

            //cmovge
            if((ifun == 4'b0101) && (ge == 1))
            begin
                destE = rB;
                proc_pipe.registers[destE] = valE;
            end

            //cmovg
            if((ifun == 4'b0110) && (g == 1))
            begin
                destE = rB;
                proc_pipe.registers[destE] = valE;
            end
        end

        //irmovq
        if (icode == 4'b0011)
        begin
            proc_pipe.registers[rB] = valC;
        end

        //rmmovq - nothing

        //mrmovq
        if (icode == 4'b0101)
        begin
            proc_pipe.registers[rA] = valM; // we changed it to rA from rB
        end 

        //OPq
        if (icode == 4'b0110)
        begin
            proc_pipe.registers[rB] = valE;
        end

        //call
        if (icode == 4'b1000)
        begin
            stack_pointer = 4;
            proc_pipe.registers[stack_pointer] = valP;   
        end

        //ret
        if (icode == 4'b1001)
        begin
            stack_pointer = 4;
            proc_pipe.registers[stack_pointer] = valP;
        end

        //pushq
        if (icode == 4'b1010)
        begin
            stack_pointer = 4;
            proc_pipe.registers[stack_pointer] = valE;
        end

        //popq
        if (icode == 4'b1011)
        begin
            stack_pointer = 4;
            proc_pipe.registers[stack_pointer] = valE;
        end
    end

endmodule

module pcupdate(
    input [3:0] icode, 
    input [3:0] ifun,     
    input [63:0] valC,   
    input [63:0] valM,    
    input [63:0] valP,
    input le,
    input l,
    input e,
    input ne,
    input ge,
    input g,
    output reg [63:0] newPC
);

always @(*) begin
    newPC = valP;
    
    if (icode == 4'b1000) 
    begin // call Dest
        newPC = valC; // Set PC to destination
    end 

    else if (icode == 4'b1001) 
    begin // ret
        newPC = valM; // Set PC to return address
    end

    else if(icode == 4'b0111)
    begin
        if(ifun == 4'b0000)
        begin
            newPC = valC;
        end

        else if ((ifun == 4'b0001) && (le == 1))  
        begin
            newPC = valC; 
        end

        else if ((ifun == 4'b0010) && (l == 1)) 
        begin
            newPC = valC;
        end

        else if ((ifun == 4'b0011) && (e == 1)) 
        begin
            newPC = valC;
        end

        else if ((ifun == 4'b0100) && (ne == 1))
        begin
            newPC = valC;
        end

        else if ((ifun == 4'b0101) && (ge == 1))
        begin
            newPC = valC;
        end

        else if ((ifun == 4'b0110) && (g == 1))
        begin
            newPC = valC;
        end
    end
end
endmodule
