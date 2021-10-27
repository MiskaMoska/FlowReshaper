module FlowReshaper (
    input       wire                    clk,
    input       wire                    rstn,
    output      wire                    rd_en,
    output      wire        [19:0]      rd_addr,
    input       wire        [7:0]       rd_data,
    output      wire                    wr_en,
    output      wire        [19:0]      wr_addr,
    output      wire        [7:0]       wr_data,
    input       wire                    ena
);

//-----------------------------------------------------------------//
//                      Pipeline Stage 0                           //
//-----------------------------------------------------------------//
reg valid_0; //valid_0 == 1 indicates the system is running
always@(posedge clk or negedge rstn) begin
    if(~rstn) valid_0 <= 1'b0;
    else if(ena) valid_0 <= 1'b1;
    else if(done) valid_0  <= 1'b0;
end

reg [8:0] dst_i_0,dst_j_0;
reg [1:0] win_cnt_0;

wire dst_i_0_full,dst_j_0_full,win_cnt_0_full;
assign dst_i_0_full = (dst_i_0 == 259);
assign dst_j_0_full = (dst_j_0 == 259);
assign win_cnt_0_full = win_cnt_0[1] & win_cnt_0[0];

wire done;
assign done = dst_i_0_full & dst_j_0_full & win_cnt_0_full;

always@(posedge clk or negedge rstn) begin
    if(~rstn) win_cnt_0 <= 0;
    else begin
        if(ena) win_cnt_0 <= 0;
        else if(valid_0) begin
            win_cnt_0 <= win_cnt_0 + 1; //00,01,10,11,00 ....
        end
    end
end

always@(posedge clk or negedge rstn) begin
    if(~rstn) dst_j_0 <= 1'b0;
    else begin
        if(ena) dst_j_0 <= 1'b0;
        else if(valid_0 & win_cnt_0_full) begin
            if(dst_j_0_full) dst_j_0 <= 0;
            else dst_j_0 <= dst_j_0 + 1;
        end
    end
end

always@(posedge clk or negedge rstn) begin
    if(~rstn) dst_i_0 <= 1'b0;
    else begin
        if(ena) dst_i_0 <= 1'b0;
        else if(valid_0 & win_cnt_0_full & dst_j_0_full) begin
            if(dst_i_0_full) dst_i_0 <= 0;
            else dst_i_0 <= dst_i_0 + 1;
        end
    end
end

wire [19:0] addr_0;
assign addr_0 = dst_i_0 * 260 + dst_j_0;

reg [7:0] src_i_1;
reg [8:0] src_j_1;
reg [7:0] u_1,v_1;

(* romstyle = "block" *) reg [7:0] SrcIROM [0:259];
(* romstyle = "block" *) reg [8:0] SrcJROM [0:259];
(* romstyle = "block" *) reg [7:0] UROM [0:259];
(* romstyle = "block" *) reg [7:0] VROM [0:259];

initial begin
    $readmemh("F:/vivado_proj/FlowReshaper/srcs_opt/SrcI.txt",SrcIROM);
    $readmemh("F:/vivado_proj/FlowReshaper/srcs_opt/SrcJ.txt",SrcJROM);
    $readmemh("F:/vivado_proj/FlowReshaper/srcs_opt/u.txt",UROM);
    $readmemh("F:/vivado_proj/FlowReshaper/srcs_opt/v.txt",VROM);
end

always@(posedge clk or negedge rstn) begin
    if(~rstn) begin 
        src_i_1 <= 0; src_j_1 <= 0;
        u_1 <= 0; v_1 <= 0;
    end
    else begin 
        src_i_1 <= SrcIROM[dst_i_0]; 
        src_j_1 <= SrcJROM[dst_j_0];
        u_1 <= UROM[dst_i_0];
        v_1 <= VROM[dst_j_0];
    end
end



//-----------------------------------------------------------------//
//                      Pipeline Stage 1                           //
//-----------------------------------------------------------------//
reg valid_1;
reg [1:0] win_cnt_1;
reg [19:0] addr_1;
always@(posedge clk) begin
    valid_1 <= valid_0;
    win_cnt_1 <= win_cnt_0;
    addr_1 <= addr_0;
end

