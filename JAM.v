module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

wire [9:0] sum;
reg [3:0] change;
reg [2:0] set [0:7];
reg [6:0] cost0, cost1, cost2, cost3, cost4, cost5, cost6, cost7;
reg [2:0] cs, ns;
parameter IDLE  = 0, CHANGE = 1, MAXSITE = 2, SORT = 3, IN = 4, COM = 5, OUT = 6, DONE = 7;
reg [3:0] counter8;

reg [2:0]max;
reg [2:0]max_counter;
reg [1:0]counter2;
//reg turn;
reg change_done,max_done;
//reg [17:0] counter40320;
reg first,done;

always @(posedge CLK or posedge RST) begin
    if(RST)begin
        first <= 1;
    end
    else if(cs == COM)begin
        first <= 0;
    end
    else
        first <= first;
end

integer i;

assign sum = cost0 + cost1 + cost2 + cost3 + cost4 + cost5 + cost6 + cost7;


always @(posedge CLK or posedge RST) begin
    if(RST)
        cs <= IDLE;
    else
        cs <= ns;
end

always @(*) begin
    case (cs)
        IDLE:begin //0
            ns = CHANGE;
        end 
        CHANGE:begin //1
            if(change_done)
                ns=MAXSITE;
            else
                ns=CHANGE;
        end
        MAXSITE:begin //2
            if(max_done)
                ns=SORT;
            else
                ns=MAXSITE;
        end
        SORT:begin //3
            if(counter2==1)
                ns=IN;
            else
                ns=SORT;
        end
        IN:begin //4
            if(done)//counter40320 == 40320
                ns = COM;
            else if(counter8 == 8)
                ns = COM;
            else
                ns = IN;
        end
        COM:begin //5 
            if(done)
                ns = OUT;
            else
                ns = CHANGE;
        end
        OUT:begin //6
            ns = DONE;
        end
        DONE:begin //7
            ns = DONE;
        end
        default: 
            ns = IDLE;
    endcase
end

always @(*) begin
    if(set[0]==3'd7 & set[1]==3'd6 & set[2]==3'd5 & set[3]==3'd4 & set[4]==3'd3 & set[5]==3'd2 & set[6]==3'd1 & set[7]==3'd0)
        done =1;
    else
        done =0;
end



//COUNTER2
always @(posedge CLK or posedge RST) begin
    if(RST)
        counter2 <= 0;
    else if(cs==SORT)begin
        counter2 <= counter2 + 1;
    end
    else
        counter2 <= 0;
end

//set
always @(posedge CLK or posedge RST) begin
    if(RST)begin
        set[0]<=0;
        set[1]<=1;
        set[2]<=2;
        set[3]<=3;
        set[4]<=4;
        set[5]<=5;
        set[6]<=6;
        set[7]<=7;
    end
    else if(cs==SORT)begin
        if (counter2==0) begin
            if(first)
                set[max] <= set[max];
            else begin
                set[max]<=set[change];
                set[change]<=set[max];
            end
        end
        else begin
            for(i=7;i>0; i=i-1) begin
                if(i>change)
                    set[i]<=set[change+8-i];
            end
        end
    end
end

//change
always @(posedge CLK or posedge RST) begin
    if(RST)
        change<=3'd6;
    else if(cs==CHANGE)begin
        if(set[change]>set[change+1])//
            change<=change-1;
    end
    else if(cs==COM)begin
        change<=3'd6;
    end
end

//change_done
always @(*) begin
    if(cs==CHANGE)begin
        if(set[change]<set[change+1])
            change_done=1;
        else
            change_done=0;
    end
    else 
        change_done=0;
end

//max_counter
always @(posedge CLK or posedge RST) begin
    if(RST)
        max_counter<=3'd7;
    else if(cs==MAXSITE)begin
        max_counter<=max_counter-1;
    end
    else
        max_counter<=3'd7;
end

//max_done
always @(*) begin
    if(cs==MAXSITE)begin
        if(max_counter==change+1)//? -1 or not
            max_done=1;
        else
            max_done=0;
    end
    else
        max_done=0;
end

//max
always @(posedge CLK or posedge RST) begin
    if(RST)
        max<=3'd7;
    else if(cs==MAXSITE)begin
        if(set[change]<set[max_counter])begin
            if(change==3'd6)
                max<=3'd7;
            else if(set[max]<set[change] )
                max<=max_counter;
            else if(set[max_counter]<set[max])//get the smallest right 
                max<=max_counter;
        end
    end
    else if(cs==COM)begin
        max<=3'd7;
    end
end

//J
always @(*) begin
    if(cs == IN)
        J = set[counter8];
    else 
        J = 0;
end

//W
always @(*) begin
    if(cs == IN)
        W = counter8;
    else 
        W = 0;
end

//COUNTER8
always @(posedge CLK or posedge RST) begin
    if(RST)
        counter8 <= 0;
    else if(cs == IN)
        counter8 <= counter8 + 1; 
    else if(ns == IN)
        if(first)
            counter8 <= counter8;
        else
            counter8 <= change;
    else 
        counter8 <= 0;
end

//COST
always @(posedge CLK or posedge RST) begin
    if(RST)begin
        cost0 <= 0;
        cost1 <= 0;
        cost2 <= 0;
        cost3 <= 0;
        cost4 <= 0;
        cost5 <= 0;
        cost6 <= 0;
        cost7 <= 0;
    end
    else if(cs == IN)
        case (counter8)
            0:begin
                cost0 <= Cost;
            end 
            1:begin
                cost1 <= Cost;
            end 
            2:begin
                cost2 <= Cost;
            end 
            3:begin
                cost3 <= Cost;
            end 
            4:begin
                cost4 <= Cost;
            end 
            5:begin
                cost5 <= Cost;
            end 
            6:begin
                cost6 <= Cost;
            end 
            7:begin
                cost7 <= Cost;
            end 
        endcase
end

//MINSCOST
always @(posedge CLK or posedge RST) begin
    if(RST)
        MinCost <= 10'b1111111111;
    else if(cs == COM)
        MinCost <= (MinCost > sum) ? sum : MinCost;
    else
        MinCost <= MinCost;
end

//MATCHCOUNT
always @(posedge CLK or posedge RST) begin
    if(RST)
        MatchCount <= 0;
    else if(cs == COM)
        if(MinCost > sum)
            MatchCount <= 1;
        else if(MinCost == sum)
            MatchCount <= MatchCount + 1;
        else
            MatchCount <= MatchCount;
    else
        MatchCount <= MatchCount;
end

//VALID
always @(posedge CLK or posedge RST) begin
    if(RST)
        Valid <= 0;
    else if(cs == OUT)
        Valid <= 1;
    else 
        Valid <= 0;
end

endmodule


