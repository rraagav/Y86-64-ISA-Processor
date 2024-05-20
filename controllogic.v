module controllogic(
    input clk,
    input e_cnd,
    input [3:0] m_stat, W_stat, d_srcA, d_srcB, E_destM,
    input [3:0]  D_icode, E_icode, M_icode,
    output reg set_cc, 
    output reg D_bubble, E_bubble, M_bubble, 
    output reg F_stall, D_stall, W_stall
);

reg out1, out2, out3, out4, out5, out6, out7, out8, out9, out10, out11, out12;
initial begin 
    set_cc = 0;
    F_stall = 0;
    D_stall = 0;
    W_stall = 0;
    D_bubble = 0;
    E_bubble = 0;
    M_bubble = 0;
end

always @(*)
begin
    out1 =  (E_destM == d_srcA || E_destM == d_srcB) && (E_icode == 4'd5 || E_icode == 4'd11);
    out2 = (D_icode == 4'd9 || E_icode == 4'd9 || M_icode == 4'd9);
  if (out1 || out2)
  begin
    F_stall=1;
  end
  
  else 
   begin
     F_stall=0;
   end
    //F_stall = (out1 || out2); writing like this is not working for some reason

    out3 = (E_destM == d_srcA || E_destM == d_srcB);
    out4 = (E_icode == 4'd5 || E_icode == 4'd11);

//    D_stall = (out3 && out4); 
    if(out3 && out4)
    begin
      D_stall = 1;
    end
    else
    begin
      D_stall = 0;
    end


    //W_stall = (W_stat == 4'd2 || W_stat == 4'd3 || W_stat == 4'd4);
     if(W_stat == 4'd2 || W_stat == 4'd3 || W_stat == 4'd4)
    begin
      W_stall = 1;
    end
    else
    begin
      W_stall = 0;
    end
    //Bubbles:

    out5 = (E_icode == 4'd7) && (!e_cnd);
    out6 = (E_icode == 4'd5 || E_icode == 4'd11) && (E_destM == d_srcA || E_destM == d_srcB);
    out7 = (D_icode == 4'd9 || E_icode == 4'd9 || M_icode == 4'd9);

    //D_bubble = ((out5) || ((!(out6)) && (out7)));
    if((out5) || ((!(out6)) && (out7)))
    begin
      D_bubble = 1;
    end
    else
    begin
      D_bubble = 0;
    end
    //Might be wrong, look at the IF Statements here.
    // !e_cnd is the same as e_cnd == 0

    out8 = (E_icode == 4'd7) && (!e_cnd);
    out9 = (E_icode == 4'd5 || E_icode == 4'd11);
    out10 = (E_destM == d_srcA || E_destM == d_srcB);

    //E_bubble = ((out8) || ((out9) && (out10)));

    if((out8) || ((out9) && (out10)))
    begin
      E_bubble = 1;
    end
    else
    begin
      E_bubble = 0;
    end

    out11 = (m_stat == 4'd3 || m_stat == 4'd4 || m_stat == 2'd2);
    out12 = (W_stat == 4'd3 || W_stat == 4'd4 || W_stat == 2'd2);

    //M_bubble = ((out11) || (out12));
    if((out11) || (out12))
    begin
      M_bubble = 1;
    end
    else
    begin
      M_bubble = 0;
    end
end
//E_dstM is E_destM
endmodule