wire [7:0] src_i_rt_1;
wire [8:0] src_j_rt_1;
assign src_i_rt_1 = (src_i_1 != 239) & win_cnt_1[1] ? src_i_1 + 1 : src_i_1;
assign src_j_rt_1 = (src_j_1 != 319) & win_cnt_1[0] ? src_j_1 + 1 : src_j_1;

wire [7:0] cu_1,cv_1;
assign cu_1 = (u_1 == 0) ? 8'hFF : (~ u_1) + 1'b1;
assign cv_1 = (v_1 == 0) ? 8'hFF : (~ v_1) + 1'b1;


//-----------------------------------------------------------------//
//                      Pipeline Stage 2                           //
//-----------------------------------------------------------------//
reg valid_2;
reg [7:0] src_i_rt_2;
reg [8:0] src_j_rt_2;
reg [7:0] u_2,v_2,cu_2,cv_2;
reg [1:0] win_cnt_2;
reg [19:0] addr_2;
always@(posedge clk) begin
    valid_2 <= valid_1;
    {src_i_rt_2,src_j_rt_2} <= {src_i_rt_1,src_j_rt_1};
    {u_2,v_2,cu_2,cv_2} <= {u_1,v_1,cu_1,cv_1};
    win_cnt_2 <= win_cnt_1;
    addr_2 <= addr_1;
end

wire [19:0] real_addr_2;
assign real_addr_2 = src_i_rt_2 * 320 + src_j_rt_2;

wire [15:0] w00_2,w01_2,w10_2,w11_2;
assign w00_2 = cv_2 * cu_2;
assign w01_2 = cv_2 * u_2;
assign w10_2 = cu_2 * v_2;
assign w11_2 = u_2 * v_2;


//-----------------------------------------------------------------//
//                      Pipeline Stage 3                           //
//-----------------------------------------------------------------//
reg valid_3;
reg [19:0] addr_3;
reg [19:0] real_addr_3;
reg [15:0] w_3;
reg [15:0] w00_3,w01_3,w10_3,w11_3;
reg [1:0] win_cnt_3;
always@(posedge clk) begin
    valid_3 <= valid_2;
    addr_3 <= addr_2;
    real_addr_3 <= real_addr_2;
    {w00_3,w01_3,w10_3,w11_3} <= {w00_2,w01_2,w10_2,w11_2};
    win_cnt_3 <= win_cnt_2;
end

assign rd_addr = real_addr_3;
assign rd_en = valid_3;

reg [15:0] w_3;
always@(*) begin
    case(win_cnt_3) 
        2'b00: w_3 = w00_3;
        2'b01: w_3 = w01_3;
        2'b10: w_3 = w10_3;
        2'b11: w_3 = w11_3;
    endcase
end

//-----------------------------------------------------------------//
//                      Pipeline Stage 4                           //
//-----------------------------------------------------------------//
reg valid_4;
reg [19:0] addr_4;
reg [15:0] w_4;
reg [1:0] win_cnt_4;
always@(posedge clk) begin
    valid_4 <= valid_3;
    addr_4 <= addr_3;
    w_4 <= w_3;
    win_cnt_4 <= win_cnt_3;
end

wire [23:0] prod_4;
assign prod_4 = w_4 * rd_data;


//-----------------------------------------------------------------//
//                      Pipeline Stage 5                           //
//-----------------------------------------------------------------//
reg valid_5;
reg [19:0] addr_5;
reg [1:0] win_cnt_5;
reg [23:0] prod_5;
always@(posedge clk) begin
    valid_5 <= valid_4;
    addr_5 <= addr_4;
    win_cnt_5 <= win_cnt_4;
    prod_5 <= prod_4;
end

wire [23:0] sum_5,psum_5;
assign sum_5 = prod_5 + psum_6;
assign psum_5 = (win_cnt_5 == 2'b11) | (~valid_5) ? 0 : sum_5;
assign wr_addr = addr_5;
assign wr_en = (win_cnt_5 == 2'b11);


//-----------------------------------------------------------------//
//                      Pipeline Stage 6                           //
//-----------------------------------------------------------------//
reg valid_6;
reg [23:0] psum_6;
reg [23:0] sum_6;
always@(posedge clk) begin
    valid_6 <= valid_5;
    psum_6 <= psum_5;
    sum_6 <= sum_5;
end

assign wr_data = sum_6[23:16];

endmodule