module mux (
    input S0, 
    input S1, 
    output D0, D1, D2, D3
);
    wire S0comp, S1comp;
    
    not n1(S0comp, S0);
    not n2(S1comp, S1);

    and a1(D0, S0comp, S1comp);
    and a2(D1, S0, S1comp);
    and a3(D2, S0comp, S1);
    and a4(D3, S0, S1);
endmodule

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
