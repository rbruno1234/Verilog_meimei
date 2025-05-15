always@(posedge clk)
  begin
    next_state=state;
    case(state)
      S0:
        begin
          if(in)
            next_state=S1;
          else
            next_state=S2;
        end

      S1:
        begin
          if(in)
            next_state=S3;
          else
            next_state=S0;
        end

      S2:
        begin
          if(in)
            next_state=S0;
          else
            next_state=S3;
        end

      S3:
        begin
            next_state=S1;

        end
    endcase
  end
